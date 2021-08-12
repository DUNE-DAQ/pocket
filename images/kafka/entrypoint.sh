#!/bin/bash

NODE_ID=${HOSTNAME:6}

#LISTENERS="PLAINTEXT_POCKET://:9092,PLAINTEXT://30092,CONTROLLER://:9093,"
#ADVERTISED_LISTENERS="PLAINTEXT://kafka-$NODE_ID.$SERVICE.$NAMESPACE.svc.cluster.local:9092"
#ADVERTISED_LISTENERS="PLAINTEXT://127.0.0.1:30092, PLAINTEXT_POCKET:kafka-svc.kafka-kraft:9092"
#KAFKA_LISTENER_SECURITY_PROTOCOL_MAP="PLAINTEXT:PLAINTEXT,PLAINTEXT_POCKET:PLAINTEXT"

CONTROLLER_QUORUM_VOTERS=""
for i in $( seq 0 $REPLICAS); do
    if [[ $i != $REPLICAS ]]; then
        CONTROLLER_QUORUM_VOTERS="$CONTROLLER_QUORUM_VOTERS$i@kafka-$i.$SERVICE.$NAMESPACE.svc.cluster.local:9093,"
    else
        CONTROLLER_QUORUM_VOTERS=${CONTROLLER_QUORUM_VOTERS::-1}
    fi
done

mkdir -p $SHARE_DIR/$NODE_ID

if [[ ! -f "$SHARE_DIR/cluster_id" && "$NODE_ID" = "0" ]]; then
    CLUSTER_ID=$(kafka-storage.sh random-uuid)
    echo $CLUSTER_ID > $SHARE_DIR/cluster_id
else
    CLUSTER_ID=$(cat $SHARE_DIR/cluster_id)
fi

sed -e "s+^node.id=.*+node.id=$NODE_ID+" \
-e "s+^controller.quorum.voters=.*+controller.quorum.voters=$CONTROLLER_QUORUM_VOTERS+" \
-e "s+^log.dirs=.*+log.dirs=$SHARE_DIR/$NODE_ID+" \
/opt/kafka/config/kraft/server.properties > server.properties.updated \
&& mv server.properties.updated /opt/kafka/config/kraft/server.properties

kafka-storage.sh format -t $CLUSTER_ID -c /opt/kafka/config/kraft/server.properties

exec kafka-server-start.sh /opt/kafka/config/kraft/server.properties


