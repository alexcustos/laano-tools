#!/bin/bash
# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0

PYVENV=$(which pyvenv)
REALPATH=$(which realpath)
DIRNAME=$(which dirname)

SCRIPT_PATH=$(${DIRNAME} $(${REALPATH} $0))
VENV_PATH=$(${REALPATH} ${SCRIPT_PATH}/../venv)

cd ${SCRIPT_PATH}/..
if [ ! -d "${VENV_PATH}" ]; then
    ${PYVENV} ${VENV_PATH}
    ${VENV_PATH}/bin/pip install --upgrade pip
    ${VENV_PATH}/bin/pip install -r ./uploader/src/requirements.txt
fi

cd ./uploader/src
if [ ! -f config.ini ]; then
    cp ./config.ini.example ./config.ini
    echo -e "\nWARNING: the example configuration has been used. Please check the config.ini file."
fi

${VENV_PATH}/bin/python ./uploader.py
