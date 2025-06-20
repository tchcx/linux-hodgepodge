### This is a demonstration for a Pentest+ class
# Specifically to show off code obfuscators but hey,
# Why not write the entire ransomeware too.
# Yaknow?

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
}


# Find user file within the specified directory
# Ensure directory exists and we can access it
# Search within accessible directories for user files
# Check file permissions with check_files()

find_files() {
    # Directory exists?
    if ! [[ -d "$1" ]]; then
        echo "Can't find $1."
        return 1
    else
        echo "Found $1."
    fi

    # We have permissions?
    if ! [[ -x "$1" && -r "$1" ]]; then
        echo -e "\tCan't access $1 (permissions)"
        return 1
    else
        echo -e "\tWe can access directory."
    fi

    # Search in directory
    ext_regex='.*\.\(csv\|xslx\|docx\|rtf\|pdf\|ost\|pst\|zip\|rar\|7z\|png\|txt\)$'

    find . -maxdepth 1 -type f -iregex "$ext_regex" -print0 | \
        while IFS= read -r -d $'\0' file; do
        echo "Found file type associated with users: $file. Checking permissions..."
        check_file "$1/$file"
    done

}


### Test directories with different permissions

# Read+Execute
find_files rx_dir

# No read or execute
find_files no_rx_dir

# No read
find_files no_r_dir

# No execute
find_files no_x_dir

### Identical files within each:

# Read+Write
rw_file.png

# Read permissions
r_file.csv

# Write permissions
w_file.pdf

# No permissions
no_rw_file.docx
