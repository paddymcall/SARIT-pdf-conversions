#!/usr/bin/env bash

set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

OLDIFS=$IFS
IFS=$(echo -en "\n\b")

BASEDIR=$(dirname "${0}")/../
XMLFILE="${1:-}"
OUTDIR="${2:-}"
STYLESHEET=$(realpath "${BASEDIR}"./Stylesheets/profiles/sarit/latex/to.xsl)
REVISION=$(git rev-parse --short --verify HEAD || echo "No Revision")

function cleanup {
    IFS=$OLDIFS
    # echo "Finishing up regardless"
}
trap cleanup EXIT

USAGE="Usage: $0 path/to/doc.xml [ path/to/output/dir/ ] [ key=param key2=param2 key3=param3 ]
The key/param fields are passed to saxonb-xslt."

if [ -z "${XMLFILE}" ]; then
    echo "$USAGE"
    exit 1
elif [ -f "${XMLFILE}" ]; then
    XMLFILE=$(realpath "$XMLFILE")
    shift
else
    echo "XML Doc ${XMLFILE} not found."
    exit 1
fi

if [ -z "${OUTDIR}" ] && [ -d "${BASEDIR}"/TeX/ ]; then
    OUTDIR=$(realpath "${BASEDIR}"/TeX/)
    echo "OUTDIR is: ${OUTDIR}"
elif [ -d "${OUTDIR}" ]; then
    OUTDIR=$(realpath "${OUTDIR}")
    shift
else
    echo "Target directory ${OUTDIR} does not exist."
    exit 1
fi

OUTPUT="${OUTDIR}"/"$(basename "${XMLFILE}" .xml)".tex

echo "Converting ${XMLFILE} to ${OUTPUT}"

if type emacs > /dev/null 2>&1  && [ -f "${BASEDIR}"/bin/hyphenate.sh ]; then
    echo "Hyphenating"
    "${BASEDIR}"/bin/hyphenate.sh < "${XMLFILE}" | \
	saxonb-xslt -ext:on -xsl:"${STYLESHEET}" -s:- -o:"${OUTPUT}" revision="${REVISION}" "$@"
else
    echo "Not hyphenating"
    saxonb-xslt -ext:on -xsl:"${STYLESHEET}" -s:- -o:"${OUTPUT}" revision="${REVISION}" < "${XMLFILE}" "$@"
fi

# \
# reencode=false  \
# documentclass=memoir \
# userpackage=bibsetup \
# mainFont=Chandas \
# printtoc=true \
# showteiheader=true \
# usetitling=true \
# useHeaderFrontMatter=false \
# # not used: \
# useHeaderFrontMatter=false 

# xelatex -shell-escape $output.tex

echo "Converted ${XMLFILE} to ${OUTPUT}"
