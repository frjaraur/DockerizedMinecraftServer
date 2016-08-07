# Dockerized Minecraft Server

docker run --rm -ti frjaraur/mcserver

Use enviroment variables to change server version and mod mode:
- VERSION --> -e "VERSION=1.10" (default)
- MODS --> -e "MODS=true" (default MODS=false, forge installation for 1.10.2, 1.8.9 and 1.7.10 are included in BASE/forge dir)
- USERID --> -e "USERID=3333" (default)
- GROUPID --> -e "GROUPID=3333" (default)
- GAMEDIR Should be a volumen mapped on your host engine, where you will store your server data.

* Use your userid and groupid if you want to take control of configuration files.

* Use --net=host or -p 25565:25565 -p (or any other external port of your choose, default minecraft server 25565 will be exposed).

docker run -d --name mc189 --net=host -ti -e MODS=true -e VERSION=1.8.9 -e USERID=1000 -e GROUPID=1000 -v _PATH_TO_YOUR_GAME_DIR_:/MINECRAFT frjaraur/mcserver start

Added support for 'Raspberry Jam Mod' if you put RaspberryJamMod.jar into your _PATH_TO_YOUR_GAME_DIR_/mods (or mod server version folder).
Docker container will download python example scripts from Git to start using this great mod.

https://github.com/arpruss/raspberryjammod
* RaspberryJamMod listening on port 4711 and Websocket server on 14711 are not exposed.

[arpruss](https://github.com/arpruss) Good Job !!! You Made my son learn to code ;P

I created this container for my son's game server :D, have fun :)

World's backup will be launched on every container start, purge process will be added when my son tell me what he really wants ;P
