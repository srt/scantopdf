#!/bin/bash

usage()
{
cat << EOF
usage: $0 options [file.pdf]

This script scans a document and produces a PDF file.

OPTIONS:
   -h      Show this message
   -d      Duplex
   -m      Mode, e.g. Lineart or Gray
   -r      Resolution in DPI
   -s      Page number to start naming files with
   -t      Title of PDF file
EOF
}

SOURCE="ADF Front"
MODE="Gray"
RESOLUTION="300"
BATCH_START="1"
TITLE=`uuidgen`
SUBJECT="${TITLE}"
#IMAGE_PROCESSING_OPTIONS="--convertToBWImage"
IMAGE_PROCESSING_OPTIONS=""
#IMAGE_PROCESSING_OPTIONS="-id --grayJpegQuality 90 --colorJpegQuality 90"

while getopts "hdm:r:s:t:" OPTION
do
	case $OPTION in
		h) usage; exit 1 ;;
		d) SOURCE="ADF Duplex" ;;
		m) MODE="$OPTARG" ;;
		r) RESOLUTION="$OPTARG" ;;
		s) BATCH_START="$OPTARG" ;;
		t) TITLE="$OPTARG"; SUBJECT="$OPTARG" ;;
	esac
done
shift $(($OPTIND - 1))

DEST_DIR="."
unset DEST_FILE

if [ $# == 1 ]
then
	DEST_FILE="$1"
	if [ -e "$DEST_FILE" ]
	then
		echo Error: $1 already exists
		exit 1
	fi
	DEST_DIR=$(mktemp -td scantopdf.XXXXXXXXX) || exit 1
fi

scanimage \
  -d canon_dr \
  --batch="${DEST_DIR}/out%03d.pnm" \
  --batch-start=${BATCH_START} \
  --resolution=${RESOLUTION} \
  -l 0 -t 0 -x 210 -y 297 \
  --page-width 210 --page-height 297 \
  --rollerdeskew=yes \
  --stapledetect=yes \
  --mode="${MODE}" \
  --resolution="${RESOLUTION}" \
  --source "${SOURCE}"

#  --swcrop=yes \

#  --df-thickness=yes \
#unpaper -v --dpi ${RESOLUTION} -s a4 "${DEST_DIR}/out%03d.pnm" "${DEST_DIR}/unpaper_out%03d.pnm"
#for i in "${DEST_DIR}/unpaper_out"*; do pnmtotiff "${i}" > "${i}.tif"; done

for i in "${DEST_DIR}/out"*.pnm
do
  pnmtotiff \
    -xresolution "${RESOLUTION}" \
    -yresolution "${RESOLUTION}" \
    -lzw "${i}" > ${DEST_DIR}/`basename "${i}" .pnm`.tif
  rm "${i}"
done

if [ ! -z "$DEST_FILE" ]
then
	tiffcp "${DEST_DIR}/"*".tif" "${DEST_DIR}/all.tif"
	abbyyocr11 \
	  --progressInformation \
	  --recognitionLanguage German \
	  $IMAGE_PROCESSING_OPTIONS \
	  --inputFileName "${DEST_DIR}/all.tif" \
	  --skipEmptyPages \
	  --outputFileFormat PDF \
	  --pdfPaperSizeMode SynthesisSize \
	  --pdfTextExportMode ImageOnText \
	  --pdfaComplianceMode Pdfa_2a \
	  --outputFileName "${DEST_DIR}/result.pdf"
#	tiff2pdf \
#	  -j -q 50 \
#	  -pA4 -x "${RESOLUTION}" -y "${RESOLUTION}" \
#	  -f \
#	  -c "reuter network consulting" \
#	  -a "reuter network consulting" \
#	  -t "${TITLE}" \
#	  -s "${SUBJECT}" \
#	  -o "${DEST_DIR}/result.pdf" "${DEST_DIR}/all.tif"
	mv "${DEST_DIR}/result.pdf" "$DEST_FILE"

	echo rm -rf "${DEST_DIR}"
fi

