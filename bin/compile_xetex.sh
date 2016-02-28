#!/usr/bin/env bash

# see http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

BASEDIR=$(realpath $(dirname ${0})"/../")

TEXFILE=${1:-}

if [ -z "${TEXFILE}" ]
    then
    echo "Please specify name of a TeX file."
    exit 1
fi

STARTDIR=$(pwd)
TEXDIR=$(dirname ${TEXFILE})
COMPILEFILE=$(basename ${TEXFILE} ".tex")

function cleanup {
    cd ${STARTDIR}
    echo "Results are in ${TEXDIR}."
}
trap cleanup EXIT

cd ${TEXDIR}

latexmk -pdflatex="xelatex -shell-escape %O %S" -pdf -dvi- -ps- ${COMPILEFILE}
