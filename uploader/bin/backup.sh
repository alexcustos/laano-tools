#!/bin/bash
# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0

REALPATH=$(which realpath)
DIRNAME=$(which dirname)
MKDIR=$(which mkdir)

SCRIPT_PATH=$(${DIRNAME} $(${REALPATH} $0))
BACKUP_DIR='backup'
CUR_DATE=`date +'%Y_%m_%d'`
BACKUP_NAME=$CUR_DATE.uploader.tar.gz

cd ${SCRIPT_PATH}/..
${MKDIR} -p "${BACKUP_DIR}"
tar --use-compress-program=pigz -cpf ${BACKUP_DIR}/${BACKUP_NAME} \
    --exclude=${BACKUP_DIR} \
    --exclude=uploader/src/.ropeproject \
    --exclude=uploader/src/session \
    --exclude=venv \
    .
