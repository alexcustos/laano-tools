# laano-tools
The tools for the LaaNo Android app: [https://github.com/alexcustos/linkasanote](https://github.com/alexcustos/linkasanote)

## Uploader
This tool allows to send Links and Notes items to the Nextcloud storage via WebDAV interface, than them can be synced to the devices.

The script is written in Python3 using Bottle micro web-framework. There are two options to start it:
1. One is to use the `bin/local-start.sh`. A virtual environmet will be build in the parent directory and the APP section of the `uploader/src/config.ini` file will be used to set up the web applicaton;
1. The other is to build a Docker image using `bin/docker-build.sh` than to run a container with the `bin/docker.sh run` command. In that case, the `uwsgi.socket` will be provided to the `uploader/run` directory. It can be used with Nginx. The example config is in the `uploader/conf/uploader.nginx.conf.example` file.

## License

    Copyright 2017-present The laano-tools Repository Contributors

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
