#!/bin/sh

mkdir -p /opt
cd /opt

################################################
#Install HiveMQ
# 3.3.3
wget -O hivemq.zip https://www.hivemq.com/download.php?token=6264303c0ea115248df151f50a722572
unzip hivemq.zip
rm hivemq.zip

mv /opt/hivemq-* /opt/hivemq

adduser -D -h /opt/hivemq hivemq
chown -R hivemq:hivemq /opt/hivemq

chmod +x /opt/hivemq/bin/run.sh

######################################################
#Install file authentication plugin
INSTALL_TEMP=/opt/file-auth-plugin-install
mkdir -p $INSTALL_TEMP

cd $INSTALL_TEMP
wget -O file-auth.zip https://www.hivemq.com/wp-content/uploads/file-authentication-3.1.1-distribution.zip
unzip file-auth.zip
rm file-auth.zip

mkdir -p /opt/hivemq-modules/fileauth/bin
mv file-authentication-plugin-3.1.1.jar LICENSE.txt /opt/hivemq-modules/fileauth/bin

mkdir -p /opt/tools
mv tools/file-authentication-plugin-utility-1.1.jar /opt/tools

rm -rf $INSTALL_TEMP

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


#################################################################
# Download Database cluster plugin
mkdir -p /opt/hivemq-modules/database-cluster-discovery/bin
# For updating change Download-URL and adjust docker-entrypoint.sh to use the correct version
wget -O /opt/hivemq-modules/database-cluster-discovery/bin/database-cluster-discovery-1.0.0.jar https://github.com/peez80/hivemq-database-cluster-discovery-plugin/releases/download/1.0.0/database-cluster-discovery-1.0.0.jar


