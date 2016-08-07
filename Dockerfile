FROM  ubuntu:trusty

MAINTAINER FRJARAUR "frjaraur@gmail.com"

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV GOSU_VERSION 1.9
RUN apt-get update -qq && \
 LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends software-properties-common \
 apt-utils openjdk-7-jre wget ca-certificates && rm -rf /var/lib/apt/lists/* \
 && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
 && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
 && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
 && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
 && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
 && chmod +x /usr/local/bin/gosu \
 && gosu nobody true \
 && apt-get purge -qq --auto-remove apt-utils \
 && apt-get -qq autoremove

ENV VERSION 1.10
ENV MODS false
ENV USERID 3333
ENV GROUPID ${USERID}
ENV BASEDIR /BASE
ENV GAMEDIR /MINECRAFT

RUN groupadd -r mcserver --gid=${GROUPID} && useradd -r -g mcserver --uid=${USERID} mcserver

WORKDIR /BASE

VOLUME /MINECRAFT

COPY forge forge

COPY mcserver.sh /mcserver.sh

ENTRYPOINT ["/mcserver.sh"]

EXPOSE 25565

CMD ["help"]
