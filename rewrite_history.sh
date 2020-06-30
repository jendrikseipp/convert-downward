#!/bin/sh

if [ $# -ne 2 ]; then
  echo "Invalid arguments. Use: $0 SRC DST"
  exit 1
fi
BASE=$(dirname $(readlink -f $0))
hg \
 --config extensions.renaming_mercurial_source=$BASE/renaming_mercurial_source.py \
 convert $1 $2 \
 --source-type renaming_mercurial_source \
 --authormap "$BASE/data/downward_authormap.txt" \
 --filemap "$BASE/data/downward_filemap.txt" \
 --splicemap "$BASE/data/downward_splicemap.txt" \
 --branchmap "$BASE/data/downward_branchmap.txt"

cd $2
hg strip "branch(issue323)" --nobackup
hg strip "branch(ipc-2011-fixes)" --nobackup
