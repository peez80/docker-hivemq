Professional HiveMQ Docker Image
================================

!! Image still under construction. Cluster not yet working and functionality (especially tls) not tested !!


Installing a license
--------------------
By default hivemq starts with a standard license for development purposes. 
To add your license file, mount it to _/opt/hivemq/license_:

    docker run -itd -v /local/path/license.lic:/opt/hivemq/license/license.lic:ro peez/hivemq

Persistence
-----------
Info about persistence here


Individual configuration
------------------------
This image comes with a default configuration. To define an own configuration, just mount the config folder as you would with the license file:

    docker run -itd -v /local/path/to/config:/opt/hivemq/conf:ro peez/hivemq

Logging
-------
It is possible to mount a custom logback.xml to /opt/hivemq/conf


Start on docker native cluster
------------------------------
Since 1.12 docker supports native swarm mode. Due to it's routing mesh it also provides automated loadbalancing from outside as well in between containers. We incorporate this to build a higly available
cluster without an explicit loadbalancer in front.
(Not working yet ;)