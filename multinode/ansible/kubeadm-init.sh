#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -x
IFS=$'\n\t\v'

LOAD_BALANCER_DNS=$1
LOAD_BALANCER_PORT=6443

rm -rf /var/lib/etcd/lost+found
kubeadm init --control-plane-endpoint "$LOAD_BALANCER_DNS:$LOAD_BALANCER_PORT" \
             --upload-certs \
             --pod-network-cidr=192.168.66.0/8 \
             --ignore-preflight-errors=NumCPU

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
