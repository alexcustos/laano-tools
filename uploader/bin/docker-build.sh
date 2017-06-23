#!/bin/bash
# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0

ID=$(which id)
GETENT=$(which getent)
WHOAMI=$(which whoami)
CUT=$(which cut)
REALPATH=$(which realpath)
DIRNAME=$(which dirname)

DEFAULT_WSGROUP=nginx
DEFAULT_HUSER=$(${WHOAMI})
SCRIPT_PATH=$(${DIRNAME} $(${REALPATH} $0))

HUSER=${HUSER:-${DEFAULT_HUSER}}
WSGROUP=${WSGROUP:-${DEFAULT_WSGROUP}}

HUID=$(${ID} ${HUSER} -u)
HGID=$(${ID} ${HUSER} -g)
WSGID=$(${GETENT} group ${WSGROUP} | ${CUT} -d: -f3) 2> /dev/null

if [ -z "${HUID}" ] || [ -z "${HGID}" ] || [ -z "${WSGID}" ]; then
    echo "ERROR: The specified User and web server Group must be presented on the Host."
    exit 1
fi

cd ${SCRIPT_PATH}/..
docker build -t uwsgi-laano-uploader docker-uwsgi \
    --build-arg HUID=${HUID} --build-arg HGID=${HGID} \
    --build-arg WSGID=${WSGID}
