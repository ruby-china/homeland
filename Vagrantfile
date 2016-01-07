# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/precise64"
  config.vm.hostname = "ruby-china-dev"
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.provision "shell", path: "bin/provision.sh", privileged: false

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
end
