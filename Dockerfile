FROM alpine:3.4
MAINTAINER philipp.lamp@stiffi.de

COPY install_hivemq.sh /install_hivemq.sh
RUN source /install_hivemq.sh &&\
    rm /install_hivemq.sh
COPY config.xml /opt/hivemq/conf/config.xml


ENV \
    HIVEMQ_KEYSTORE_PASSWORD="" \
    HIVEMQ_PRIVATE_KEY_PASSWORD="" \
    HIVEMQ_TRUSTSTORE_PASSWORD="" \
    HIVEMQ_TLS_CLIENT_AUTHENTICATION_MODE="NONE" \
    HIVEMQ_TCP_PORT="1883" \
    HIVEMQ_TCP_TLS_PORT="8883" \
    HIVEMQ_WEBSOCKET_PORT="8000" \
    HIVEMQ_WEBSOCKET_TLS_PORT="8001" \
    HIVEMQ_PERSISTENCE_MODE="in-memory" \
    HIVEMQ_CLUSTER_ENABLED="true"


EXPOSE $HIVEMQ_TCP_PORT $HIVEMQ_TCP_TLS_PORT $HIVEMQ_WEBSOCKET_PORT $HIVEMQ_WEBSOCKET_TLS_PORT 7800 7900

USER hivemq
CMD ["/opt/hivemq/bin/run.sh"]