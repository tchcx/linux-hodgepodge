#!/usr/bin/env bash

# Kinda maybe safe but also YOLOOOO
# Script downloads PDF using curl -> STDOUT
# GhostScript accepts via STDIN
# Re-renders it out without forms, annotations, etc.

# You can source it in .bashrc => . pdf_kinda_safe.sh URL
# To have it as an available command
# Or just run it as a script => ./pdf_kinda_safe.sh URL
# Either way, just add the url as an argument

function pdf_kinda_safe() {
  local url=$1
  # basename gets raw file name; sed removes URL encoding
  local filename=$(basename $url | sed -e 's/%20/_/g' -e 's/%21/!/g' -e 's/%23/#/g' -e 's/%24/$/g' -e 's/%26/\&/g' -e "s/%27/'/g" -e 's/%28/(/g' -e 's/%29/)/g')
  echo -n "\nDownloading $url..."
  echo -n "\nDownloading to $filename..."

curl $url | gs \
-dSAFER \
-dBATCH \
-dNOPAUSE \
-dNOCACHE \
-sDEVICE=pdfwrite \
-dSubsetFonts=true \
-dCompressFonts=true \
-dPreserveAnnots=false \
-dPreserveForms=false \
-dNoOutputFonts \
-dCreateJobTicket=false \
-dPreserveEPSInfo=false \
-dPreserveOPIComments=false \
-dPreserveOverprintSettings=false \
-dUCRandBGInfo=/Remove \
-dCompatibilityLevel=1.4 \
-dPDFSETTINGS=/ebook \
-dDownsampleColorImages=true \
-dColorImageDownsampleThreshold=1.1 \
-dColorImageResolution=144 \
-dColorImageDownsampleType=/Bicubic \
-dDownsampleGrayImages=true \
-dGrayImageDownsampleThreshold=1.1 \
-dGrayImageResolution=144 \
-dGrayImageDownsampleType=/Bicubic \
-dDownsampleMonoImages=true \
-dMonoImageDownsampleThreshold=1.1 \
-dMonoImageResolution=144 \
-dMonoImageDownsampleType=/Bicubic \
-sOutputFile=$filename -
}

if [[ -z $1 ]]; then
  echo -n "No URL provided. Assume sourcing."
else
  pdf_kinda_safe $1
fi
