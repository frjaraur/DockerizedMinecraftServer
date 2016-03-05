FROM  ubuntu:trusty

MAINTAINER FRJARAUR "frjaraur@gmail.com"

ENV MSERVER_VERSION "1.9"

RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

RUN apt-get update && \
 LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common apt-utils openjdk-7-jre wget 

ENV MSERVER /SERVER
ENV TMPDATA /DEFAULTS

RUN groupadd -r mserver --gid=2002 && useradd -r -g mserver --uid=2002 mserver

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
        && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
        && gpg --verify /usr/local/bin/gosu.asc \
        && rm /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu

WORKDIR $TMPDATA

RUN wget -O minecraft_server.jar https://s3.amazonaws.com/Minecraft.Download/versions/${MSERVER_VERSION}/minecraft_server.${MSERVER_VERSION}.jar

VOLUME "${MSERVER}"

COPY DEFAULTS/server.properties ${TMPDATA}/server.properties
COPY DEFAULTS/server-icon.png ${TMPDATA}/server-icon.png

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

#If you want to user this server on internet dont forget to change your routing/portnat infastructure.
#You can use -p INTERNAL_PORT:HOST_PORT when running this container when changing server.properties.
EXPOSE 25565:25565

CMD ["start","",""]
