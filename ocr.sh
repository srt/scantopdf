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

#IMAGE_PROCESSING_OPTIONS="--convertToBWImage"
IMAGE_PROCESSING_OPTIONS=""
#IMAGE_PROCESSING_OPTIONS="-id --grayJpegQuality 90 --colorJpegQuality 90"
abbyyocr11 \
  --progressInformation \
  --recognitionLanguage German \
  $IMAGE_PROCESSING_OPTIONS \
  "${INPUT_FILES[@]}" \
  --skipEmptyPages \
  --outputFileFormat PDF \
  --pdfPaperSizeMode SynthesisSize \
  --pdfTextExportMode ImageOnText \
  --pdfaComplianceMode Pdfa_2a \
  --outputFileName "$1"
