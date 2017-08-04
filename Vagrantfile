# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "homeland-dev"
  config.vm.network "private_network", ip: "192.168.56.88"
  config.vm.provision "shell", path: "bin/provision.sh", privileged: false

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "homeland-dev"
    vb.memory = "2048"
  end
end
