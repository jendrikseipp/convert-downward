#!/bin/bash

set -euo pipefail

if [[ $# -le 2 ]]; then
  echo "Invalid arguments. Use: $0 [SRC REPOSITORY] [CLEANED REPOSITORY] \
[CONVERTED REPOSITORY] (--redirect-fast-export-stderr FILE)"
  exit 1
fi

if [[ ! -d $1 ]]; then
  echo "Invalid argument. $1 has to be a directory."
  exit 1
fi

if [[ -e $2 ]]; then
  echo "Invalid argument. $2 may not exist."
  exit 1
fi

if [[ -e $3 ]]; then
  echo "Invalid argument. $3 may not exist."
  exit 1
fi



BASE=$(realpath $(dirname $(readlink -f $0)))
SETUP_CLEANUP="${BASE}/setup-cleanup.sh"
SETUP_CONVERSION="${BASE}/setup-conversion.sh"
RUN_CLEANUP="${BASE}/run-cleanup.sh"
RUN_CONVERSION="${BASE}/run-conversion.sh"

if ! /bin/bash ${SETUP_CLEANUP}; then
  echo "Error during the setup for the cleaning script."
  exit 2
fi

if ! /bin/bash ${SETUP_CONVERSION}; then
  echo "Error during the setup for the conversion script."
  exit 2
fi

if ! ${RUN_CLEANUP} $1 $2; then
  echo "Cleanup failed."
  exit 2
fi

if ! ${RUN_CONVERSION} ${@:2}; then
  echo "Conversion failed."
  exit 2
fi

