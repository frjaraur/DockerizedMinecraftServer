# DockerizedMinecraftServer
Dockerized Minecraft Server

- Customize server.properties as needed

- Build Container Image

	docker build -t mcserver:1.9 .

- Run a new container image mapping volumes and ports as needed
	
	docker run --name mc19 [-v /YOUR_DATA_PATH:/SERVER] [-p 25565:YOUR_OWN_PORT] [-d] mcserver:1.9

- You can customize default port (not really needed for exporting your container's service) and motd for server.

	docker run --name mc19 [-v /YOUR_DATA_PATH:/SERVER] [-p 25565:YOUR_OWN_PORT] [-d] mcserver:1.9 start YOUR_OWN_PORT MOTD_MESSAGE

- Minecraft Server Version is managed by Dockerfile variable, you can update your server base image changing that value.



