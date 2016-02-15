#!/usr/bin/env bash

set -o errexit # exit on error 
set -o nounset # don't allow uninitalized vars

BASEDIR=$(dirname ${0})"/.."
XMLFILE=${1:-}
OUTDIR=${2:-}
STYLESHEET=$(realpath ${BASEDIR}/"./Stylesheets/profiles/sarit/latex/to.xsl")

if [ -z "${XMLFILE}" ]; then
    echo "You need to specify a file for conversion."
    exit 1
elif [ -f "${XMLFILE}" ]; then
    XMLFILE=`realpath $XMLFILE`
else
    echo "${XMLFILE} not found."
    exit 1
fi

if [ -z ${OUTDIR} ] && [ -d ${BASEDIR}/"TeX/" ]; then
    OUTDIR=$(realpath ${BASEDIR}"/TeX/")
    echo "OUTDIR is: ${OUTDIR}"
elif [ -d "${OUTDIR}" ]; then
    OUTDIR=$(realpath ${OUTDIR})
else
    echo "Target directory ${OUTDIR} does not exist."
    exit 1
fi

OUTPUT=${OUTDIR}/$(basename ${XMLFILE} .xml).tex

echo "Converting ${XMLFILE} to ${OUTPUT}."

saxonb-xslt -ext:on -xsl:${STYLESHEET} -s:${XMLFILE} -o:${OUTPUT} # \
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

