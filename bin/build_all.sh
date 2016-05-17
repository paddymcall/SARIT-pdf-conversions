#!/usr/bin/env bash

# see http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

BASEDIR=$(realpath $(dirname ${0})"/../")
CONVERSIONSCRIPT=$(realpath ${BASEDIR}"/bin/convert_sarit_to_tex.sh")
COMPILETEXSCRIPT=$(realpath ${BASEDIR}"/bin/compile_xetex.sh")

CORPUS=${1:-}

if [ -z "${CORPUS}" ]
    then
    echo "Please specify name of corpus file (usually SARIT-corpus/saritcorpus.xml)."
    exit 1
fi

STARTDIR=$(pwd)
CORPUS=$(realpath ${CORPUS})
XDIR=$(dirname ${CORPUS})
OUTDIR=$(mktemp --tmpdir -d "pdf-conv-XXXX")

function cleanup {
    cd $STARTDIR
    echo "Results are in ${OUTDIR}."
}
trap cleanup EXIT

cd $XDIR

xmlstarlet sel -N xi='http://www.w3.org/2001/XInclude' -t -v '//xi:include/@href'  ${CORPUS} | \
    parallel --jobs -1 ${CONVERSIONSCRIPT} {} ${OUTDIR}


cd ${OUTDIR}

ls *tex | parallel --jobs -1 ${COMPILETEXSCRIPT} {} 


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

