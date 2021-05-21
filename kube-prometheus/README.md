# Kube-prometheus

This implements the building instructions for kube-prometheus found here:  
https://github.com/prometheus-operator/kube-prometheus#quickstart

Manifests are checked into git in the `manifests` folder. If you wish to rebuild, run:

```bash
$ bash build.sh kube-prometheus.jsonnet
```