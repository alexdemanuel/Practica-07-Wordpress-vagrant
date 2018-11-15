# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/bionic64"

    # Load Balancer
    config.vm.define "balancer" do |app|
      app.vm.hostname = "balanacer"
      app.vm.network "private_network", ip: "192.168.33.10"
      app.vm.provision "shell", path: "provision/provision-for-balancer.sh"
    end
     
    # Apache HTTP Server
    config.vm.define "web1" do |app|
      app.vm.hostname = "web1"
      app.vm.network "private_network", ip: "192.168.33.11"
      app.vm.provision "shell", path: "provision/provision-for-nfs-server.sh"
    end

    # Apache HTTP Server 2
      config.vm.define "web2" do |app|
        app.vm.hostname = "web2"
        app.vm.network "private_network", ip: "192.168.33.12"
        app.vm.provision "shell", path: "provision/provision-for-nfs-client.sh"
      end
  
    # MySQL Server
    config.vm.define "db" do |app|
      app.vm.hostname = "db"
      app.vm.network "private_network", ip: "192.168.33.13"
      app.vm.provision "shell", path: "provision/provision-for-mysql.sh"
    end

end
