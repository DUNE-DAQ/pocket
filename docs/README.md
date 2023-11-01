# pocket

The goal of this project is to setup a minimal kubernetes environment for deploying DAQ workflows.

Pocket is based on [(Linux) containers](https://docker.io), [Kubernetes](https://kubernetes.io) and [KIND](https://kind.sigs.k8s.io).

## Security

Pocket exposes most of its services on the host to the outside network. It should only be run in a protected environment where it is safe to expose these services!

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

You must also have a functional [`docker` server installation](https://docs.docker.com/engine/install/#server) that can download container images from the internet.

On Alma/CentOS/SL:
```bash
sudo [yum|dnf] -y install docker-ce
sudo systemctl enable docker
sudo systemctl start docker
```

## Setup

To use this project you need to clone the git repo and run one of the Makefile workflows:

```bash
git clone https://github.com/DUNE-DAQ/pocket.git
cd pocket
make help
```

Select the workflow you desire from the output of `make help`.  Odds are it is `make recreate-pocketdune-cluster`.

### local storage

This setup will use `./local` to store your persistant disks. You can replace this directory with a symbolic link to another location before you run the `make` commands - but not after.

## Test your system

Check that your system has the required utilities installed and working:

```bash
make test-shell-utils
```

## Create pocketdune cluster

Now you can create a pocketdune cluster on your system:

```bash
make create-pocketdune-cluster
```

This will also provide some output to help you quickly deploy content into the new cluster.

## Setup your PATH

As a part of the create process a handful of utilities will be downloaded.  You'll need these in your `$PATH` to use them.

```bash
eval $(make env)
```

## Cleanup pocketdune cluster

Once you are done with the cluster, you can remove it with:

```bash
make remove-pocketdune-cluster
```

## Deployment

Once you have created the kind cluster via this project, you should be able to select your deployment target from `daq-kube`. See that [repo](https://github.com/DUNE-DAQ/daq-kube) for instructions.

If you recieve:

```
✗ target pocket not existent in kluctl project config
```

You should first `cd daq-kube`.
