#!/bin/bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Invalid arguments. Use: $0 SRC DST"
  exit 1
fi

if [[ ! -d "$1" ]]; then
  echo "Invalid argument. $1 has to be a directory."
  exit 1
fi

if [[ -e "$2" ]]; then
  echo "Invalid argument. $2 may not exist."
  exit 1
fi


BASE="$(dirname "$(readlink -f "$0")")"
SETUP_CLEANUP="${BASE}/setup-cleanup.sh"
VIRTUALENV="${BASE}/data/py3-env"

if ! /bin/bash "${SETUP_CLEANUP}"; then
  echo "Error during setup."
  exit 2
fi
source "$VIRTUALENV/bin/activate"

# Disable all extensions.
# (https://stackoverflow.com/questions/46612210/mercurial-disable-all-the-extensions-from-the-command-line)
HGRCPATH= hg \
 --config extensions.renaming_mercurial_source="${BASE}/renaming_mercurial_source.py" \
 --config extensions.hgext.convert= \
 --config format.sparse-revlog=0 \
 convert "$1" "$2" \
 --source-type renaming_mercurial_source \
 --authormap "${BASE}/data/downward_authormap.txt" \
 --filemap "${BASE}/data/downward_filemap.txt" \
 --splicemap "${BASE}/data/downward_splicemap.txt" \
 --branchmap "${BASE}/data/downward_branchmap.txt"

cd "$2"
hg --config extensions.strip= strip "branch(issue323)" --nobackup
hg --config extensions.strip= strip "branch(ipc-2011-fixes)" --nobackup
