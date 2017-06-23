#!/bin/bash
# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0

REALPATH=$(which realpath)
DIRNAME=$(which dirname)
DOCKER=$(which docker)

SCRIPT_PATH=$(${DIRNAME} $(${REALPATH} $0))
CONTAINER="uwsgi-laano-uploader"
CONTAINER_NAME="laano-uploader"
CONTAINER_HOME=$(${REALPATH} ${SCRIPT_PATH}/../uploader)

case "$1" in
    run)
        ${DOCKER} run -d --restart unless-stopped --name=${CONTAINER_NAME} \
            -v ${CONTAINER_HOME}:/opt ${CONTAINER}
        ;;
    start)
        ${DOCKER} start ${CONTAINER_NAME}
        ;;
    stop)
        ${DOCKER} stop ${CONTAINER_NAME}
        ;;
    restart)
        ${DOCKER} stop ${CONTAINER_NAME}
        ${DOCKER} start ${CONTAINER_NAME}
        ;;
    logs)
        ${DOCKER} logs --follow ${CONTAINER_NAME}
        ;;
    status)
        RUNNING=$(docker inspect --format="{{.State.Running}}" ${CONTAINER_NAME} 2> /dev/null)
        if [ $? -eq 1 ]; then
            echo "${CONTAINER_NAME}: does not exist"
        elif [ "${RUNNING}" == "false" ]; then
            echo "${CONTAINER_NAME}: is stopped"
        else
            RESTARTING=$(docker inspect --format="{{.State.Restarting}}" ${CONTAINER_NAME} 2> /dev/null)
            if [ "${RESTARTING}" == "true" ]; then
                echo "${CONTAINER_NAME}: is restarting"
            else
                echo "${CONTAINER_NAME}: is running"
            fi
        fi
        ;;
    *)
        echo "Usage: $0 (run|start|stop|restart|logs|status)"
        exit 2
        ;;
esac
