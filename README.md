UDP Communication
=================

This is the code for the UDP Communication chapter in the [Getting functional with Erlang](http://gettingfunctionalwitherlang.com/) book. The two files [docker-container.sh](https://github.com/gettingfunctionalwith/erlang-udp-communication/blob/master/docker-container.sh) and [docker.host.sh](https://github.com/gettingfunctionalwith/erlang-udp-communication/blob/master/docker-host.sh) that we build throughtout the chapter are both here for you to review. But this repository also contains all the files needed to instantiate a Vagrant managed VM build on top of VirtualBox and a Dockerfile that creates a Ubuntu image which can compile Erlang releases.

## Installation

For the whole setup to work we need VirtualBox, Vagrant and the Docker client installed, if you are running on a Linux based platform already you probably can just run the Docker client. I have atm only been able to test this on the MacOS platform.

### MacOS

When using Docker on MacOS you will need to run it in a Virtual Environment as Docker only runs on Linux based systems. Thankfully there is a rather simple way to achieve this using VirtualBox, Vagrant and the Docker Client.

Follow the steps described [here](http://docs.vagrantup.com/v2/installation/index.html) to install Vagrant and these steps [here](http://docs.docker.io/installation/mac/) to install docker on MacOS.

### Ubuntu

Because Docker runs natively on Linux based systems, setting it up on Ubuntu is rather easy. Follow the instructions [here](http://docs.docker.io/installation/ubuntulinux/).

## Vagrant (MacOS)

Once everything is installed we should build the Virtual machine that will host our Docker containers, we just run `make vagrant.up` which will setup the virtual machine using CoreOS. After this has finished you need to go in and execute a small command. Use `vagrant ssh` to SSH into the virtual machine. Once there you execute `sudo touch /etc/hosts` this is because we will run Docker with the option `--net=host` and this relies on there being a hosts file. CoreOS does not come with a hosts file and it will halt the Docker container. I expect this to be fixed in a later release of Docker. After this just exis the SSH session my typing `exit`.

Now we have a virtual machine running, you can easily stop it by typing `vagrant halt` and later start again my typing `make vagrant.up` note the only reason we use make here is so we don't forget the `--provision` option.

Note: Vagrant is configuring the virtual machine to have a static IP address of 192.168.1.50, if this is incompatible with your network then you should change the [Vagrantfile](https://github.com/gettingfunctionalwith/erlang-udp-communication/blob/master/Vagrantfile) and the [makefile](https://github.com/gettingfunctionalwith/erlang-udp-communication/blob/master/makefile) accordingly.

## Docker (MacOS & Ubuntu)

Make sure the virtual machine is running by typing `vagrant status` and then we will build our Docker image my typing `make docker.build`. This will download Ubuntu and all other software needed to build Erlang releases. Once it is done you can run `make docker.shell` to inspect the container. Inside you should see a folder /src/ where the project code will be. Once you are happy you can run `make docker.release` which will run the same as the previous command and additionally setup the `docker-container.sh` and `docker-host.sh` scripts to copy the created release back to the host machine.
