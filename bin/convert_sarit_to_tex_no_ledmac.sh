#!/usr/bin/env bash

CONV=$(dirname "${0}")/convert_sarit_to_tex.sh

bash "$CONV" "$@" "ledmac=false"

