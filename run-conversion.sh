#!/bin/bash

set -euo pipefail

INTERMEDIATE_REPOSITORY="$1"
CONVERTED_REPOSITORY="$2"
shift 2

BASE="$(dirname "$(readlink -f "$0")")"
SETUP_CONVERSION="${BASE}/setup-conversion.sh"
CONVERT="${BASE}/convert.py"
VIRTUALENV="${BASE}/data/py3-env"

if ! /bin/bash "${SETUP_CONVERSION}"; then
  echo "Error during setup."
  exit 2
fi

source "$VIRTUALENV/bin/activate"

python3 "${CONVERT}" "$INTERMEDIATE_REPOSITORY" "$CONVERTED_REPOSITORY" $@
