#! /usr/bin/env bash

# OK this is an atrocity penosding refactoring. 
# Functionality over self respect, ya know

# Define where the items we want to back up are located
# My KeepassXC DB is a VirtioFS mount from host to guest
KPX_DB="/virtiofs/Share/tachybuntu.kdbx"

# GPG and SSH in the normal places
GPG_DIR="/home/$USER/.gnupg/"
SSH_DIR="/home/$USER/.ssh/"

# And we are backing up to a seperate storage disc I'll retaib
# on an encrypted drive
BK_TARG="/media/$USER/ext-storage/Backup/"

# By default, we don't want to commit, we fear yolo IT
COMMIT=0

# Rudimentary. Help or Commit
# The encryption part will be integrated laters
case "$1" in
 [Hh] | [Hh][Ee][Ll][Pp] ) 
      echo "h or help prints this dialog" 
      echo "c or commit does a real run"
      echo "default behavior is dry run rsync"
     ;;
 [Cc] | [Cc][Oo][Mm][Mm][Ii][Tt] )
      echo "Yolo rsync!"
      COMMIT=1
     ;;
   * ) 
     ;;
esac 



if [[ -d $GPG_DIR ]]; then
  echo "Found GPG directory in user home."
else
  echo "Could not find GPG directory in user home."
  exit 1
fi

if [[ -f $KPX_DB ]]; then
  echo "Found KeepassXC database."
else
  echo "Could not find KeepassXC database."
  exit 1
fi

if [[ -d $SSH_DIR ]]; then
  echo "Found SSH directory in user home."
else
  echo "Could not find SSH directory in user home."
  exit 1
fi

if [[ -d $BK_TARG ]]; then 
  echo "Found backup target directory."
else
  echo "Could not find backup target directory."
  exit 1
fi 


if [[ $COMMIT -eq 1 ]]; then
  echo "Performing real run."
  rsync -av "$KPX_DB" "$BK_TARG/KPX/"

  rsync -av "$GPG_DIR" "$BK_TARG/GPG/"

  rsync -av "$SSH_DIR" "$BK_TARG/SSH/"
fi

if [[ $COMMIT -eq 0 ]]; then
  echo "Performing dry run."
  rsync -av "$KPX_DB" "$BK_TARG/KPX/" --dry-run

  rsync -av "$GPG_DIR" "$BK_TARG/GPG/" --dry-run

  rsync -av "$SSH_DIR" "$BK_TARG/SSH/" --dry-run
fi



## For good measure we can encrypt and toss it in another location
##  openssl rand -hex 32 > ~/.backup_symm_key
##  chmod 600  ~/.backup_symm_key
## $GOOG_BK_DR is an env var

## All this needs to be cleaned up but it's late, and this is working, and chicken 
## wings are long since cold

# I'm going to have my cold chicken wings in my cold bed,
# and try to think positive things like "at least these tears are warm"

BK_KEY_FILE="/home/$USER/.backup_symm_key"
PASSPHRASE=$(cat "$BK_KEY_FILE")

cd "$BK_TARG/.."

gpgtar --symmetric --gpg-args "--passphrase=$PASSPHRASE --batch" -o "$GOOG_BK_DR/backup.gpg" "./Backup"
