# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  number_of_instances = 1
  (1..number_of_instances).each do |instance_number|
    config.vm.define "node#{instance_number}" do |host|
      host.vm.box = "ubuntu/trusty64"
      host.vm.network "private_network", ip: "192.168.33.11#{instance_number}"
      host.vm.hostname = "node#{instance_number}"

      host.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
      end


      config.vm.provision "shell", inline: <<-SHELL
       # install docker 1.12 beta
       curl -fsSL https://test.docker.com/ | sh
       sudo usermod -aG docker vagrant
     SHELL

    end
  end
end