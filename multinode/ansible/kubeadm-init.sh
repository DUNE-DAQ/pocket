#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -x
IFS=$'\n\t\v'

rm -rf /var/lib/etcd/lost+found
kubeadm init --upload-certs \
             --pod-network-cidr=192.168.66.0/8 \
             --ignore-preflight-errors=NumCPU

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
