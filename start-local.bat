echo "Create overlay network"
docker network create --driver overlay hivemqcluster

echo "Remove existing services"
docker service rm hivemq clusterdb

echo Start Cluster Database
docker service create --name clusterdb --network hivemqcluster -p 5432:5432 -e POSTGRES_PASSWORD=cluster -e POSTGRES_USER=cluster -e POSTGRES_DB=cluster postgres:latest

echo Build and Start hivemq with 3 replicas
docker build -t peez/hivemq:dev .
docker service create --name hivemq --network hivemqcluster -p 1883:1883 --replicas=3 -e HIVEMQ_CLUSTER_JDBC_URL=jdbc:postgresql://clusterdb:5432/cluster -e HIVEMQ_CLUSTER_JDBC_USER=cluster -e HIVEMQ_CLUSTER_JDBC_PASSWORD=cluster peez/hivemq:dev

