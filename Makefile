SHELL:=/bin/bash
.DEFAULT_GOAL := help

KIND_CLUSTER_NAME := pocketdune

# BEGIN FRUSTRATING MANUAL MAINTANCE
# keep these in sync by hand :(
# RHEL7 doesn't support kind 0.20.0
KUBERNETES_VERSION := v1.27.1
KIND_VERSION := v0.19.0
KIND_NODE_VERSION := docker.io/kindest/node:v1.27.1@sha256:b7d12ed662b873bd8510879c1846e87c7e676a79fefc93e17b2a52989d3ff42b
# END FRUSTRATING MANUAL MAINTANCE

MAKEFILE_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
MY_BINDIR := ${MAKEFILE_DIR}/bin
MY_CONFIGDIR := ${MAKEFILE_DIR}/config
MY_PERSISTENT_STORAGE := ${MAKEFILE_DIR}/local

MY_KIND_CLUSTER_CONFIG := ${MY_CONFIGDIR}/${KIND_CLUSTER_NAME}.kind.cluster.config.yaml

OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
PLATFORM := $(shell uname -m | tr '[:upper:]' '[:lower:]' | sed -e 's/x86_64/amd64/')

# try to break out targets into something more manageable 
include .makefile/kubectl.mk
include .makefile/kind.mk
include .makefile/kind-config.mk
include .makefile/kluctl.mk
include .makefile/daq-kube.mk

PATH := ${PATH}:${MAKEFILE_DIR}/bin

##
### Usage assistance
##
.PHONY: help
help: ## display this Help Message
	@IFS=$$'\n'; for line in `grep -h -E '^[a-zA-Z_#-]+:?.*?## .*$$' $(MAKEFILE_LIST)`; do if [ "$${line:0:2}" = "##" ]; then \
	echo $$line | awk 'BEGIN {FS = "## "}; {printf "\n\033[33m%s\033[0m\n", $$2}'; else \
	echo $$line | sed -e 's/$${KIND_CLUSTER_NAME}/${KIND_CLUSTER_NAME}/' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'; fi; \
	done; unset IFS;


.PHONY: env
env: ## use `eval $(make env)` to get access to downloaded binaries
	@echo "export PATH=\"\$${PATH}:${MY_BINDIR}\""

##
### Manage KinD cluster
##
.PHONY: write-kind-config
write-kind-config: ${MY_KIND_CLUSTER_CONFIG} ## Generate a KinD config
	@true

.PHONY: remove-kind-config
remove-kind-config: ## Delete the generated KinD config
	@rm -f ${MY_KIND_CLUSTER_CONFIG}

.PHONY: create-${KIND_CLUSTER_NAME}-cluster
create-${KIND_CLUSTER_NAME}-cluster: test-shell-utils test-docker-is-working get-kubectl get-kind write-kind-config get-kluctl ## Create the KinD cluster
	@echo ""
	@echo "Creating kind cluster..."
	@echo -e "\033[1m**\033[0m The wait for control-plane=Ready \033[1mmay time out\033[0m, this is safe to ignore. \033[1m**\033[0m"
	@echo ""
	@kind create cluster --wait 10s --config ${MY_KIND_CLUSTER_CONFIG}
	@echo ""
	@echo "Cleaning up unnecessary resources, please wait..."
	kubectl delete storageclass standard --now=true --wait=true
	kubectl delete namespace local-path-storage --now=true --wait=true
	@echo ""
	@echo "Setting up kubernetes client certificates..."
	@sleep 5
	@kubectl get csr --no-headers=true | grep -i pending | cut -d' ' -f1 | xargs -i kubectl certificate approve {} >/dev/null
	@echo ""
	@echo -e "You can setup your \033[1m\$$PATH\033[0m with:"
	@echo -e " \033[1m eval \$$(make env) \033[0m"
	@echo "You should look at the cluster status with:"
	@echo -e " \033[1m kubectl get pods -A \033[0m"
	@echo "and install your cluster components with \`kluctl\`"
	@echo -e "from the \033[1mdaq-kube\033[0m repo you have just checked out:"
	@echo -e " \033[1m cd ${MAKEFILE_DIR}/daq-kube \033[0m"
	@echo "You should review the instructions in that repository"
	@echo "to run something like this:"
	@echo -e " \033[1m kluctl deploy -t pocket -y \033[0m"

.PHONY: remove-${KIND_CLUSTER_NAME}-cluster
remove-${KIND_CLUSTER_NAME}-cluster: test-docker-is-working get-kind remove-kind-config ## Delete the KinD cluster
	@echo ""
	kind delete cluster --name ${KIND_CLUSTER_NAME}
	@echo ""

.PHONY: recreate-${KIND_CLUSTER_NAME}-cluster
recreate-${KIND_CLUSTER_NAME}-cluster: remove-pocketdune-cluster create-pocketdune-cluster ## Delete and create the KinD cluster
	@true # no actual work done in this wrapper

##
### Fetch required binaries
##
.PHONY: get-kind
get-kind: ${MY_BINDIR}/kind ## fetch KinD binary
	@true # fall through to ugly name

.PHONY: get-kubectl
get-kubectl: ${MAKEFILE_DIR}/bin/kubectl ## fetch kubectl binary
	@true # fall through to ugly name


.PHONY: get-kluctl
get-kluctl: ${MY_BINDIR}/kluctl ## fetch kluctl binary
	@true # fall through to ugly name

##
### Fetch the kube-daq repository
##
.PHONY: get-kube-daq
get-kube-daq: ${MAKEFILE_DIR}/daq-kube/.kluctl.yaml ## Checkout kube-daq repository
	@echo ""
	@echo "Ensure daq-kube is up to date"
	@cd ${MAKEFILE_DIR}/daq-kube ; git pull ; git submodule update --init

##
### System tests
##
.PHONY: test-shell-utils
test-shell-utils: test-base64-is-working test-find-is-working test-git-exists test-grep-is-working test-jq-is-working test-sed-is-working  ## verify expected shell utils are installed

.PHONY: test-base64-is-working
test-base64-is-working: ## verify `base64` is working
	@echo -e "Checking if \`\033[1mbase64\033[0m\` is installed and workingr"
	@echo | base64 >/dev/null

.PHONY: test-docker-is-working
test-docker-is-working: ## verify `docker` can run images
	@echo -e "Checking if \`\033[1mdocker\033[0m\` is installed and workingr"
	docker run --rm docker.io/library/hello-world:latest >/dev/null

.PHONY: test-find-is-working
test-find-is-working: ## verify `find` is working
	@echo -e "Checking if \`\033[1mfind\033[0m\` is installed and working"
	@find /dev/null >/dev/null

.PHONY: test-git-exists
test-git-exists: ## verify `git` is in path
	@echo -e "Checking if \`\033[1mgit\033[0m\` is installed"
	@which git >/dev/null

.PHONY: test-grep-is-working
test-grep-is-working: ## verify `grep` is working
	@echo -e "Checking if \`\033[1mgrep\033[0m\` is installed and working"
	@echo  "is working" | grep -q is >/dev/null

.PHONY: test-jq-is-working
test-jq-is-working: ## verify `jq` is working
	@echo -e "Checking if \`\033[1mjq\033[0m\` is installed and working"
	@echo '{"jq": "is working"}' | jq . >/dev/null

.PHONY: test-sed-is-working
test-sed-is-working: ## verify `sed` is working
	@echo -e "Checking if \`\033[1msed\033[0m\` is installed and working"
	@echo '' | sed -e 's/ //' >/dev/null
