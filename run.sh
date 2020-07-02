#!/bin/bash

set -exuo pipefail

MISSING_REQUIREMENTS=""

if ! command -v python3 > /dev/null; then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: python3.5+"
elif [[ `python3 -c "import sys; print(sys.version_info < (3,5))"` = "True" ]];then
        MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: python3.5+"
fi

if ! `python3 -c "import ensurepip" 2> /dev/null`; then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: \
ensurepip module missing for python3. For Debian/Ubuntu use \
'sudo apt install python3-venv'"
fi

if [[ `dpkg-query -f '${Package}\n' -W | grep "python3-dev"` == "" ]];then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: python3-dev"
fi

if ! command -v git > /dev/null; then
    MISSING_REQUIREMENTS="${MISSING_REQUIREMENTS}\nMissing requirement: git"
fi

if [[ ${MISSING_REQUIREMENTS} != "" ]]; then
    echo -e ${MISSING_REQUIREMENTS}
    exit 3
fi




BASE=$(realpath $(dirname $(readlink -f $0)))
DATA="${BASE}/data"
VIRTUALENV="${DATA}/py3-env"
FAST_EXPORT_REPO="${DATA}/fast-export"
CONVERT="${BASE}/convert.py"

MERCURIAL_VERSION="mercurial==5.2"
FAST_EXPORT_VERSION="v200213-23-g44c50d0"

echo "Setup python virtual environment"
if [[ ! -d ${VIRTUALENV} ]]; then
    python3 -m venv ${VIRTUALENV}
    source "$VIRTUALENV/bin/activate"
    pip install --upgrade pip wheel
    pip install ${MERCURIAL_VERSION}
    echo `hg --version | grep "version"`
else
    source "$VIRTUALENV/bin/activate"
fi

echo "Setup fast-export"
if [[ ! -d ${FAST_EXPORT_REPO} ]]; then
    git clone https://github.com/frej/fast-export.git ${FAST_EXPORT_REPO}
    git -C ${FAST_EXPORT_REPO} checkout ${FAST_EXPORT_VERSION}
fi
export FAST_EXPORT_REPO=${FAST_EXPORT_REPO}

python3 ${CONVERT} $@
