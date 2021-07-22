SHELL:=/bin/bash
.DEFAULT_GOAL := help

##
## helper variables
##

include .makefile/vars.mk

##
### Setup an installation of Pocket
##

.PHONY: setup.local
setup.local: dependency.docker kind kubectl ## start local setup
	@$(KIND) create cluster --config local/kind.config.yml
	@$(MAKE) --no-print-directory kubectl-apply
	@echo ""
	@$(MAKE) --no-print-directory print-access-creds

.PHONY: setup.openstack
setup.openstack: on-cern-network check_openstack_login terraform ansible dependency.ssh ## create a setup in your openstack account
	cd openstack/terraform && \
	$(TERRAFORM) init -upgrade && \
	TF_VAR_cluster_name=${OS_USERNAME}-pocketdune $(TERRAFORM) apply

	cd openstack/ansible && \
	ansible-playbook -i hosts.yaml playbook.yaml

	cat $(shell find openstack/ansible/admin.conf -type f -name admin.conf) | sed 's|kubernetes-admin@kubernetes|admin@pocketdune|g' | sed 's|kubernetes-admin|pocketdune-admin|g' | sed 's|kubernetes|pocketdune|g' > /tmp/kubeconfig-pocketdune
	KUBECONFIG=~/.kube/config:/tmp/kubeconfig-pocketdune $(KUBECTL) config view --flatten > /tmp/kubeconfig
	cp /tmp/kubeconfig ~/.kube/config
	$(KUBECTL) config use-context 'admin@pocketdune'
	-$(KUBECTL) taint nodes --all node-role.kubernetes.io/master-
	$(MAKE) --no-print-directory kubectl-apply
	$(MAKE) --no-print-directory print-access-creds
	@echo -n "Proxy server available at: socks5"
	@cat ~/.kube/config | grep -Eo '://[a-zA-Z0-9-]*-pocketdune.cern.ch:' | tr -d '\012\015'
	@echo "31000"

.PHONY: kafka.local
kafka.local: dependency.docker kind kubectl external-manifests
	@$(KIND) create cluster --config local/kind.config.yml
	
	@$(KUBECTL) apply -f manifests/proxy-server.yaml ||:
	@$(KUBECTL) apply -f manifests/kubernetes-dashboard-recommended.yaml ||:

	@echo "installing kafka"

	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/ns-kafka-kraft.yaml ||:

	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/kafka.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/kafka-svc.yaml ||:
	#@$(MAKE) --no-print-directory print-access-creds

.PHONY: ers-kafka.local
ers-kafka.local: kafka.local
	@echo "installing ers-kafka"

	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/ns-dunedaqers.yaml ||:

	@>/dev/null 2>&1 $(KUBECTL) -n dunedaqers create secret generic postgres-secrets \
        --from-literal=POSTGRES_USER="admin" \
        --from-literal=POSTGRES_PASSWORD="$(PGPASS)" ||:

	# aspcore needs a different password string
	$(KUBECTL) -n dunedaqers create secret generic aspcore-secrets \
	--from-literal=DOTNETPOSTGRES_PASSWORD="Password=$(PGPASS);" ||:

	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/postgres.yaml
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/postgres-svc.yaml
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dunedaqers/aspcore.yaml
	@$(MAKE) --no-print-directory print-access-creds

.PHONY: kubectl-apply
kubectl-apply: kubectl external-manifests ## apply files in `manifests` using kubectl
	@echo "installing basic services"
	@>/dev/null 2>&1 $(KUBECTL) create ns csi-cvmfs ||:
	@>/dev/null $(KUBECTL) apply -f manifests -f manifests/cvmfs

ifeq ($(OPMON_ENABLED),0)
	@echo -e "\e[33mskipping installation of opmon\e[0m"
else
	@echo "installing opmon"
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/opmon/ns-monitoring.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) -n monitoring create secret generic grafana-secrets \
	--from-literal=GF_SECURITY_SECRET_KEY="$(call random_password)" \
	--from-literal=GF_SECURITY_ADMIN_PASSWORD="$(call random_password)" ||:

	@>/dev/null 2>&1 $(KUBECTL) -n monitoring create secret generic influxdb-secrets \
	--from-literal=INFLUXDB_CONFIG_PATH=/etc/influxdb/influxdb.conf \
	--from-literal=INFLUXDB_DB=influxdb \
	--from-literal=INFLUXDB_URL=http://influxdb.monitoring:8086 \
	--from-literal=INFLUXDB_USER=user \
	--from-literal=INFLUXDB_USER_PASSWORD="$(call random_password)" \
	--from-literal=INFLUXDB_READ_USER=readonly \
	--from-literal=INFLUXDB_READ_USER_PASSWORD=readonly \
	--from-literal=INFLUXDB_ADMIN_USER=dune \
	--from-literal=INFLUXDB_ADMIN_USER_PASSWORD="$(call random_password)" \
	--from-literal=INFLUXDB_HOST=influxdb.monitoring  \
	--from-literal=INFLUXDB_HTTP_AUTH_ENABLED=false ||:

	@>/dev/null $(KUBECTL) apply -f manifests/opmon
endif

ifeq ($(ECK_ENABLED),0)
	@echo -e "\e[33mskipping installation of Elastic stack\e[0m"
else
	@echo "installing Elastic stack"
	@>/dev/null $(KUBECTL) apply -f manifests/ECK/CRDs
	@>/dev/null $(KUBECTL) wait --for condition=established --timeout=60s crd/kibanas.kibana.k8s.elastic.co

	@>/dev/null $(KUBECTL) apply -f manifests/ECK
endif

##
### Destroy any created setups
##

.PHONY: destroy.local
destroy.local: kind ## undo the setup made by `setup.local`
	@$(KIND) delete cluster --name $(shell cat local/kind.config.yml | grep 'name: ' | cut -d ":" -f2)

.PHONY: destroy.openstack
destroy.openstack: check_openstack_login terraform ## undo the setup made by `setup.openstack`
	cd openstack/terraform && \
	$(TERRAFORM) init -upgrade && \
	TF_VAR_cluster_name=${OS_USERNAME}-pocketdune $(TERRAFORM) destroy
	$(KUBECTL) config delete-context 'admin@pocketdune'
	$(KUBECTL) config delete-cluster pocketdune
	$(KUBECTL) config delete-user pocketdune-admin

##
### Helper commands
##

.PHONY: env
env: kubectl ## use `eval $(make env)` to get access to dependency binaries such as kubectl
	@echo "PATH=\"$(EXTERNALS_BIN_FOLDER):$(shell echo $$PATH)\""

.PHONY: topic
topic: env
	@echo "Configuring Kafka Topic erskafka-reporting"
	$(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic erskafka-reporting

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
	@KUBECTL=$(KUBECTL) .makefile/print-creds.sh

##
### Docker images
##

.PHONY: images
images: images.grafana ## build all images

.PHONY: images.grafana
images.grafana: ## build Grafana image
	docker build -t juravenator/pocket-grafana:latest images/grafana
	docker push juravenator/pocket-grafana:latest

##
### Dependencies
##

YUM_HINT.ssh := openssh-clients
YUM_HINT.python3 := rh-python38-python-pip && scl enable rh-python38 "make ..."
YUM_HINT.8.python3 := python38-pip
dependency.%: # check if a dependency is installed
	@command -v $* > /dev/null || $(MAKE) --no-print-directory dependencyhint.$*

.PHONY: dependencyhint.%
dependencyhint.%:
	@echo -e "\e[31m$* is required to run\e[0m"
ifeq ($(OS),centos)
	@echo "Hint: yum install $(or ${YUM_HINT.$(OS_VERSION).$*},${YUM_HINT.$*},$* ?)"
endif
	@exit 1

.PHONY: python3
python3: dependency.python3 # check if python3 is installed
	@python3 --version | awk -F. '{if($$2<8)exit 1}' || (echo -e "\e[31mMinimum Python 3.8 is required\e[0m" && $(MAKE) --no-print-directory dependencyhint.python3)

.PHONY: on-cern-network
on-cern-network:
	@curl --connect-timeout 1 network.cern.ch > /dev/null 2>&1 || (echo -e "\e[31mThe CERN network is not accessible\e[0m" && exit 1)

.PHONY: kind
kind: $(KIND) ## fetch Kubernetes In Docker (KIND) binary
	@$(call symlink,$(KIND),$(KIND_NOVER))
$(KIND):
# do not print to stdout when user runs `make env`
ifneq ($(MAKECMDGOALS),env)
	@echo "downloading KIND $(KIND_VERSION)"
endif
	@curl -Lo $(KIND) --fail --silent https://github.com/kubernetes-sigs/kind/releases/download/v$(KIND_VERSION)/kind-${uname_s}-${COMMON_ARCH}
	@chmod +x $(KIND)

.PHONY: terraform
terraform: $(TERRAFORM) ## fetch Terraform binary
	@$(call symlink,$(TERRAFORM),$(TERRAFORM_NOVER))
$(TERRAFORM):
	@$(MAKE) --no-print-directory dependency.unzip
# do not print to stdout when user runs `make env`
ifneq ($(MAKECMDGOALS),env)
	@echo "downloading terraform $(TERRAFORM_VERSION)"
endif
	@curl -Lo $(TERRAFORM).zip --silent --fail https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${uname_s}_${COMMON_ARCH}.zip
	@cd $(dir $(TERRAFORM)) && unzip -o $(TERRAFORM).zip > /dev/null 2>&1 && touch terraform && mv terraform $(TERRAFORM)
	@rm -rf $(TERRAFORM).zip

.PHONY: ansible
ansible: python3 ## install Ansible
	@command -v ansible-playbook > /dev/null || (python3 -m pip install --upgrade pip && python3 -m pip install ansible)

.PHONY: kubectl
kubectl: $(KUBECTL) ## fetch kubectl binary
	@$(call symlink,$(KUBECTL),$(KUBECTL_NOVER))
$(KUBECTL):
# do not print to stdout when user runs `make env`
ifneq ($(MAKECMDGOALS),env)
	@echo "downloading kubectl $(KUBECTL_VERSION)"
endif
	@curl -Lo $(KUBECTL) --fail --silent https://dl.k8s.io/release/v$(KUBECTL_VERSION)/bin/${uname_s}/${COMMON_ARCH}/kubectl
	@chmod +x $(KUBECTL)

.PHONY: external-manifests
external-manifests: manifests/ECK/CRDs/eck.yaml manifests/kubernetes-dashboard-recommended.yaml manifests/cvmfs/deploy.yaml

manifests/ECK/CRDs/eck.yaml: # fetch the ECK operator
	@curl -Lo $@ --silent --fail https://download.elastic.co/downloads/eck/1.6.0/all-in-one.yaml

manifests/kubernetes-dashboard-recommended.yaml: # fetch kubernetes dashboard manifest
	@curl -Lo $@ --silent --fail https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

manifests/cvmfs/deploy.yaml: # fetch the CVMFS CSI Driver
	@curl -Lo $@ --silent --fail https://raw.githubusercontent.com/Juravenator/cvmfs-csi/master/deployments/kubernetes/deploy.yaml

include .makefile/help.mk
