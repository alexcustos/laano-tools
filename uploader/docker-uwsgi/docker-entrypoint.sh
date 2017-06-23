#!/bin/bash
# Copyright (c) 2017 Aleksandr Borisenko
# Licensed under the Apache License, Version 2.0
set -e

# INIT
/bin/mkdir -p /opt/{logs,run,src}
/bin/chown huser:huser /opt/{logs,run,src}

# DEPLOY
if [ -f /opt/src/docker-deploy.sh ]; then
    /bin/bash /opt/src/docker-deploy.sh
fi

# UPDATE
if [ -f /opt/src/docker-update.sh ]; then
    /bin/bash /opt/src/docker-update.sh
    /bin/rm -f /opt/src/docker-update.sh
fi

exec "$@"
