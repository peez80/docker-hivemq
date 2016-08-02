#!/bin/bash

#restore original config.xml. This was the container is restart aware
cp /opt/hivemq/conf/config_initial.xml /opt/hivemq/conf/config.xml


#export MY_SWARM_NETWORK_ADDRESS=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep 192)
#echo "ADDR: $MY_SWARM_NETWORK_ADDRESS"

#sed -i "s/{{MY_IP}}/$MY_SWARM_NETWORK_ADDRESS/g" /opt/hivemq/conf/config.xml

#Replace bind-address 0.0.0.0 by the actual docker multihost networking ip
#For this we need to have a docker overlay network with a given subnet.
echo "Base: $SWARM_NETWORK_BASE"
if [ ! -z "$SWARM_NETWORK_BASE" ]; then
    echo "Found SWARM_NETWORK_BASE Variable. Configuring bind-addr..."
    MY_SWARM_NETWORK_ADDRESS=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep "$SWARM_NETWORK_BASE")
    echo "Found Addr: $MY_SWARM_NETWORK_ADDRESS"

    sed -i "s/<!--CLUSTER_START_TAG//g" /opt/hivemq/conf/config.xml
    sed -i "s/CLUSTER_END_TAG-->//g" /opt/hivemq/conf/config.xml


    echo "Replacing cluster bind address in config.xml..."
    sed -i "s/{{CLUSTER_IP}}/$MY_SWARM_NETWORK_ADDRESS/g" /opt/hivemq/conf/config.xml

    echo "Replacing docker network base in config.xml..."
    sed -i "s/{{SWARM_NETWORK_BASE}}/$SWARM_NETWORK_BASE/g" /opt/hivemq/conf/config.xml
fi


/opt/hivemq/bin/run.sh