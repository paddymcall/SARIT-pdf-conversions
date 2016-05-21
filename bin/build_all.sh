#!/usr/bin/env bash

# see http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

OLDIFS=$IFS
IFS=$(echo -en "\n\b")

STARTDIR="$(pwd)"
CORPUS="${1:-}"

if [ -z "${CORPUS}" ]
then
    echo "Please specify name of corpus file (usually SARIT-corpus/saritcorpus.xml)."
    exit 1
fi

OUTDIR="${2:-}"

if [ -z "${OUTDIR}" ]; then
    OUTDIR="$(mktemp --tmpdir -d "pdf-conv-XXXX")"
elif [ ! -d "${OUTDIR}" ]; then
    echo "This is not a directory: ${OUTDIR}"
    exit 1
fi

echo "Will save output to $OUTDIR"

function cleanup {
    cd $STARTDIR
    IFS=$OLDIFS
    echo "Cleaning up, results should be in ${OUTDIR}"
}
trap cleanup EXIT

BASEDIR="$(realpath $(dirname ${0})"/../")"
CONVERSIONSCRIPT="$(realpath ${BASEDIR}"/bin/convert_sarit_to_tex.sh")"
COMPILETEXSCRIPT="$(realpath ${BASEDIR}"/bin/compile_xetex.sh")"


CORPUS="$(realpath ${CORPUS})"
XDIR="$(dirname ${CORPUS})"


cd "$XDIR"

echo "Calling xmlstarlet"

xmlstarlet sel -N xi='http://www.w3.org/2001/XInclude' -t -v '//xi:include/@href'  "${CORPUS}" | \
    parallel --gnu -q --jobs -1 "${CONVERSIONSCRIPT}" "{}" "${OUTDIR}"

cd "${OUTDIR}"

find ./ -type f -iname "*tex" | parallel --gnu -q --jobs -1 "${COMPILETEXSCRIPT}" "{}"

if type pdfinfo > /dev/null 2>&1; then
    echo "Stats about the generated pdfs: "
    find ./ -type f -iname "*pdf" | parallel --gnu -q --jobs -1 pdfinfo "{}" 
fi

# for i in `ls *tex`
# do
#     xelatex -shell-escape -no-pdf -etex -interaction=nonstopmode ${i}
#     biber --nodieonerror --onlylog `basename ${i} .tex`
#     xelatex -shell-escape -no-pdf -etex -interaction=nonstopmode ${i}
#     biber --nodieonerror --onlylog `basename ${i} .tex`
#     xelatex -shell-escape -etex -interaction=nonstopmode ${i}
# done

# or this, but loses logs:
# parallel --jobs 0.5% $CONVERSIONSCRIPT {} ${OUTDIR} 2> >(zenity --progress --auto-kill)

