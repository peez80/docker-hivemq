#!/bin/bash


#################################################################
# Download Database cluster plugin
mkdir -p /opt/hivemq-modules/database-cluster-discovery/bin
# For updating change Download-URL and adjust docker-entrypoint.sh to use the correct version
wget -O /opt/hivemq-modules/database-cluster-discovery/bin/database-cluster-discovery-1.0.0.jar https://github.com/peez80/hivemq-database-cluster-discovery-plugin/releases/download/1.0.0/database-cluster-discovery-1.0.0.jar


