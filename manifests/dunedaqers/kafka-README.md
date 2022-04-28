
These are the operations to run the kafka

create your namespace `$MYNAMESPACE`

```bash
kubectl create namespace $MYNAMESPACE
kubectl config set-context --current --namespace=$MYNAMESPACE
```
import the external listener
```bash
kubectl -n $MYNAMESPACE create secret generic kafka-secrets --from-literal=EXTERNAL_LISTENER=<your desired server>
```

apply the kafka

```bash
kubectl -n $MYNAMESPACE create configmap dune-kafka-libs --from-file images/kafka/jmx_prometheus_javaagent-0.16.1.jar
kubectl -n $MYNAMESPACE create configmap dune-kafka-config --from-file images/kafka/sample_jmx_exporter.yml
kubectl apply -f manifests/dunedaqers/kafka.yaml
kubectl apply -f manifests/dunedaqers/kafka-svc.yaml
```