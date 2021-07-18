#! /bin/bash
# run this to initialize a local ERS

wdir=$PWD

cd ..
eval $(make env)

cd ${wdir}

kind create cluster --config ./ers-kind.config.yaml

kubectl apply -f ../ers-proxy-server.yaml

#namespaces
kubectl apply -f ns-dunedaqers.yaml
kubectl apply -f ns-kafka-kraft.yaml

#secrets
kubectl -n dunedaqers create secret generic postgres-secrets \
        --from-literal=POSTGRES_USER="$(pwqgen)" \
        --from-literal=POSTGRES_PASSWORD="$(pwqgen)"\

kubectl apply -f kafka.yaml

#kubectl apply -f kafka-svc.yaml

kubectl apply -f postgres.yaml
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
