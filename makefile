
# ================================================== #
# If your local network has a different              #
# configuration and cannot work with the 192.168 IP  #
# range then there are two places you need to change #
# this, in the Vagrantfile and in the makefile (this #
# one).                                              #
# ================================================== #

YOUR_IP_STARTS_WITH=192
CONTAINER_NAME=simple-erlang-release


vagrant.help:
	@echo "\n\
Currently Vagrant is configured to create the VM on IP 192.168.1.50\n\
If your network configuration needs a differnt IP address then you \n\
can change this in the ./Vagrantfile. I tried setting it up using \n\
DHCP but could not get that working consistently\n\
\n\
After doing the first vagrant up you need to go into the VM using\n\
'vagrant ssh' and execute 'sudo touch /etc/hosts' because the rest\n\
depends on this file being there\n\n"

vagrant.up: vagrant.help
	vagrant up --provision

vagrant.reload: vagrant.help
	vagrant reload --provision


docker.host:
	@echo "export DOCKER_HOST=tcp://127.0.0.1:4243"

docker.build: docker.host
	docker build --rm -t ${CONTAINER_NAME} .

docker.shell: docker.host
	docker run --rm -ti --net=host --name ${CONTAINER_NAME} ${CONTAINER_NAME} /sbin/my_init -- bash -l

docker.release: docker.host docker.release.start_listner
	docker run --rm -ti --net=host --name ${CONTAINER_NAME} ${CONTAINER_NAME} /sbin/my_init -- ./docker-container.sh `ifconfig | grep inet | grep -v inet6 | grep ${YOUR_IP_STARTS_WITH} | awk '{print $$2}'`

docker.release.start_listner: docker.release.reset
	./docker-host.sh ${CONTAINER_NAME} /src/releases.tar.gz . &

docker.release.reset:
	rm -rf releases
	rm -rf *.tar.gz

docker.clean: docker.clean.containers docker.clean.none-images
	@echo "Clean all"
	docker rmi ${CONTAINER_NAME}:latest

docker.clean.containers:
	@echo "Clean stopped containers"
	docker rm `docker ps --no-trunc -a -q`

docker.clean.none-images:
	@echo "Clean <none> images"
	docker rmi `docker images | grep "^<none>" | awk "{print $3}"`
