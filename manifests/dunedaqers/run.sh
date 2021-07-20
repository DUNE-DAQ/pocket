#! /bin/bash
# run this to initialize a local ERS


echo $0
wdir=$(dirname "`realpath $0`")

cd ../../
eval $(make env)
make kind

cd $wdir

echo $wdir

kind create cluster --config ./ers-kind.config.yaml

#namespaces
kubectl apply -f ns-dunedaqers.yaml
kubectl apply -f ns-kafka-kraft.yaml

#use the regular Pocket proxy
kubectl apply -f ../proxy-server.yaml

#secrets
pgpass="$(pwqgen)"
pgpass="admin"
echo $pgpass

kubectl -n dunedaqers create secret generic postgres-secrets \
        --from-literal=POSTGRES_USER="admin" \
        --from-literal=POSTGRES_PASSWORD="$pgpass"

# aspcore needs the password in a different format
dotnetpass=`echo $pgpass| awk '{print "Password="$0";"}'`

echo $dotnetpass

kubectl -n dunedaqers create secret generic aspcore-secrets \
	--from-literal=DOTNETPOSTGRES_PASSWORD="$dotnetpass"


kubectl apply -f kafka.yaml

#kubectl apply -f kafka-svc.yaml
kubectl apply -f postgres.yaml
kubectl apply -f postgres-svc.yaml

kubectl apply -f aspcore.yaml

echo "Proxy server available at: socks5 port 31000"

kubectl describe secrets postgres-secrets
echo ""

kubectl -n kafka-kraft get pods
echo ""

kubectl -n dunedaqers get pods


echo ""

echo "check out http://aspcore-svc.dunedaqers/ErrorReports"
echo "through proxy"
