help:
	grep ":" Makefile|grep -v grep|grep -v "^[[:space:]]"|sed -e"s/\://"

rebuild:
	docker build -t frjaraur/mcserver .

update:
	make rebuild
	docker login
	docker push frjaraur/mcserver

run189moded:
	docker rm -fv mc189 || echo
	docker run -d --name mc189 --net=host -ti -e MODS=true -e VERSION=1.8.9 -e USERID=1000 -e GROUPID=1000 -v /home/zero/MINECRAFT:/MINECRAFT frjaraur/mcserver start
	docker logs -f mc189
