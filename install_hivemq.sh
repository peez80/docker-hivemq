#!/bin/sh

apk add --no-cache bash openjdk7-jre

mkdir -p /opt
cd /opt

wget -O hivemq.zip http://www.hivemq.com/download.php?token=a2903f0457bc42959785c34fa1532dca
unzip hivemq.zip
rm hivemq.zip

ln -s /opt/hivemq-* /opt/hivemq

adduser -D -h /opt/hivemq hivemq
chown -R hivemq:hivemq /opt/hivemq-*
chown -R hivemq:hivemq /opt/hivemq


chmod +x /opt/hivemq/bin/run.sh

