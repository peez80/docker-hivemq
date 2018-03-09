#!/bin/sh


################################################
#Install HiveMQ
# 3.3.3

INSTALL_TEMP=/opt/install/hivemq-install-temp
mkdir -p $INSTALL_TEMP

wget -O $INSTALL_TEMP/hivemq.zip https://www.hivemq.com/download.php?token=6264303c0ea115248df151f50a722572
unzip -d $INSTALL_TEMP $INSTALL_TEMP/hivemq.zip
rm $INSTALL_TEMP/hivemq.zip

mv -v $INSTALL_TEMP/hivemq-* /opt/hivemq

adduser -D -h /opt/hivemq hivemq
chown -R hivemq:hivemq /opt/hivemq

chmod +x /opt/hivemq/bin/run.sh

rm -r $INSTALL_TEMP