# -*- mode: ruby -*-
# vi: set ft=ruby :

# ================================================== #
# If your local network has a different              #
# configuration and cannot work with the 192.168 IP  #
# range then there are two places you need to change #
# this, in the Vagrantfile (this one) and in the     #
# makefile.                                          #
# ================================================== #
IP_FOR_VM = '192.168.1.50'


require 'fileutils'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
CLOUD_CONFIG_PATH = "./user-data"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "coreos-alpha"
  config.vm.box_version = ">= 308.0.1"
  config.vm.box_url = "http://storage.core-os.net/coreos/amd64-usr/alpha/coreos_production_vagrant.json"

  config.vm.hostname = "simple-erlang-release"
  # config.vm.network "public_network", type: 'dhcp', :netmask => '255.255.255.0', :bridge => 'en0: Wi-Fi (AirPort)'
  config.vm.network "public_network", ip: "#{IP_FOR_VM}", :netmask => '255.255.255.0', :bridge => 'en0: Wi-Fi (AirPort)'

  config.vm.network "forwarded_port", guest: 4243, host: 4243, auto_correct: true
  config.vm.network "forwarded_port", guest: 6667, host: 6667, auto_correct: true, protocol: 'udp'

  if File.exist?(CLOUD_CONFIG_PATH)
    config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
    config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
  end

end
