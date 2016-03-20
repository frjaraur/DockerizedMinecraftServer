# Dockerized Minecraft Server
Dockerized Minecraft Server

- Customize server.properties as needed

- Build Container Image

	docker build -t mcserver:1.9 .

- Run a new container image mapping volumes and ports as needed
	
	docker run --name mc19 [-v /YOUR_DATA_PATH:/SERVER] -ti [-p 25565:YOUR_OWN_PORT] [-d] mcserver:1.9

- You can customize default port (not really needed for exporting your container's service) and motd for server.

	docker run --name mc19 [-v /YOUR_DATA_PATH:/SERVER] -ti [-p 25565:YOUR_OWN_PORT] [-d] mcserver:1.9 start YOUR_OWN_PORT MOTD_MESSAGE

- Minecraft Server Version is managed by Dockerfile variable, you can update your server base image changing that value.

- Attach to Minecraft Server:

 	docker attach mc19
 	
- Starting/Stopping server should be done using:

	docker stop/start mc19


I created this container for my son's game server :D, have fun :)
