# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  number_of_instances = 4
  (1..number_of_instances).each do |instance_number|
    config.vm.define "node#{instance_number}" do |host|
      host.vm.box = "ubuntu/xenial64"
      host.vm.network "private_network", ip: "192.168.33.11#{instance_number}"
      host.vm.hostname = "node#{instance_number}"

      host.vm.provider "virtualbox" do |v|
        v.memory = 1600
        v.cpus = 2
      end


      host.vm.provision "shell", inline: <<-SHELL
            curl -fsSL https://get.docker.com/ | sh
            sudo usermod -aG docker ubuntu

            sudo docker run \
              --volume=/:/rootfs:ro \
              --volume=/var/run:/var/run:rw \
              --volume=/sys:/sys:ro \
              --volume=/var/lib/docker/:/var/lib/docker:ro \
              --volume=/dev/disk/:/dev/disk:ro \
              --publish=9000:8080 \
              --detach=true \
              --name=cadvisor \
              --restart=always \
              google/cadvisor:latest
        SHELL

    if instance_number == 1
        # First Instance will be configured as swarm master
        host.vm.provision "shell", inline: <<-SHELL

            docker swarm init --advertise-addr 192.168.33.111
            sleep 5
            docker swarm join-token --quiet worker >/vagrant/workertoken.tmp
            docker swarm join-token --quiet manager >/vagrant/managertoken.tmp

            echo "Worker-Token:"
            cat /vagrant/workertoken.tmp

            echo "Start Swarm visualizer"
            nohup docker service create --name=viz --publish=8080:8080/tcp --constraint=node.role==manager --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock dockersamples/visualizer &

            echo "Start HiveMQ Cluster..."
            docker network create --driver overlay hivemqcluster
            nohup docker service create --name clusterdb --network hivemqcluster -p 5432:5432 -e POSTGRES_PASSWORD=cluster -e POSTGRES_USER=cluster -e POSTGRES_DB=cluster postgres:latest &
            nohup docker service create --name hivemq --network hivemqcluster -p 1883:1883 --replicas=2 --reserve-memory=200M --limit-memory=400M --constraint=node.role==worker -e HIVEMQ_CLUSTER_JDBC_URL=jdbc:postgresql://clusterdb:5432/cluster -e HIVEMQ_CLUSTER_JDBC_USER=cluster -e HIVEMQ_CLUSTER_JDBC_PASSWORD=cluster peez/hivemq:latest &
            #nohup docker service create --name nginx -p 8081:80 --reserve-memory=5M --limit-memory=10M --replicas=1 --constraint=node.role==worker nginx &

            #nohup docker service create --name innerservice --network hivemqcluster --reserve-memory=8M --limit-memory=20M --replicas=1 --constraint=node.role==worker peez/innerservice &
            #nohup docker service create --name outerservice --network hivemqcluster -p 8000:80 --reserve-memory=8M --limit-memory=20M --replicas=1 --constraint=node.role==worker peez/outerservice &

        SHELL
    end

    if instance_number > 1
        # All other instances will join the warm master as workers
        host.vm.provision "shell", inline: <<-SHELL
            docker swarm join --token $(cat /vagrant/workertoken.tmp) 192.168.33.111:2377
        SHELL
    end

    end
  end
end