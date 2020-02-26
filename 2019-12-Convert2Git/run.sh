#!/bin/bash

set -ex

# Verify correct inputs
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

# Setup paths
SRC=`realpath $1`
DST=`realpath -m $2`
BASE=$(realpath $(dirname $(readlink -f $0)))
CONVERT_HGIGNORE="${BASE}/convert_hgignore_to_gitignore.py"
MAPPING_HGIGNORE="${BASE}/ignore_map.txt"
FAST_EXPORT_REPO=${FAST_EXPORT_REPO:-"$BASE/fast-export"}

# Download Mercurial to Git conversion tool
if [ ! -d $FAST_EXPORT_REPO ]; then
    git clone https://github.com/frej/fast-export.git $FAST_EXPORT_REPO
    cd $FAST_EXPORT_REPO

    MERCURIAL_VERSION=`python -c "import re;print(re.match('.*version (\d+\.\d+\.\d+).*', '''$(hg --version)''',re.MULTILINE).group(1))"`
    REVISION="master"
    if [ "$MERCURIAL_VERSION" = "4.3.1" ]; then
        REVISION="v180317"
    fi
    ## with mercurial version 4.8.2, the revision 2ba5d774 works
    git checkout $REVISION
fi

FAST_EXPORT="$FAST_EXPORT_REPO/hg-fast-export.sh"
echo "fast-export location: $FAST_EXPORT"

# Convert Mercurial to Git
echo "REMARK: If the script fails, check whether your Mercurial version requires an older repository revision (see script)"
mkdir -p $DST
cd $DST
git init
$FAST_EXPORT -r $SRC
git checkout

# Convert .hgignore to .gitignore
BRANCHES=$(hg -R ${SRC} branches)
BRANCHES=`python3 -c "\
branches = '''$(hg -R ${SRC} branches)'''.split()
branches = [branch for branch in branches if branch != '(inactive)']
branches = ['master' if branch == 'default' else branch for branch in branches]
branches = [branch for no, branch in enumerate(branches) if no % 2 == 0]
print(' '.join(branch for branch in branches))"`
HGIGNORE="${DST}/.hgignore"
for BRANCH in $BRANCHES; do
  git checkout $BRANCH
  if [ -e $HGIGNORE ]; then
    python ${CONVERT_HGIGNORE} $HGIGNORE --ignoremap ${MAPPING_HGIGNORE} > ".gitignore"
    git add ".gitignore"
    git rm ".hgignore"
    git commit -m "Automatically converted .hgignore to .gitignore"
  fi
done


# Todo: Close branches in git, if possible

#Archive (maybe our new close) branch
#git tag archive/<branchname> <branchname>
#git branch -d <branchname>
#git checkout master
#
## Reopen branch
#git checkout -b new_branch_name archive/<branchname>


if [ $# -eq 3 ]; then
    git remote add origin $3
    git push --mirror
fi
