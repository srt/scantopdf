#!/bin/bash

if [ "$#" -lt 2 ]
then
	echo "Usage: $0 source(s) destination.pdf" >&2
	exit 1
fi

i=0 INPUT_FILES=()
while [ "$#" -gt 1 ]
do 
  INPUT_FILES[$i]="--inputFileName"
  ((++i))
  INPUT_FILES[$i]="$1"
  ((++i))
  shift
done

IMAGE_PROCESSING_OPTIONS="-id --convertToBWImage"
#IMAGE_PROCESSING_OPTIONS="-id --grayJpegQuality 90 --colorJpegQuality 90"
abbyyocr9 \
  --progressInformation \
  --recognitionLanguage German \
  $IMAGE_PROCESSING_OPTIONS \
  "${INPUT_FILES[@]}" \
  --outputFileFormat PDFA \
  --pdfaExportMode ImageOnText \
  --pdfaReleasePageSizeByLayoutSize \
  --outputFileName "$1"
