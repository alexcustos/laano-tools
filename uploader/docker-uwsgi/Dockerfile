FROM debian:jessie

# The Host user which have to manage logs and other generated content
ARG HUID
ARG HGID
# The group of the web server which must have access to UWSGI socket
ARG WSGID

ENV LANG=C.UTF-8 \
    PYTHON_VERSION=3.6.1 \
    DEBIAN_FRONTEND=noninteractive \
    VENV_PATH=/var/venv

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
        curl wget bzr git mercurial openssh-client subversion procps \
        bzip2 file imagemagick xz-utils tcl tk \
    && apt-get purge -y python.* \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && apt-get update \
    && buildDeps='dpkg-dev tcl-dev tk-dev \
        autoconf automake g++ gcc libtool libbz2-dev libcurl4-openssl-dev libc6-dev libssl-dev \
        libdb-dev libevent-dev libffi-dev libgdbm-dev libgeoip-dev \
        libglib2.0-dev libjpeg-dev libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev \
        libncurses-dev libpng-dev libpq-dev libreadline-dev libsqlite3-dev \
        libwebp-dev libxml2-dev libxslt-dev libyaml-dev make patch zlib1g-dev \
        libmysqlclient-dev' \
    && apt-get install -y --no-install-recommends $buildDeps \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
    && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D \
    && gpg --batch --verify python.tar.xz.asc python.tar.xz \
    && rm -rf "$GNUPGHOME" python.tar.xz.asc \
    && mkdir -p /usr/src/python \
    && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
    && rm python.tar.xz \
    && cd /usr/src/python \
    && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
    && ./configure \
        --build="$gnuArch" \
        --enable-loadable-sqlite-extensions \
        --enable-shared \
        --with-system-expat \
        --with-system-ffi \
        --without-ensurepip \
    && make -j "$(nproc)" \
    && make install \
    && ldconfig \
    && cd /usr/local/bin \
    && ln -s idle3 idle \
    && ln -s pydoc3 pydoc \
    && ln -s python3 python \
    && ln -s python3-config python-config \
    \
    && groupadd --gid $HGID huser \
    && groupadd --gid $WSGID --non-unique wsgroup \
    && useradd -M --shell /sbin/nologin --home /opt --uid $HUID --gid huser huser \
    && usermod -a -G $WSGID huser \
    && chown -R huser:huser /opt \
    && wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
    && python get-pip.py --disable-pip-version-check --no-cache-dir \
    && rm -f get-pip.py \
    && pip install --no-cache-dir uwsgi \
    && /usr/local/bin/pyvenv ${VENV_PATH} \
    && ${VENV_PATH}/bin/pip install --upgrade pip \
    && /usr/local/bin/pip uninstall -y pip \
    && touch ${VENV_PATH}/.venvempty \
    && find ${VENV_PATH} -depth \( \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \) -exec rm -rf '{}' + \
    \
    && apt-get purge -y --auto-remove $buildDeps \
    && find /usr/local -depth \( \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \) -exec rm -rf '{}' + \
    && rm -rf /usr/src/python

WORKDIR /opt/src

VOLUME ["/var/venv"]

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/local/bin/uwsgi", "--ini", "/opt/conf/uwsgi.ini"]
