
Professional HiveMQ Docker Image
================================
[![](https://images.microbadger.com/badges/version/peez/hivemq.svg)](http://microbadger.com/images/peez/hivemq "Get your own version badge on microbadger.com")  [![](https://images.microbadger.com/badges/image/peez/hivemq.svg)](https://microbadger.com/images/peez/hivemq "Get your own image badge on microbadger.com")


General
-------
The HiveMQ Docker Image uses a production grade pre configuration. Usually you shouldn't have to change the default configurations unless you aim at some special cases.
Everything you can configure is done by environment variables. Please have a look at the Dockerfile. Everything you see there can be changed by ENV variables.

Installing a license
--------------------
By default hivemq starts with a standard license for development purposes. 
To add your license file, mount it to _/opt/hivemq/license_:

    docker run -itd -v /local/path/license.lic:/opt/hivemq/license/license.lic:ro peez/hivemq

Persistence
-----------
By default in-memory persistence is used. If you need to use some persistent storage you can change this via the environment variable `HIVEMQ_PERSISTENCE_MODE`. In general HiveMQ configuration there are several types of persistence you can configure. With this ENV variable you configure all of them at once. It is curently not in scope to configure them one by one.
For details on persistence see http://www.hivemq.com/docs/hivemq/latest/#mqtt-configuration-persistence-chapter.


Individual configuration
------------------------
This image comes with a default configuration. To define an own configuration, just mount the config.xml as you would with the license file:

    docker run -itd -v /local/path/to/config.xml:/opt/hivemq/conf/config_initial.xml:ro peez/hivemq
    
It's important to use config_initial.xml as filename, since the startscript (docker-entrypoint.sh) copies it to config.xml and makes some modifications (especially with cluster operation).
 
Please be aware that if you exchange the original configuration file and if the replacement tags inside the original file are removed, many of the original function won't work, so it's not recommended to replace the config.xml.

Logging
-------
It is possible to mount a custom logback.xml to /opt/hivemq/conf

TLS
---
If you want to use TLS, you HAVE to mount the keystore and (if applicable) the truststore, since the provided stores are some rookie-like created self signed trust stores:

    docker run -itd -v /local/path/to/keystore.jks:/opt/hivemq/cert/hivemq_keystore.jks:ro -v /local/path/to/truststore.jks:/opt/hivemq/cert/hivemq_truststore.jks peez/hivemq
    
Additionally you have to set the details of your keystores by using the following ENV variables:

    HIVEMQ_KEYSTORE_PASSWORD
    HIVEMQ_PRIVATE_KEY_PASSWORD
    HIVEMQ_TRUSTSTORE_PASSWORD

Plugins
-------
To add plugins you could mount them to the plugin directory as described. For ease of use I would recommend extending the Dockerfile instead.

Authentication
--------------
By default the file authentication plugin (see http://www.hivemq.com/plugin/file-authentication/) is installed and started. To disable the plugin start the docker container with `-e HIVEMQ_DISABLE_AUTH_PLUGIN=true`.

The predefined credentials are:

| User | Password |
| ---- | -------- |
| hivemq | test |

By default the plugin is already configured in production grade as described on the plugin homepage above. To change the configuration file, mount (or place by Dockerfile) your own fileAuthConfiguration.properties to `/opt/hivemq-modules/fileauth/conf/fileAuthConfiguration.properties`.
For changing the credentials you could either use the credentials file with the tool provided by the plugin or mount (or place by Dockerfile) your own credentials file to `/opt/hivemq-modules/fileauth/conf/credentials.properties`.

If mounting one or both of these files please have in mind that they reside in the same directory. So if you mount the directory instead of the file itself, make sure to have both files in this dir. 





Start on docker native cluster
------------------------------
Since 1.12 docker supports native swarm mode. Due to it's routing mesh it also provides automated loadbalancing from outside as well in between containers. We incorporate this to build a higly available
cluster without an explicit loadbalancer in front.

The easiest way to set up a hivemq cluster would be one of the auto discovery features - this uses tcp broadcast or udp multicast. Unfortunately docker networking doesn't support any of these.
Therefore we have to be a little bit flexible.

Approach is - we create a overlay network in a manually given subnet. This subnet HAS to be a full class-c network, so it must end with /24. Additionally we need to pass the network base as 
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