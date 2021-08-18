# Pocket

A set of scripts designed to help create a 'production-like' DUNE DAQ environment in a variety of setups.

## Requirements
- A git clone of this repository
- a functional docker installation
- access to external network/Internet for git and dockerhub downloads

Pocket is compatible with Linux, MacOS (intel based), and Windows (through WSL2).

Note that while this covers a very large variety of setups, currently lxplus is _not_ compatible for its lack of a docker installation.
This for security reasons (even though [rootless docker](https://docs.docker.com/engine/security/rootless/) is a thing.

## Dependencies

If your environment does not already provide a working Docker configuration, install Docker and run the daemon. 

On CentOS/SL, as root:
```
 $ [yum|dnf] -y install docker
 $ systemctl enable docker
 $ systemctl start docker
```

On Fedora you may need to set the kernel commandline parameter:
```systemd.unified_cgroup_hierarchy=0```

## Quick-start

Clone this git repository to a location of your choice.

For a cluster with all built-in services enabled:
```bash
make setup.local
# equivalent to
# SERVICES=opmon make setup.local
```

This will setup your local (one-node) cluster, and print out available default services and their access credentials.

![](docs/print-access-creds.png)

To start a cluster without ElasticSearch
```bash
SERVICES=opmon make setup.local
```

Optionally, to make your shell use binaries (`kubectl`, ...) that pocket ships with
```bash
eval $(make env)
```

## Accessing services

Built-in services will be exposed via static port bindings to `localhost`.  
These are printed out after a successful setup or by running `make print-access-creds`.

|Service|Port|
|-|-|
|Proxy server|31000|
|K8S Dashboard|31001|
|InfluxDB|31002|
|Grafana|31003|
|ElasticSearch|31004|
|Kibana|31005|
|Opmonlib Proxy|31006|

For the in-cluster experience, and to access your own (non-built-in) defined services,
the cluster will have a http proxy running for you to access any services internal to the cluster.

This proxy runs on port `31000` and is usable using curl
```bash
$ # when using local deployment
$ curl --socks5 localhost:31000 --socks5-hostname localhost:31000 http://example-server
$ # when using OpenStack
$ curl --socks5 https://mycernusername-pocketdune.cern.ch:31000 --socks5-hostname https://mycernusername-pocketdune.cern.ch:31000 http://example-server
```

or a webbrowser using foxyproxy  
![](docs/foxyproxy.png)

![](docs/grafana.png)

## supported setups

### locally on your own machine
This will create a single node cluster.  
The only requirement is a working installation of `docker`, other binaries required for setup are downloaded automatically and require no sudo privileges.
```bash
$ make setup.local
```

Optionally, to make your shell use binaries (`kubectl`, ...) that pocket ships with
```bash
eval $(make env)
```

To destroy after you finished, run
```bash
$ make destroy.local
```

### CERN OpenStack
This will create a two-node cluster (by default). You will need Python3.8 or higher and ssh client on your local machine. Other binaries required for setup are downloaded automatically and require no sudo privileges.

You will need to authenticate with CERN OpenStack, the makefile will help you do that if you don't know how.
```bash
$ make setup.openstack
```

This will create a `terraform.tfstate` file in `./openstack/terraform`. Keep this file, and keep it secret, for as long as you wish to have your cluster.
It contains your SSH key, there is no other place where you can retrieve this.

If you are not on the CERN network, open a proxy using `ssh -D 12345 lxplus.cern.ch`.
You can then execute `HTTP_PROXY=https://localhost:12345 make setup.openstack`.

To destroy after you finished, run
```bash
$ make destroy.openstack
```

You can change the number and flavor of machines to use by editing [terraform/wanted.tf](terraform/wanted.tf)
