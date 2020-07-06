FROM debian:buster

ARG VERSION
ARG VERSION_BUILD
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

RUN groupadd -g ${GROUP_ID} raven \
      && useradd -u ${USER_ID} -g raven -s /bin/bash -m -d /raven raven

RUN apt-get update && apt-get -y upgrade && apt-get install -y wget ca-certificates gpg && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY checksum.sha256 /root
# Install required system packages
RUN apt-get update && apt-get install -y \
    automake \
    bsdmainutils \
    curl \
    g++ \
    libboost-all-dev \
    libevent-dev \
    libssl-dev \
    libtool \
    libzmq3-dev \
    make \
    pkg-config \
    zlib1g-dev

# Install minizip from source (unavailable from apt on Ubuntu 14.04)
RUN curl -L https://www.zlib.net/zlib-1.2.11.tar.gz | tar -xz -C /tmp && \
    cd /tmp/zlib-1.2.11/contrib/minizip && \
    autoreconf -fi && \
    ./configure --enable-shared=no --with-pic && \
    make -j$(nproc) install && \
    cd / && rm -rf /tmp/zlib-1.2.11

# Install zmq from source (outdated version from apt on Ubuntu 14.04)
RUN curl -L https://github.com/zeromq/libzmq/releases/download/v4.3.1/zeromq-4.3.1.tar.gz | tar -xz -C /tmp && \
    cd /tmp/zeromq-4.3.1/ && ./configure --disable-shared --without-libsodium --with-pic && \
    make -j$(nproc) install && \
    cd / && rm -rf /tmp/zeromq-4.3.1/


RUN set -x && \
      cd /root && \
  wget -q https://github.com/RavenProject/Ravencoin/releases/download/v${VERSION_BUILD}/raven-${VERSION}-x86_64-linux-gnu.tar.gz && \
      cat checksum.sha256 | grep ${VERSION} | sha256sum -c  && \
  tar xvf raven-${VERSION}-x86_64-linux-gnu.tar.gz && \
  cd raven-${VERSION} && \
  mv bin/* /usr/bin/ && \
  mv lib/* /usr/bin/ && \
  mv include/* /usr/bin/ && \
  mv share/* /usr/bin/ && \
  cd /root && \
  rm -Rf raven-${VERSION} raven-${VERSION}-x86_64-linux-gnu.tar.gz

ENV GOSU_VERSION 1.7
RUN set -x \
      && apt-get install -y --no-install-recommends \
              ca-certificates \
      && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
      && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
      && export GNUPGHOME="$(mktemp -d)" \
      && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
      && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
      && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
      && chmod +x /usr/local/bin/gosu \
      && gosu nobody true


VOLUME ["/raven"]
EXPOSE  8766 8767

WORKDIR /raven

COPY scripts/docker-entrypoint.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]
