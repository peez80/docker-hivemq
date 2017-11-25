
# Professional HiveMQ Docker Image
[![](https://images.microbadger.com/badges/version/peez/hivemq.svg)](http://microbadger.com/images/peez/hivemq "Get your own version badge on microbadger.com")  [![](https://images.microbadger.com/badges/image/peez/hivemq.svg)](https://microbadger.com/images/peez/hivemq "Get your own image badge on microbadger.com")

## HiveMQ
HiveMQ Version 3.3.1 is used currently

### General

The HiveMQ Docker Image uses a production grade pre configuration. Usually you shouldn't have to change the default configurations unless you aim at some special cases.
Everything you can configure is done by environment variables. Please have a look at the Dockerfile. Everything you see there can be changed by ENV variables.

### Installing a license
By default hivemq starts with a standard license for development purposes. 
To add your license file, mount it to _/opt/hivemq/license_:

    docker run -itd -v /local/path/license.lic:/opt/hivemq/license/license.lic:ro peez/hivemq

### Persistence
By default in-memory persistence is used. If you need to use some persistent storage you can change this via the environment variable `HIVEMQ_PERSISTENCE_MODE`. In general HiveMQ configuration there are several types of persistence you can configure. With this ENV variable you configure all of them at once. It is curently not in scope to configure them one by one.
For details on persistence see http://www.hivemq.com/docs/hivemq/latest/#mqtt-configuration-persistence-chapter.


### Individual configuration
This image comes with a default configuration. To define an own configuration, just mount the config.xml as you would with the license file:

    docker run -itd -v /local/path/to/config.xml:/opt/hivemq/conf/config_initial.xml:ro peez/hivemq
    
It's important to use config_initial.xml as filename, since the startscript (docker-entrypoint.sh) copies it to config.xml and makes some modifications (especially with cluster operation).
 
Please be aware that if you exchange the original configuration file and if the replacement tags inside the original file are removed, many of the original function won't work, so it's not recommended to replace the config.xml.

### Logging
It is possible to mount a custom logback.xml to /opt/hivemq/conf

### TLS
If you want to use TLS, you HAVE to mount the keystore and (if applicable) the truststore, since the provided stores are some rookie-like created self signed trust stores:

    docker run -itd -v /local/path/to/keystore.jks:/opt/hivemq/cert/hivemq_keystore.jks:ro -v /local/path/to/truststore.jks:/opt/hivemq/cert/hivemq_truststore.jks peez/hivemq
    
Additionally you have to set the details of your keystores by using the following ENV variables:

    HIVEMQ_KEYSTORE_PASSWORD
    HIVEMQ_PRIVATE_KEY_PASSWORD
    HIVEMQ_TRUSTSTORE_PASSWORD

## Plugins
To add plugins you could mount them to the plugin directory as described. For ease of use I would recommend extending the Dockerfile instead.

### Authentication
By default the file authentication plugin (see http://www.hivemq.com/plugin/file-authentication/) is installed and started. To disable the plugin start the docker container with `-e HIVEMQ_DISABLE_AUTH_PLUGIN=true`.

The predefined credentials are:

| User | Password |
| ---- | -------- |
| hivemq | test |

By default the plugin is already configured in production grade as described on the plugin homepage above. To change the configuration file, mount (or place by Dockerfile) your own fileAuthConfiguration.properties to `/opt/hivemq-modules/fileauth/conf/fileAuthConfiguration.properties`.
For changing the credentials you could either use the credentials file with the tool provided by the plugin or mount (or place by Dockerfile) your own credentials file to `/opt/hivemq-modules/fileauth/conf/credentials.properties`.

If mounting one or both of these files please have in mind that they reside in the same directory. So if you mount the directory instead of the file itself, make sure to have both files in this dir. 

### Cluster
With standard hivemq mechanisms it's quite hard to implement a cluster with hivemq standard possibilities due to several circumstances (no udp support, different network interfaces, ...).
Therefore I created a small cluster plugin that just uses one central database table for retaining the cluster state.

This is by default used to form a cluster with this image. For details see the [GitHub page](https://github.com/peez80/hivemq-database-cluster-discovery-plugin).

For starting a cluster see below.




# Start a Cluster in docker swarm mode
Since 1.12 docker supports native swarm mode. Due to it's routing mesh it also provides automated loadbalancing from outside as well in between containers. We incorporate this to build a higly available
cluster without an explicit loadbalancer in front.

The easiest way to set up a hivemq cluster would be one of the auto discovery features - this uses tcp broadcast or udp multicast. Unfortunately docker networking doesn't support any of these.
Therefore we have to be a little bit flexible.

To achieve this we just create a overlay network, start a postgres database and then start the hivemq nodes with information about this postgres database:

    docker network create --driver overlay hivemqcluster
    docker service create --name clusterdb --network hivemqcluster -p 5432:5432 -e POSTGRES_PASSWORD=cluster -e POSTGRES_USER=cluster -e POSTGRES_DB=cluster postgres:latest
    docker service create --name hivemq --network hivemqcluster -p 1883:1883 --replicas=3 -e HIVEMQ_CLUSTER_JDBC_URL=jdbc:postgresql://clusterdb:5432/cluster -e HIVEMQ_CLUSTER_JDBC_USER=cluster -e HIVEMQ_CLUSTER_JDBC_PASSWORD=cluster peez/hivemq:dev

Please note the environment variables ```HIVEMQ_CLUSTER_JDBC_URL```, ```HIVEMQ_CLUSTER_JDBC_USER```, ```HIVEMQ_CLUSTER_JDBC_PASSWORD```. These are used to inform the start script about the central database Cluster Store.

With these three commands we have three replicas running, maintaining their state at the given Postgres database. For Production I would not recommend the postgres Database in a docker container!

## Supported Databases
Currently the plugin is in it's first version, so it supports only postgres. I will extend it at some time, however it's easy to add a driver and you are free to create a pull request.
