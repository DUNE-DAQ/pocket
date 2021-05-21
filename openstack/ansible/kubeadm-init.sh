#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -x
IFS=$'\n\t\v'

LOAD_BALANCER_DNS=$1
LOAD_BALANCER_PORT=6443

rm -rf /var/lib/etcd/lost+found
kubeadm init --control-plane-endpoint "$LOAD_BALANCER_DNS:$LOAD_BALANCER_PORT" \
             --upload-certs \
             --pod-network-cidr=192.168.0.0/16 \
             --ignore-preflight-errors=NumCPU

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

curl -O https://docs.projectcalico.org/v3.15/manifests/calico.yaml

## from
## diff --context=10 calico.yaml calico.patched.yaml
cat <<EOF | patch calico.yaml
*** calico.yaml 2021-05-04 16:21:50.099528374 +0200
--- calico.patched.yaml        2021-05-04 16:26:10.424986628 +0200
***************
*** 3529,3548 ****
--- 3529,3553 ----
              mountPath: /host/driver
            securityContext:
              privileged: true
        containers:
          # Runs calico-node container on each Kubernetes node. This
          # container programs network policy and routes on each
          # host.
          - name: calico-node
            image: calico/node:v3.15.5
            env:
+             # https://discuss.kubernetes.io/t/connection-issues-with-pods-on-centos-8-nodes/8650/19
+             # https://github.com/rancher/rke/issues/1788#issuecomment-565536201
+             # https://github.com/projectcalico/calico/issues/2322#issuecomment-515554705
+             - name: FELIX_IPTABLESBACKEND
+               value: NFT
              # Use Kubernetes API as the backing datastore.
              - name: DATASTORE_TYPE
                value: "kubernetes"
              # Wait for the datastore.
              - name: WAIT_FOR_DATASTORE
                value: "true"
              # Set based on the k8s node name.
              - name: NODENAME
                valueFrom:
                  fieldRef:
EOF

kubectl apply -f calico.yaml
