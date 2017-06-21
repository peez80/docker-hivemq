#!/bin/sh

mkdir -p /opt
cd /opt

#Install HiveMQ
wget -O hivemq.zip http://www.hivemq.com/download.php?token=a1b4752797ca72e00d4074f0c1b5dc2c
unzip hivemq.zip
rm hivemq.zip

mv /opt/hivemq-* /opt/hivemq

adduser -D -h /opt/hivemq hivemq
chown -R hivemq:hivemq /opt/hivemq


chmod +x /opt/hivemq/bin/run.sh

#Install file authentication plugin
INSTALL_TEMP=/opt/file-auth-plugin-install
mkdir -p $INSTALL_TEMP


cd $INSTALL_TEMP
wget -O file-auth.zip http://www.hivemq.com/wp-content/uploads/file-authentication-3.0.2-distribution.zip
unzip file-auth.zip
rm file-auth.zip

mkdir -p /opt/hivemq-modules/fileauth/bin
mv file-authentication-plugin-3.0.2.jar LICENSE.txt /opt/hivemq-modules/fileauth/bin

mkdir -p /opt/tools
mv tools/file-authentication-plugin-utility-1.1.jar /opt/tools

rm -rf $INSTALL_TEMP

#Install graphite plugin
INSTALL_TEMP_GRAPHITE=/opt/graphite-plugin-install
mkdir -p $INSTALL_TEMP_GRAPHITE
cd $INSTALL_TEMP_GRAPHITE
wget http://www.hivemq.com/wp-content/uploads/hivemq-graphite-metrics-plugin-3.0.0.zip
unzip hivemq-graphite-metrics-plugin-3.0.0.zip
rm hivemq-graphite-metrics-plugin-3.0.0.zip
mkdir -p /opt/hivemq-modules/graphite-metrics-plugin
mv hivemq-graphite-metrics-plugin-3.0.0.jar LICENSE.txt /opt/hivemq-modules/graphite-metrics-plugin
mv graphite-plugin.properties /opt/hivemq-modules/graphite-metrics-plugin
rm -rf $INSTALL_TEMP_GRAPHITE

cd /opt
