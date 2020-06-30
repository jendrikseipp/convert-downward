#!/bin/bash

#set -ex

if ! command -v python3 > /dev/null; then
    echo 'Missing requirement: python3.5+'
    exit
fi

if [[ `python3 -c "import sys; print(sys.version_info < (3,5))"` = "True" ]];then
    echo "Missing requirement: python3.5+"
fi

BASE=$(realpath $(dirname $(readlink -f $0)))
VIRTUALENV=${VIRTUALENV:-"${BASE}/py3-env"}
FAST_EXPORT_REPO=${FAST_EXPORT_REPO:-"${BASE}/fast-export"}
CONVERT="${BASE}/convert.py"

MERCURIAL_VERSION="mercurial==5.2"
FAST_EXPORT_VERSION="v200213-23-g44c50d0"

echo "Setup python virtual environment"
if [[ ! -d ${VIRTUALENV} ]]; then
    python3 -m venv ${VIRTUALENV}
    source "$VIRTUALENV/bin/activate"
    pip install ${MERCURIAL_VERSION}
    echo `hg --version | grep "version"`
else
    if [[ `pip freeze | grep "mercurial"` != ${MERCURIAL_VERSION} ]]; then
        echo "Invalid requirement: should be ${MERCURIAL_VERSION}"
        exit
    fi
fi

echo "Setup fast-export"
if [[ ! -d ${FAST_EXPORT_REPO} ]]; then
    git clone https://github.com/frej/fast-export.git ${FAST_EXPORT_REPO}
    cd ${FAST_EXPORT_REPO}
else
    cd ${FAST_EXPORT_REPO}
    # TODO: Check if ${FAST_EXPORT_VERSION} exists already, then skip pull
    # TODO: with set -ex pull fails. Fix that
    git pull
fi
git checkout ${FAST_EXPORT_VERSION}
cd ..

FAST_EXPORT_REPO=${FAST_EXPORT_REPO} python3 ${CONVERT} $@
