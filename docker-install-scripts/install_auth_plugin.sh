#!/bin/bash

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