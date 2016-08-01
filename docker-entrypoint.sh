#!/bin/bash
#export MY_SWARM_NETWORK_ADDRESS=$(ifconfig | awk '/inet addr/{print substr($2,6)}' | grep 192)
#echo "ADDR: $MY_SWARM_NETWORK_ADDRESS"

#sed -i "s/{{MY_IP}}/$MY_SWARM_NETWORK_ADDRESS/g" /opt/hivemq/conf/config.xml

/opt/hivemq/bin/run.sh