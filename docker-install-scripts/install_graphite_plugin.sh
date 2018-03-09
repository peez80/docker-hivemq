#!/bin/bash

################################################################################
#Install graphite plugin
INSTALL_TEMP_GRAPHITE=/opt/graphite-plugin-install
mkdir -p $INSTALL_TEMP_GRAPHITE
cd $INSTALL_TEMP_GRAPHITE

HIVEMQ_GRAPHITE_PLUGIN='hivemq-graphite-metrics-plugin-3.1.1'
HIVEMQ_GRAPHITE_PLUGIN_ZIP_FILE_NAME=$HIVEMQ_GRAPHITE_PLUGIN'.zip'
HIVEMQ_GRAPHITE_PLUGIN_JAR_FILE_NAME=$HIVEMQ_GRAPHITE_PLUGIN'.jar'
wget https://www.hivemq.com/wp-content/uploads/$HIVEMQ_GRAPHITE_PLUGIN_ZIP_FILE_NAME
unzip $HIVEMQ_GRAPHITE_PLUGIN_ZIP_FILE_NAME
rm $HIVEMQ_GRAPHITE_PLUGIN_ZIP_FILE_NAME
mkdir -p /opt/hivemq-modules/graphite-metrics-plugin
mv $HIVEMQ_GRAPHITE_PLUGIN_JAR_FILE_NAME LICENSE.txt /opt/hivemq-modules/graphite-metrics-plugin
mv graphite-plugin.properties /opt/hivemq-modules/graphite-metrics-plugin
rm -rf $INSTALL_TEMP_GRAPHITE

cd /opt