#!/usr/bin/env bash

# see http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

OLDIFS=$IFS
IFS=$(echo -en "\n\b")

BASEDIR="$(realpath $(dirname ${0})/../)"
STARTDIR="$(pwd)"

TEXFILE="${1:-}"

function cleanup {
    cd ${STARTDIR}
    IFS=$OLDIFS
    echo "Cleaning up"
}
trap cleanup EXIT

if [ -z "${TEXFILE}" ]
    then
    echo "Please specify name of a TeX file."
    exit 1
fi

TEXDIR="$(dirname ${TEXFILE})"
COMPILEFILE="$(basename ${TEXFILE} .tex)"

cd ${TEXDIR}

# -8bit needed for the "^^I"/tab problem in minted environment
latexmk -f -gg -time -rules \
	-xelatex \
	-file-line-error \
	-8bit \
	-shell-escape \
	-interaction=nonstopmode \
	${COMPILEFILE}
