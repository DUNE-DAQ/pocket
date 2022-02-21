#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -x
IFS=$'\n\t\v'

JOIN_CMD="$1"
CERTIFICATE_KEY_HASH="${2:-}"

rm -rf /var/lib/etcd/lost+found
CMD="$JOIN_CMD --ignore-preflight-errors=NumCPU"
if [[ -n ${CERTIFICATE_KEY_HASH:-} ]]; then
  CMD="$CMD --control-plane --certificate-key $CERTIFICATE_KEY_HASH"
fi
eval "$CMD"

if [[ -n ${CERTIFICATE_KEY_HASH:-} ]]; then
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
fi

