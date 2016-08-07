# Dockerized Minecraft Server

docker run --rm -ti frjaraur/mcserver

Use enviroment variables to change server version and mod mode:
VERSION --> -e "VERSION=1.10" (default)
MODS --> -e "MODS=true" (default MODS=false)
USERID --> -e "USERID=3333" (default)
GROUPID --> -e "GROUPID=3333" (default)
BASEDIR Should be a volumen mapped on your host engine.

*Use your userid and groupid if you want to take control of configuration files.


docker run -d --name mc189 --net=host -ti -e MODS=true -e VERSION=1.8.9 -e USERID=1000 -e GROUPID=1000 -v _PATH_TO_YOUR_GAME_DIR_:/MINECRAFT frjaraur/mcserver start

Added support for 'Raspberry Jam Mod' if you put RaspberryJamMod.jar into your _PATH_TO_YOUR_GAME_DIR_/mods (or mod server version folder).
Docker container will download python example scripts from Git to start using this great mod.
https://github.com/arpruss/raspberryjammod
Good Job !!! You Made my son learn to code ;P

I created this container for my son's game server :D, have fun :)
