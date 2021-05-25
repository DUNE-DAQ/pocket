SHELL:=/bin/bash
.DEFAULT_GOAL := help

##
## helper variables
##

# Linux: 'linux'
# MacOS: 'darwin'
uname_s := $(shell uname -s | tr '[:upper:]' '[:lower:]')
# x86_64: 'x86_64'
# Apple M1: 'arm64'
uname_m := $(shell uname -m)

COMMON_ARCH.x86_64 := amd64
COMMON_ARCH := $(or ${COMMON_ARCH.${uname_m}},${uname_m})

OS=unknown
OS_VERSION=unknown

ifeq ($(uname_s),linux)
	PRETTY_NAME := $(shell source /etc/os-release && echo $$PRETTY_NAME)
	ifneq ($(findstring CentOS,$(PRETTY_NAME)),)
		OS=centos
	endif

	ifneq ($(findstring CentOS Linux 7,$(PRETTY_NAME)),)
		OS_VERSION=7
	else ifneq ($(findstring CentOS Linux 8,$(PRETTY_NAME)),)
		OS_VERSION=8
	endif
else ifeq ($(uname_s),darwin)
	OS=macos
endif

TERRAFORM_VERSION ?= 0.15.3
terraform := $(shell pwd)/terraform

##
### Setup an installation of pocketDUNE
##

.PHONY: setup.local
setup.local: kind ## start local setup
	./kind create cluster --config local/kind.config.yml
	$(MAKE) --no-print-directory kubectl-apply
	$(MAKE) --no-print-directory print-access-creds

.PHONY: setup.openstack
setup.openstack: on-cern-network check_openstack_login terraform ansible dependency.ssh ## create a setup in your openstack account
	cd openstack/terraform && \
	${terraform} init -upgrade && \
	TF_VAR_cluster_name=${OS_USERNAME}-pocketdune ${terraform} apply

	cd openstack/ansible && \
	ansible-playbook -i hosts.yaml playbook.yaml

	cat $(shell find openstack/ansible/admin.conf -type f -name admin.conf) | sed 's|kubernetes-admin@kubernetes|admin@pocketdune|g' | sed 's|kubernetes-admin|pocketdune-admin|g' | sed 's|kubernetes|pocketdune|g' > /tmp/kubeconfig-pocketdune
	KUBECONFIG=~/.kube/config:/tmp/kubeconfig-pocketdune kubectl config view --flatten > /tmp/kubeconfig
	cp /tmp/kubeconfig ~/.kube/config
	kubectl config use-context 'admin@pocketdune'
	-kubectl taint nodes --all node-role.kubernetes.io/master-
	$(MAKE) --no-print-directory kubectl-apply
	$(MAKE) --no-print-directory print-access-creds
	@echo -n "Proxy server available at: socks5"
	@cat ~/.kube/config | grep -Eo '://[a-zA-Z0-9-]*-pocketdune.cern.ch:' | tr -d '\012\015'
	@echo "31000"

.PHONY: kubectl-apply
kubectl-apply: kubectl manifests/CRDs/eck.yaml manifests/metricbeat.yaml ## apply files in `manifests` using kubectl
	@-./kubectl create ns monitoring
	@-./kubectl -n monitoring create secret generic grafana-secrets \
  --from-literal=GF_SECURITY_SECRET_KEY=$(shell < /dev/urandom tr -dc _A-Z-a-z-0-9-=%. | head -c$${1:-32};echo;) \
	--from-literal=GF_SECURITY_ADMIN_PASSWORD="$(shell < /dev/urandom tr -dc _A-Z-a-z-0-9-=%. | head -c$${1:-32};echo;)"

	@-kubectl -n monitoring create secret generic influxdb-secrets \
	--from-literal=INFLUXDB_CONFIG_PATH=/etc/influxdb/influxdb.conf \
  --from-literal=INFLUXDB_DB=influxdb \
	--from-literal=INFLUXDB_URL=http://influxdb.monitoring:8086 \
  --from-literal=INFLUXDB_USER=user \
  --from-literal=INFLUXDB_USER_PASSWORD=$(shell < /dev/urandom tr -dc _A-Z-a-z-0-9-=%. | head -c$${1:-32};echo;) \
  --from-literal=INFLUXDB_READ_USER=readonly \
  --from-literal=INFLUXDB_READ_USER_PASSWORD=readonly \
  --from-literal=INFLUXDB_ADMIN_USER=dune \
  --from-literal=INFLUXDB_ADMIN_USER_PASSWORD=$(shell < /dev/urandom tr -dc _A-Z-a-z-0-9-=%. | head -c$${1:-32};echo;) \
  --from-literal=INFLUXDB_HOST=influxdb.monitoring  \
  --from-literal=INFLUXDB_HTTP_AUTH_ENABLED=false

	./kubectl apply -f manifests/CRDs
	./kubectl wait --for condition=established --timeout=60s crd/kibanas.kibana.k8s.elastic.co

	./kubectl apply -f manifests

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
	kubectl config delete-context 'admin@pocketdune'
	kubectl config delete-cluster pocketdune
	kubectl config delete-user pocketdune-admin

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

print-access-creds: kubectl ## retrieve and print access data for provided services
	@echo -n "waiting for ECK to start"
	@while ! ./kubectl -n monitoring get secret dune-eck-es-elastic-user 2>/dev/null >&2 ; do echo -n "."; sleep 1s; done; echo ""
	@echo ""
	@echo -e "\e[34mAvailable services:\e[0m"

	@echo "Elasticsearch"
	@echo "	URL: https://dune-eck-es-http.monitoring:9200/"
	@echo "	User: elastic"
	@echo -n "	Password: "
	@./kubectl get -n monitoring secret dune-eck-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

	@echo "Kibana"
	@echo "	URL: https://dune-eck-kb-http.monitoring:5601/"
	@echo "	User: elastic"
	@echo -n "	Password: "
	@./kubectl get -n monitoring secret dune-eck-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode; echo

	@echo "Grafana"
	@echo "	URL: http://grafana.monitoring:3000/"
	@echo "	User: dune"
	@echo -n "	Password: "
	@./kubectl get -n monitoring secret grafana-secrets -o=jsonpath='{.data.GF_SECURITY_ADMIN_PASSWORD}' | base64 --decode; echo

	@echo "InfluxDB"
	@echo "	URL: http://influxdb.monitoring:8086/"
	@echo "	User: readonly"
	@echo "	Password: readonly"
	@echo "	User: user"
	@echo -n "	Password: "
	@./kubectl get -n monitoring secret influxdb-secrets -o=jsonpath='{.data.INFLUXDB_USER_PASSWORD}' | base64 --decode; echo
	@echo "	User: dune"
	@echo -n "	Password: "
	@./kubectl get -n monitoring secret influxdb-secrets -o=jsonpath='{.data.INFLUXDB_ADMIN_USER_PASSWORD}' | base64 --decode; echo

##
### Docker images
##

.PHONY: images
images: images.grafana ## build all images

.PHONY: images.grafana
images.grafana: ## build Grafana image
	docker build -t juravenator/pocket-grafana:latest stuff/grafana
	docker push juravenator/pocket-grafana:latest

##
### Dependencies
##

YUM_HINT.ssh := openssh-clients
YUM_HINT.python3 := rh-python38-python-pip && scl enable rh-python38 "make ..."
YUM_HINT.8.python3 := python38-pip
dependency.%: # check if a dependency is installed
	@command -v $(subst dependency.,,$@) > /dev/null || $(MAKE) --no-print-directory dependencyhint.$(subst dependency.,,$@)

.PHONY: dependencyhint.%
dependencyhint.%:
	@echo -e "\e[31m$(subst dependencyhint.,,$@) is required to run\e[0m"
ifeq ($(OS),centos)
	@echo "Hint: yum install $(or ${YUM_HINT.$(OS_VERSION).$(subst dependencyhint.,,$@)},${YUM_HINT.$(subst dependencyhint.,,$@)},$(subst dependencyhint.,,$@) ?)"
endif
	@exit 1

.PHONY: python3
python3: dependency.python3 # check if python3 is installed
	@python3 --version | awk -F. '{if($$2<8)exit 1}' || (echo -e "\e[31mMinimum Python 3.8 is required\e[0m" && $(MAKE) --no-print-directory dependencyhint.python3)

.PHONY: on-cern-network
on-cern-network:
	@curl --connect-timeout 1 network.cern.ch > /dev/null 2>&1 || (echo -e "\e[31mThe CERN network is not accessible\e[0m" && exit 1)

kind: ## fetch Kubernetes In Docker (KIND) binary
	curl -Lo ./kind --fail https://github.com/kubernetes-sigs/kind/releases/download/v0.11.0/kind-${uname_s}-${COMMON_ARCH}
	chmod +x ./kind

terraform: ## fetch Terraform binary
	@$(MAKE) --no-print-directory dependency.unzip
	curl -Lo terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${uname_s}_${COMMON_ARCH}.zip
	unzip -o terraform.zip
	rm -rf terraform.zip

.PHONY: ansible
ansible: python3 ## install Ansible
	@command -v ansible-playbook > /dev/null || (python3 -m pip install --upgrade pip && python3 -m pip install ansible)

kubectl: ## fetch kubectl binary
	curl -LO --fail https://dl.k8s.io/release/v1.21.0/bin/${uname_s}/${COMMON_ARCH}/kubectl
	chmod +x kubectl

manifests/metricbeat.yaml: # fetch metricbeats manifest
	curl -Lo manifests/metricbeat.yaml --fail https://raw.githubusercontent.com/elastic/beats/7.12/deploy/kubernetes/metricbeat-kubernetes.yaml

manifests/CRDs/eck.yaml: # fetch the ECK operator
	curl -Lo manifests/CRDs/eck.yaml --fail https://download.elastic.co/downloads/eck/1.6.0/all-in-one.yaml

include .makefile/help.mk