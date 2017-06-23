#!/bin/bash
# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0
set -e

DEPS="gcc libbz2-dev libcurl4-openssl-dev libc6-dev libssl-dev"

if [ -f ${VENV_PATH}/.venvempty ]; then
    rm -f ${VENV_PATH}/.venvempty

    apt-get update
    apt-get install -y --no-install-recommends ${DEPS}
    rm -rf /var/lib/apt/lists/*

    if [ -f /opt/src/requirements.txt ]; then
        ${VENV_PATH}/bin/pip install --no-cache-dir -r /opt/src/requirements.txt
    fi

    apt-get purge -y --auto-remove ${DEPS}
    find /usr/local -depth \( \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \) -exec rm -rf '{}' +
fi
