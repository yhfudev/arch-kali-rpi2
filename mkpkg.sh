#!/bin/bash
#####################################################################
# makepkg.sh for PKGBUILD file
#
# This script will read the config/script from the PKGBUILD file
#
# Copyright 2015 Yunhui Fu
# License: GPL v3.0 or later
#####################################################################
my_getpath () {
  PARAM_DN="$1"
  shift
  #readlink -f
  DN="${PARAM_DN}"
  FN=
  if [ ! -d "${DN}" ]; then
    FN=$(basename "${DN}")
    DN=$(dirname "${DN}")
  fi
  cd "${DN}" > /dev/null 2>&1
  DN=$(pwd)
  cd - > /dev/null 2>&1
  echo "${DN}/${FN}"
}
#DN_EXEC=`echo "$0" | ${EXEC_AWK} -F/ '{b=$1; for (i=2; i < NF; i ++) {b=b "/" $(i)}; print b}'`
DN_EXEC=$(dirname $(my_getpath "$0") )
if [ ! "${DN_EXEC}" = "" ]; then
    DN_EXEC="$(my_getpath "${DN_EXEC}")/"
else
    DN_EXEC="${DN_EXEC}/"
fi

#####################################################################

if [ ! -f "PKGBUILD" ]; then
    echo "Error, not found file PKGBUILD"
    exit 1
fi

if [ ! -f "${DN_EXEC}/librepo.sh" ]; then
    echo "Error, not found file librepo.sh"
    exit 1
fi

. PKGBUILD

. ${DN_EXEC}/librepo.sh

#####################################################################
DN_ORIGIN=$(pwd)

down_sources

echo "[DBG] check version: $(pkgver)"

checkout_sources

# call user's function
type prepare > /dev/null
if [ "$?" = "0" ]; then
    ${MYEXEC} cd "${DN_ORIGIN}"
    ${MYEXEC} prepare
fi

type build > /dev/null
if [ "$?" = "0" ]; then
    ${MYEXEC} cd "${DN_ORIGIN}"
    ${MYEXEC} build
fi

type package > /dev/null
if [ "$?" = "0" ]; then
    ${MYEXEC} cd "${DN_ORIGIN}"
    ${MYEXEC} package
    ${MYEXEC} makepkg_tarpkg
fi

${MYEXEC} cd "${DN_ORIGIN}"
