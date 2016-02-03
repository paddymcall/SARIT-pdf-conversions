#!/bin/bash

if [ -z "$1" ]
    then
    echo "You need to specify a file for conversion."
    exit 1
fi

oldifs=$IFS

IFS='
'
export IFS

INPUT=$1
OUTDIR="./TeX/"
OUTPUT=$OUTDIR`basename $1 .xml`.tex

echo "writing output to $OUTPUT."

saxonb-xslt -ext:on -xsl:./Stylesheets/profiles/sarit/latex/to.xsl -s:$INPUT \
	    -o:$OUTPUT
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

IFS=$oldifs
export IFS
