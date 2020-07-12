FROM ubuntu:bionic
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}
ENV RVN_DATA=/home/raven/.raven

RUN groupadd -g ${GROUP_ID} raven \
	&& useradd -u ${USER_ID} -g raven -s /bin/bash -m -d /ravn raven

RUN apt-get update -y

RUN apt-get upgrade -y

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get install -y dialog apt-utils git nano

RUN apt-get install -y --no-install-recommends \
        cron \
        gosu \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y

RUN apt-get install -y -q build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils default-jdk default-jre libgmp-dev

RUN apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

RUN apt-get install software-properties-common -y

RUN add-apt-repository ppa:bitcoin/bitcoin -y

RUN apt-get update -y

RUN apt-get install libdb4.8-dev libdb4.8++-dev -y

RUN apt-get install -y libminiupnpc-dev

RUN apt-get install -y libzmq3-dev

RUN cd /tmp && git clone https://github.com/RavenProject/Ravencoin.git && cd ./Ravencoin && git checkout tags/v4.2.1

RUN cd /tmp/Ravencoin && ./autogen.sh && ./configure --without-gui && make && make install

RUN rm -rf ./Ravencoin

EXPOSE 8766 8767

VOLUME ["/home/raven/.raven"]

COPY ./docker-entrypoint.sh /usr/local/bin/

RUN chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["ravend"]
