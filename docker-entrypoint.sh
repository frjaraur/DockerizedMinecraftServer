#!/bin/bash
set -e

ACTION=$1

PORT=$2

MOTD=$3

SERVER_PORT=25565

SERVER_MOTD="Dockerized Minecraft Server"

echo "Prepare Default Environment using files from host SERVER directory."

cd $MSERVER

for resource in minecraft_server.jar server.properties server-icon.png
do
	[ ! -e ${MSERVER}/${resource} ] && cp -p ${TMPDATA}/${resource} ${MSERVER}/${resource}
done

[ -n "$PORT" ] && SERVER_PORT=$PORT 
sed -i "s/^server-port.*$/server-port\=${SERVER_PORT}/" ${MSERVER}/server.properties

[ -n "$MOTD" ] && SERVER_MOTD=$MOTD 
sed -i "s/^motd.*$/motd=${SERVER_MOTD}/" ${MSERVER}/server.properties

#Change Eula

echo "Accept eula even it was already done."

echo "eula=true" > ${MSERVER}/eula.txt

#Always change data to mserver user/group

chown -R mserver:mserver ${MSERVER}

case $ACTION in
	
	start)
		echo "Starting server on port defined in server.properties, if you want a new port, you must build a new container and changed expose port"
		echo "DOCKER PORT is [${SERVER_PORT}]"
		echo "If you want to use this service on internet, don't forget to change your routing/portnat in your infrastructure."
		gosu mserver java -Dfml.queryResult=confirm -Xms2048M -Xmx2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing \
		-XX:ParallelGCThreads=2 -XX:+AggressiveOpts -jar minecraft_server.jar nogui
	;;

	*)
	
		exec "bash"
	;;
esac

