docker service rm hivemq
docker build -t hive .

REM docker rm -f hivemq
REM docker run -itd --name hivemq -p 1883:1883 -p 8883:8883 -p 8000:8000 -p 8001:8001 -e HIVEMQ_KEYSTORE_PASSWORD=password -e HIVEMQ_PRIVATE_KEY_PASSWORD=password peez/hivemq:latest
REM docker logs -f hivemq

docker service create --name hivemq --network hivemq --replicas 3 -p 1883:1883 -e SWARM_NETWORK_BASE=192.168.110 hive
