SHELL:=/bin/bash
.DEFAULT_GOAL := help

# Linux: 'linux'
# MacOS: 'darwin'
uname_s := $(shell uname -s | tr '[:upper:]' '[:lower:]')
# x86_64: 'x86_64'
# Apple M1: 'arm64'
uname_m := $(shell uname -m)

KIND_ARCH.x86_64 := amd64
KIND_ARCH := $(or ${KIND_ARCH.${uname_m}},${uname_m})

TERRAFORM_VERSION ?= 0.15.3
terraform := $(shell pwd)/terraform

##
### Setup an installation of pocketDUNE
##

.PHONY: setup.local
setup.local: kind ## start local setup
	./kind create cluster --config local/kind.config.yml
	$(MAKE) kubectl-apply

.PHONY: setup.openstack
setup.openstack: check_openstack_login terraform ansible dependency.ssh ## create a setup in your openstack account
	cd openstack/terraform && \
	${terraform} init -upgrade && \
	TF_VAR_cluster_name=${OS_USERNAME}-pocketdune ${terraform} apply

	cd openstack/ansible && \
	ansible-playbook -i hosts.yaml playbook.yaml

	$(MAKE) kubectl-apply
#	KUBECONFIG=~/.kube/config:pocketdune.yml kubectl config view --flatten > /tmp/kubeconfig
#	cp /tmp/kubeconfig ~/.kube/config
#	kubectl config use-context openstack-pocket

##
### Destroy any created setups
##

.PHONY: destroy.local
destroy.local: kind ## undo the setup made by `setup.local`
	./kind delete cluster --name $(shell cat local/kind.config.yml | grep 'name: ' | cut -d ":" -f2)

.PHONY: destroy.openstack
destroy.openstack: check_openstack_login terraform ## undo the setup made by `setup.openstack`
	cd openstack/terraform && \
	${terraform} init -upgrade && \
	TF_VAR_cluster_name=${OS_USERNAME}-pocketdune ${terraform} destroy

##
### Helper commands
##

.PHONY: check_openstack_login
check_openstack_login:
ifndef OS_PASSWORD
	@echo -e "\e[31mOpenStack credentials file is not sourced\e[0m"
	@echo "Please source your openstack credentials file before running me (\`source my-openstack-rc.sh\`)"
	@echo "Download your RC file at https://openstack.cern.ch > Tools (button on the top right) > OpenStack RC File"
	@echo ""
	@exit 1
endif

.PHONY: python3
python3: # check if python3 is installed
	@command -v python3 > /dev/null || (echo -e "\e[31mPython 3.8 is required (\`yum install rh-python38-python-pip && scl enable rh-python38 \"make ...\"\`, \`dnf install python38-pip\`)\e[0m" && exit 1)
	@python3 --version | awk -F. '{if($$2<8)exit 1}' || (echo -e "\e[31mPython 3.8 is required (\`yum install rh-python38-python-pip && scl enable rh-python38 \"make ...\"\`, \`dnf install python38-pip\`)\e[0m" && exit 1)

kind: ## fetch Kubernetes In Docker (KIND) binary
	curl -Lo ./kind --fail https://github.com/kubernetes-sigs/kind/releases/download/v0.11.0/kind-${uname_s}-${KIND_ARCH}
	chmod +x ./kind

terraform: ## fetch Terraform binary
	@$(MAKE) dependency.unzip
	curl -Lo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${uname_s}_${KIND_ARCH}.zip
	unzip -o terraform.zip
	rm -rf terraform.zip

.PHONY: ansible
ansible: python3 ## install Ansible
	@command -v ansible-playbook > /dev/null || (python3 -m pip install --upgrade pip && python3 -m pip install ansible)

dependency.%: # check if a dependency is installed
	@command -v $(subst dependency.,,$@) > /dev/null || (echo -e "\e[31m$(subst dependency.,,$@) is required to run\e[0m" && exit 1)

.PHONY: kubectl-apply
kubectl-apply: ## apply files in `manifests` using kubectl
	kubectl apply -Rf manifests

.PHONY: clean
clean:
	rm -rf ./kind ./terraform


include .makefile/help.mk