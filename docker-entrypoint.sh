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
    sed -i "s/{{CLUSTER_IP_HERE}}/$MY_SWARM_NETWORK_ADDRESS/g" /opt/hivemq/conf/config.xml


    echo "Building static cluster configuration..."
    TMPFILE=/tmp/clusterconfig.xml
    echo "" > $TMPFILE
    IP_SUFFIX=1
    while [  $IP_SUFFIX -lt 255 ]; do
        echo "<node><host>$SWARM_NETWORK_BASE.$IP_SUFFIX</host><port>7800</port></node>" >> $TMPFILE
        let IP_SUFFIX=IP_SUFFIX+1
    done
    sed -e '/{{STATIC_NODE_CONFIG_HERE}}/ {' -e "r $TMPFILE" -e 'd' -e '}' -i /opt/hivemq/conf/config.xml
    rm $TMPFILE
fi


# Enable Auth Plugin if necessary
if [ "$HIVEMQ_DISABLE_AUTH_PLUGIN" == "true" ]; then
    echo "Not Activating Auth plugin due to HIVEMQ_DISABLE_AUTH_PLUGIN"
    # This way is not yet compatible with docker stop and start. only with rm and run.
else
    echo "Enabling Auth plugin"
    ln -s /opt/hivemq-modules/fileauth/bin/file-authentication-plugin-3.0.2.jar /opt/hivemq/plugins/file-authentication-plugin-3.0.2.jar
    ln -s /opt/hivemq-modules/fileauth/conf/credentials.properties /opt/hivemq/plugins/credentials.properties
    ln -s /opt/hivemq-modules/fileauth/conf/fileAuthConfiguration.properties /opt/hivemq/plugins/fileAuthConfiguration.properties
fi

# Enable Graphite metrics plugin if necessary.
echo $GRAPHITE_HOST
if [ ! -z "$GRAPHITE_HOST" ]; then
  echo "Installing the graphite metrics plugin"
  HIVEMQ_GRAPHITE_PLUGIN_JAR_FILE_NAME=hivemq-graphite-metrics-plugin-3.1.1'.jar'
  echo $HIVEMQ_GRAPHITE_PLUGIN_JAR_FILE_NAME
  sed -i "s/localhost/$GRAPHITE_HOST/g" /opt/hivemq-modules/graphite-metrics-plugin/graphite-plugin.properties
  sed -i "s/reportingInterval \= 60/reportingInterval \= 10/g" /opt/hivemq-modules/graphite-metrics-plugin/graphite-plugin.properties
  sed -i "s/prefix \=/prefix \= hivemq/g" /opt/hivemq-modules/graphite-metrics-plugin/graphite-plugin.properties
  ln -s /opt/hivemq-modules/graphite-metrics-plugin/$HIVEMQ_GRAPHITE_PLUGIN_JAR_FILE_NAME /opt/hivemq/plugins/$HIVEMQ_GRAPHITE_PLUGIN_JAR_FILE_NAME
  ln -s /opt/hivemq-modules/graphite-metrics-plugin/graphite-plugin.properties /opt/hivemq/conf/graphite-plugin.properties
else
  echo "NOT installing the graphite metrics plugin."
fi

/opt/hivemq/bin/run.sh
