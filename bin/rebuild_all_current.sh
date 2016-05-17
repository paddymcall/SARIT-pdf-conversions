#!/usr/bin/env bash

# see http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

BASEDIR=$(realpath $(dirname ${0})"/../")
CONVERSIONSCRIPT=$(realpath ${BASEDIR}"/bin/convert_sarit_to_tex.sh")
COMPILETEXSCRIPT=$(realpath ${BASEDIR}"/bin/compile_xetex.sh")

STARTDIR=$(pwd)
OUTDIR=$(realpath $BASEDIR"/TeX/")
XMLDIR=$(realpath $BASEDIR"/SARIT-corpus/")

function cleanup {
    cd $STARTDIR
    echo "Results are in ${OUTDIR}."
}
trap cleanup EXIT


find $OUTDIR -type f -iname "*.tex"  -printf '%f\n' | \
    sed 's/tex$/xml/' | \
    parallel --jobs 1 $CONVERSIONSCRIPT $XMLDIR/{} $OUTDIR


cd $OUTDIR

ls *tex | \
    parallel --jobs -1 ${COMPILETEXSCRIPT} {} 

