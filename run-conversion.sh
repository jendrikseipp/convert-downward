#!/bin/bash

set -euo pipefail

BASE=$(dirname $(readlink -f $0))
SETUP_CONVERSION="${BASE}/setup-conversion.sh"
CONVERT="${BASE}/convert.py"
VIRTUALENV="${BASE}/data/py3-env"

if ! /bin/bash ${SETUP_CONVERSION}; then
  echo "Error during setup."
  exit 2
fi

source "$VIRTUALENV/bin/activate"

python3 ${CONVERT} $@