# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "homeland-dev"
  # For Android/iOS app dev
  config.vm.network "public_network"
  config.vm.provision "shell", path: "bin/provision.sh", privileged: false

  config.vm.provider "virtualbox" do |vb|
    vb.name   = "homeland-dev"
    vb.memory = "2048"
  end
end
