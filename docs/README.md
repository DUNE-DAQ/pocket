# pocket

The goal of this project is to setup a minimal kubernetes environment for deploying DAQ workflows.

Pocket is based on [(Linux) containers](https://docker.io), [Kubernetes](https://kubernetes.io) and [KIND](https://kind.sigs.k8s.io).

## Installation

### Requirements

- access to external network/Internet for git and dockerhub downloads

Utilities:

- `make`
- `base64`
- `find`
- `git`
- `grep`
- `jq`
- `sed`

You must also have a functional [`docker` installation](https://docs.docker.com/engine/install/) that can download container images from the internet.

On CentOS/SL/Alma9, as root:
```
 $ [yum|dnf] -y install docker-ce
 $ systemctl enable docker
 $ systemctl start docker
```

## Setup

To use this project you need to clone the git repo and run one of the Makefile workflows:

```bash
git clone https://github.com/DUNE-DAQ/pocket.git
cd pocket
make help
```
## create pocketdune cluster

```bash
make create-pocketdune-cluster
```

## setup your path


The utilities this workflow installs can be added to your `$PATH` via `eval $(make env)`.

```
eval $(make env)
```

## deploy all services

```
kluctl deploy pocket
```

### Security

Pocket exposes most of its services on the host to the outside network. It should only be run in a protected environment where it is safe to expose these services!

## Deployment

Once you have created the kind cluster via this project, you should be able to select your deployment target from `daq-kube`. See that repo for instructions

If you recieve:

```
✗ target pocket not existent in kluctl project config
```

You should first `cd daq-kube`.

### local storage

This setup will use `./local` to store your persistant disks. You can replace this directory with a symbolic link to another location.
