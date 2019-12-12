#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Invalid arguments. Use: $0 SRC DST"
  exit 1
fi
BASE=`dirname $0`
hg convert $1 $2 --authormap "$BASE/downward_authormap.txt" --filemap "$BASE/downward_filemap.txt"

