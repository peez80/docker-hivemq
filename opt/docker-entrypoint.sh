#!/bin/bash
# Attention!! Currently I'm working with file links and not removing file links - this way docker only docker rm should work really realiably - especially when changing environment parameters!


#restore original config.xml. This way the container is restart aware
cp /opt/hivemq/conf/config_initial.xml /opt/hivemq/conf/config.xml

# Enable Database Cluster Discovery if necessary
if [ ! -z "$HIVEMQ_CLUSTER_JDBC_URL" ]; then
    echo "Setting up HiveMQ DB Cluster with Database: $HIVEMQ_CLUSTER_JDBC_URL. User: $HIVEMQ_CLUSTER_JDBC_USER"

    if [ -z "$HIVEMQ_CLUSTER_JDBC_USER" ]; then
        echo "Environment Variable HIVEMQ_CLUSTER_JDBC_USER not found. Hopefully this is intentionally ;)"
    fi
    if [ -z "$HIVEMQ_CLUSTER_JDBC_PASSWORD" ]; then
        echo "Environment Variable HIVEMQ_CLUSTER_JDBC_PASSWORD not found. Hopefully this is intentionally ;)"
    fi


    # Remove Cluster comment tags to enable the cluster config part in config.xml
    sed -i "s/<!--CLUSTER_START_TAG//g" /opt/hivemq/conf/config.xml
    sed -i "s/CLUSTER_END_TAG-->//g" /opt/hivemq/conf/config.xml

    #Set Cluster IP
    MY_SWARM_NETWORK_ADDRESS=$(ifconfig eth0 | awk '/inet addr/{print substr($2,6)}')
    sed -i "s/{{CLUSTER_IP_HERE}}/$MY_SWARM_NETWORK_ADDRESS/g" /opt/hivemq/conf/config.xml

    # Manually build Plugin configuration
    cp /opt/hivemq-modules/database-cluster-discovery/conf/jdbc-database-cluster-discovery.properties /opt/hivemq/conf

    sed -i "s~{{jdbcUrl}}~$HIVEMQ_CLUSTER_JDBC_URL~g" /opt/hivemq/conf/jdbc-database-cluster-discovery.properties
    sed -i "s/{{jdbcUser}}/$HIVEMQ_CLUSTER_JDBC_USER/g" /opt/hivemq/conf/jdbc-database-cluster-discovery.properties
    sed -i "s/{{jdbcPassword}}/$HIVEMQ_CLUSTER_JDBC_PASSWORD/g" /opt/hivemq/conf/jdbc-database-cluster-discovery.properties


    # Link Plugin from installation dir to hivemq dir
    ln -s /opt/hivemq-modules/database-cluster-discovery/bin/database-cluster-discovery-1.0.0.jar /opt/hivemq/plugins/database-cluster-discovery.jar
fi



# Enable Auth Plugin if necessary
if [ "$HIVEMQ_DISABLE_AUTH_PLUGIN" == "true" ]; then
    echo "Not Activating Auth plugin due to HIVEMQ_DISABLE_AUTH_PLUGIN"
    # This way is not yet compatible with docker stop and start. only with rm and run.
else
    echo "Enabling Auth plugin"
    ln -s /opt/hivemq-modules/fileauth/bin/file-authentication-plugin-3.1.1.jar /opt/hivemq/plugins/file-authentication-plugin-3.1.1.jar
    ln -s /opt/hivemq-modules/fileauth/conf/credentials.properties /opt/hivemq/conf/credentials.properties
    ln -s /opt/hivemq-modules/fileauth/conf/fileAuthConfiguration.properties /opt/hivemq/conf/fileAuthConfiguration.properties
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
