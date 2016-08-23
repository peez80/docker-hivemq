#!/bin/sh

mkdir -p /opt
cd /opt

#Install HiveMQ
wget -O hivemq.zip http://www.hivemq.com/download.php?token=a2903f0457bc42959785c34fa1532dca
unzip hivemq.zip
rm hivemq.zip

mv /opt/hivemq-* /opt/hivemq

adduser -D -h /opt/hivemq hivemq
chown -R hivemq:hivemq /opt/hivemq


chmod +x /opt/hivemq/bin/run.sh

#Install file authentication plugin
mkdir -p /opt/file-auth-plugin
mkdir -p /opt/tools

cd /opt/file-auth-plugin
wget -O file-auth.zip http://www.hivemq.com/wp-content/uploads/file-authentication-3.0.2-distribution.zip
unzip file-auth.zip
rm file-auth.zip

mv file-authentication-plugin-3.0.2.jar LICENSE.txt /opt/hivemq-modules/fileauth/bin
mv tools/file-authentication-plugin-utility-1.1.jar /opt/tools



cd ..
