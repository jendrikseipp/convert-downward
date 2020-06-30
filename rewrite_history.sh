#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Invalid arguments. Use: $0 SRC DST"
  exit 1
fi
BASE=$(dirname $(readlink -f $0))
hg convert $1 $2 \
 --authormap "$BASE/downward_authormap.txt" \
 --filemap "$BASE/downward_filemap.txt" \
 --splicemap "$BASE/downward_splicemap.txt" \
 --branchmap "$BASE/downward_branchmap.txt"

cd $2
hg strip "branch(issue323)" --nobackup
hg strip "branch(ipc-2011-fixes)" --nobackup
