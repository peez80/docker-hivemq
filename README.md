Professional HiveMQ Docker Image
================================

!! Image still under construction. Cluster not yet working and functionality (especially tls) not tested !!


Installing a license
--------------------
By default hivemq starts with a standard license for development purposes. 
To add your license file, mount it to _/opt/hivemq/license_:

    docker run -itd -v /local/path/license.lic:/opt/hivemq/license/license.lic:ro peez/hivemq

Persistence
-----------
Info about persistence here


Individual configuration
------------------------
This image comes with a default configuration. To define an own configuration, just mount the config.xml as you would with the license file:

    docker run -itd -v /local/path/to/config.xml:/opt/hivemq/conf/config_initial.xml:ro peez/hivemq
    
It's important to use config_initial.xml as filename, since the startscript (docker-entrypoint.sh) copies it to config.xml and makes some modifications (especially with cluster operation) 

Logging
-------
It is possible to mount a custom logback.xml to /opt/hivemq/conf

TLS
---
If you want to use TLS, you HAVE to mount the keystore and (if applicable) the truststore, since the provided truststores are some rookie-like created self signed trust stores:

    docker run -itd -v /local/path/to/keystore.jks:/opt/hivemq/cert/hivemq_keystore.jks:ro -v /local/path/to/truststore.jks:/opt/hivemq/cert/hivemq_truststore.jks peez/hivemq

Plugins
-------
To add plugins you could mount them to the plugin directory as described. For ease of use I recommend instead extending the Dockerfile.


Start on docker native cluster
------------------------------
Since 1.12 docker supports native swarm mode. Due to it's routing mesh it also provides automated loadbalancing from outside as well in between containers. We incorporate this to build a higly available
cluster without an explicit loadbalancer in front.

To achieve this we have to be a little bit flexible.
!! STILL NOT WORKING !!
Approach is - we create a overlay network in a given subnet. This subnet HAS to be a class-c network, so it must end with /24. Additionally we need to pass the network base as 
environment variable to the docker containers. See Example:

    docker swarm init
    docker network create --driver overlay --subnet 192.168.110.0/24 hivemq
    docker service create --name hivemq --network hivemq -p 1883:1883 -e SWARM_NETWORK_BASE=192.168.110 peez/hivemq

It's absolutely important to write exactly the first three segments of your class c network since there is not much logic inside the start scripts that create a "static"
cluster discovery from 192.168.110.1-254.

Often docker doesn't allocate the correct IP-address for advertising in the cluster. Therefore use --advertise-addr argument. Example:

    docker swarm init --advertise-addr 192.168.33.111:2377

Unfortunately HiveMQs auto discovery won't work on docker multihost networking, since neither udp multicast nor tcp broadcast are supported in these networks. Therefore it's important to follow the steps above exactly.
The docker container then will automatically create a statically allocated cluster with nodes of the entire Class-C network (e.g. 192.168.110.1 - 192.168.110.254) 

But - IT'S STILL NOT WORKING YET ;)
