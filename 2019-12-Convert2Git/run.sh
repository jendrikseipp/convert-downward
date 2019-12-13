#!/bin/bash

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Invalid arguments. Use: $0 SRC DST [REMOTE-GIT-ORIGIN]"
  exit 1
fi
if [ ! -d $1 ]; then
  echo "Source is not a directory: $1"
  exit 1
fi
if [ -e $2 ]; then
  echo "Destination exists: $2"
  exit 1
fi
SRC=`realpath $1`
DST=`realpath $2`

BASE=$(realpath $(dirname $(readlink -f $0)))
FAST_EXPORT_REPO=${FAST_EXPORT_REPO:-"$BASE/fast-export"}
if [ ! -d $FAST_EXPORT_REPO ]; then
    git clone https://github.com/frej/fast-export.git $FAST_EXPORT_REPO
    cd $FAST_EXPORT_REPO
    git checkout v180317
fi
FAST_EXPORT="$FAST_EXPORT_REPO/hg-fast-export.sh"
echo "fast-export location: $FAST_EXPORT"



mkdir -p $DST
cd $DST
git init
$FAST_EXPORT -r $SRC
git checkout

if [ $# -eq 3 ]; then
    git remote add origin $3
fi
