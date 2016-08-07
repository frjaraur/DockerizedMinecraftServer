#!/bin/bash

#

ACTION="$(echo $1|tr '[A-Z]' '[a-z]')"

VERSION=${VERSION:=1.10}

MODS=${MODS:=false}

USERID=${USERID:=3333}

GROUPID=${GROUPID:=USERID}

BASEDIR="/BASE"

GAMEDIR=${GAMEDIR:=/MINECRAFT}

# COLORS
RED='\033[0;31m' # Red
BLUE='\033[0;34m' # Blue
GREEN='\033[0;32m' # Green
CYAN='\033[0;36m' # Cyan
YELL='\033[1;33m' # Cyan
NC='\033[0m' # No Color

Help(){
	printf "${YELL}Use enviroment variables to change server version and mod mode:${NC}\n"
  printf "${RED}VERSION${YELL} --> ${RED}-e\"VERSION=1.10\"${YELL} (default)${NC}\n"
  printf "${RED}MODS${YELL} --> ${RED}-e\"MODS=true\"${YELL} (default MODS=false)${NC}\n"
  printf "${RED}USERID${YELL} --> ${RED}-e\"USERID=3333\"${YELL} (default)${NC}\n"
  printf "${RED}GROUPID${YELL} --> ${RED}-e\"GROUPID=3333\"${YELL} (default)${NC}\n"
  printf "${RED}BASEDIR${YELL} Should be a volumen mapped on your host engine.${NC}\n"
  printf "\n${RED}*Use your userid and groupid if you want to take control of configuration files.${NC}\n"

}

ErrorMessage(){
	date="$(date +%Y/%m/%d-%H:%M:%S)"
	printf "${date} ${RED}ERROR: $* ${NC}\n"
	exit 1
}

InfoMessage(){
	date="$(date +%Y/%m/%d-%H:%M:%S)"
	printf "${date} ${CYAN}INFO: $* ${NC}\n"
}

OKMessage(){
	date="$(date +%Y/%m/%d-%H:%M:%S)"
	printf "${date} ${GREEN}OK: $* ${NC}\n"
}

Download(){
  wget -q -O minecraft_server.${VERSION}.jar https://s3.amazonaws.com/Minecraft.Download/versions/${VERSION}/minecraft_server.${VERSION}.jar
  [ $? -ne 0 ] && rm -f minecraft_server.${VERSION}.jar && ErrorMessage "Can not download 'minecraft_server.${VERSION}.jar'."
  OKMessage "Minecraft server 'minecraft_server.${VERSION}.jar' downloaded correctly."
}

CheckMods(){

  [ "${MODS}" = "false" ] && InfoMessage "Not using any mod on server" && return 0

  # forge-VERSION-
  [ ! -d forge ] && ErrorMessage "Forge directory does not exists."

  FORGE_VERSION="$(ls -1 forge/forge-${VERSION}-*.jar 2>/dev/null|tail -1)"

  [ ! -n "${FORGE_VERSION}" ] && ErrorMessage "Can not find a valid forge version for your 'minecraft_server.${VERSION}.jar'."

  # sed -e "s/ORIGEN/DESTINO/"
  FORGE_VERSION="$(echo ${FORGE_VERSION}|sed -e "s/forge\///g")"

  OKMessage "We will use '${FORGE_VERSION}' for 'minecraft_server.${VERSION}.jar'."

}

SetUpEnvironment(){

  MCSERVERDIR="${GAMEDIR}/MCSERVER_${VERSION}"

  [ ! -f ${MCSERVERDIR} ] && mkdir -p ${MCSERVERDIR} || ErrorMessage "Can not create server game dir '${MCSERVERDIR}'."

  if [ "${MODS}" = "false" ]
  then
    [ ! -f ${MCSERVERDIR}/minecraft_server.${VERSION}.jar ] \
    && cp -f ${BASEDIR}/minecraft_server.${VERSION}.jar ${MCSERVERDIR} #\
    #|| ErrorMessage "Can not copy 'minecraft_server.${VERSION}.jar' to server game dir '${MCSERVERDIR}'."
  else
    echo "SOURCE: [${BASEDIR}/forge/${FORGE_VERSION}] DEST: [${MCSERVERDIR}]"
    [ ! -f "${MCSERVERDIR}/${FORGE_VERSION}" ] \
    && cp -f ${BASEDIR}/forge/${FORGE_VERSION} ${MCSERVERDIR} # \
    #ErrorMessage "Can not copy 'forge/${FORGE_VERSION}' to server game dir '${MCSERVERDIR}'."

		### Added for RaspberryJamMod.jar
		#
		# Good Job !!! You Made my son learn to code ;P
		#
		if [ -f ${MCSERVERDIR}/mods/RaspberryJamMod.jar -o -f ${MCSERVERDIR}/mods/${VERSION}/RaspberryJamMod.jar ]
		then
			[ ! $(which python)  ] && apt-get -qq update \
			&& LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends unzip python python3
			[ ! -d ${MCSERVERDIR}/mcpipy ] \
			&& wget -q -O ${MCSERVERDIR}/python3-scripts.zip "https://github.com/arpruss/raspberryjammod/raw/master/python3-scripts.zip" \
			&& unzip -qn ${MCSERVERDIR}/python3-scripts.zip -d ${MCSERVERDIR}
		fi


  fi

  # Accept eula
  echo "eula=true" > ${MCSERVERDIR}/eula.txt || ErrorMessage "Can not accept eula on '${MCSERVERDIR}'."

  # Install forge if it is not already installed
  FORGE_EXEC="$(echo ${FORGE_VERSION}|sed -e "s/-installer./-universal./g")"
  [ ! -f ${FORGE_EXEC} ] && cd ${MCSERVERDIR} && InfoMessage "Forge not found .... it will be installed" \
  && java -jar ${FORGE_VERSION} --installServer nogui

  chown -R ${USERID}:${GROUPID} ${MCSERVERDIR}
}

BackupWorld(){

  [ ! -d ${MCSERVERDIR}/world ] && InfoMessage "Does not exist any previous world, stating from scratch, no backup needed." \
  && return 0

  # Move previous backup
  [ -f ${MCSERVERDIR}/world.current.tar.bz ] && \
  mv ${MCSERVERDIR}/world.current.tar.bz ${MCSERVERDIR}/world.$(date -r ${MCSERVERDIR}/world.current.tar.bz +%Y%m%d%H%M).tar.bz

  # Purge old backups (max 5)


  # Create new backup
  [ -d ${MCSERVERDIR}/world ] && gosu ${USERID} tar -jcf ${MCSERVERDIR}/world.current.tar.bz ${MCSERVERDIR}/world \
  || ErrorMessage "Can not create '${MCSERVERDIR}/world.current.tar.bz'."

}





case ${ACTION} in
  start)
    InfoMessage "VERSION=${VERSION}"
    InfoMessage "MODS=${MODS}"
    InfoMessage "USERID=${USERID}"
    InfoMessage "BASEDIR=${BASEDIR}"
    InfoMessage "GAMEDIR=${GAMEDIR}"

    [ ! -f "minecraft_server.${VERSION}.jar" ] && Download

    CheckMods

    SetUpEnvironment

    BackupWorld

    cd ${MCSERVERDIR}

    # Stand Alone or Modded server
    if [ "${MODS}" = "false" ]
    then
      gosu ${USERID} java -Dfml.queryResult=confirm -Xms2048M -Xmx2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing \
      -XX:ParallelGCThreads=2 -XX:+AggressiveOpts -jar minecraft_server.${VERSION}.jar nogui

      [ $? -ne 0 ] && ErrorMessage "Can not execute correctly 'minecraft_server.${VERSION}.jar' :| or have you used Ctr+C to exit server :O ??."

    else

      gosu ${USERID} java -Dfml.queryResult=confirm -Xms2048M -Xmx2048M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSIncrementalPacing \
      -XX:ParallelGCThreads=2 -XX:+AggressiveOpts -jar ${FORGE_EXEC} nogui

      [ $? -ne 0 ] && ErrorMessage "Can not execute correctly '${FORGE_EXEC}' :| ."

    fi
  ;;

  stop)
    pkill java || ErrorMessage "Can not stop minecraft server :| ."
    OKMessage "Minecraft server terminated...."

  ;;

  help)
    Help

  ;;

  *)
    OKMessage "EXECUTING \"$@\""
    exec "$@"

  ;;
esac
