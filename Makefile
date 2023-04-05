SHELL:=/bin/bash
.DEFAULT_GOAL := help

##
## helper variables
##

include .makefile/vars.mk

##
### Setup an installation of Pocket
#

.PHONY: setup.local
setup.local: dependency.docker kind kubectl share/ ## start local setup
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


.PHONY: namespaces.local
namespaces.local: kind kubectl external-manifests
	@echo "setting up namespaces"
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/cvmfs/ns-cvmfs.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/kafka/ns-kafka-kraft.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/opmon/ns-monitoring.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/postgres/ns-ers.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/dqm-django/ns-dqm.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/daqconfig/ns-daqconfig.yaml ||:


.PHONY: kafka2influx.local
kafka2influx.local: kafka.local influx.local
	@echo "Connecting kafka to influxdb"

	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/opmon/kafka2influx.yaml ||:


.PHONY: kafka.local
kafka.local: dependency.docker kind kubectl external-manifests namespaces.local
	@echo "installing kafka"
	@echo -n "setting advertised listener to "
	@echo "$(call node_ip)"
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft create secret generic kafka-secrets \
	--from-literal=EXTERNAL_LISTENER="$(call node_ip)" ||:

	$(KUBECTL) -n kafka-kraft create configmap dune-kafka-libs --from-file images/kafka/jmx_prometheus_javaagent-0.16.1.jar ||:
	$(KUBECTL) -n kafka-kraft create configmap dune-kafka-config --from-file images/kafka/sample_jmx_exporter.yml ||:

	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/kafka/kafka.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/kafka/kafka-svc.yaml ||:


.PHONY: erspostgres.local
erspostgres.local: kind kubectl external-manifests namespaces.local
	@echo "installing postgres"

	$(KUBECTL) -n ers create secret generic postgres-secrets \
	--from-literal=POSTGRES_USER="admin" \
	--from-literal=POSTGRES_PASSWORD="$(PGPASS)" ||:

	$(KUBECTL) -n monitoring create secret generic postgres-secrets \
	--from-literal=POSTGRES_USER="admin" \
	--from-literal=POSTGRES_PASSWORD="$(PGPASS)" ||:

	@>/dev/null 2>&1 $(KUBECTL) -n ers create configmap ers-sql --from-file manifests/postgres/sql/ApplicationDbErrorReporting.sql ||:
	$(KUBECTL) apply -f manifests/postgres/postgres-pv.yaml ||:
	$(KUBECTL) apply -f manifests/postgres/postgres-pvc.yaml ||:
	$(KUBECTL) apply -f manifests/postgres/ers-postgres.yaml ||:
	$(KUBECTL) apply -f manifests/postgres/ers-postgres-svc.yaml ||:


.PHONY: ers.local
ers.local: kafka.local erspostgres.local #grafana.local
	@echo "installing ers-kafka"

	@>/dev/null 2>&1 $(KUBECTL) -n monitoring create secret generic ers-secret \
	--from-literal=ERS_DBWRITER_KAFKA_HOST=kafka-svc.kafka-kraft \
	--from-literal=ERS_DBWRITER_KAFKA_PORT=9092 \
	--from-literal=ERS_DBWRITER_HOST="postgres-svc.ers" \
	--from-literal=ERS_DBWRITER_PORT="5432" \
	--from-literal=ERS_DBWRITER_USER="admin" \
	--from-literal=ERS_DBWRITER_PASS="$(PGPASS)" \
	--from-literal=ERS_DBWRITER_NAME="ApplicationDbErrorReporting" ||:
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/ers/ers-dbwriter.yaml ||:


.PHONY: dqm.local
dqm.local:
	@echo "installing dqm backend"
	$(KUBECTL) -n dqm create secret generic dqm-secrets \
	--from-literal=USERNAME=admin \
	--from-literal=PASSWORD=admin \
	--from-literal=ALLOWED_HOSTS=$(call node_ip) \
	--from-literal=PATH_DATABASE=/mnt/data/Database/ \
	--from-literal=PATH_DATABASE_RESULTS=/mnt/data/Database-results/ \
	--from-literal=REDIS_HOST=dqm-redis-svc.dqm \
	--from-literal=KAFKA_HOST=kafka-svc.kafka-kraft \
	--from-literal=KAFKA_PORT=9092 ||:
	$(KUBECTL) apply -f manifests/dqm-django/dqm-pv.yaml ||:
	$(KUBECTL) apply -f manifests/dqm-django/dqm-pv-claim.yaml ||:
	$(KUBECTL) apply -f manifests/dqm-django/dqm-redis-backend.yaml ||:
	$(KUBECTL) apply -f manifests/dqm-django/dqm-backend.yaml ||:

.PHONY: daqconfig.local
daqconfig.local: daqconfig-mongo.local
	@echo "installing config service"
	@>/dev/null 2>&1 $(KUBECTL) apply -f manifests/daqconfig/daqconfig-svc.yaml ||:


.PHONY: daqconfig-mongo.local
daqconfig-mongo.local: kind kubectl external-manifests namespaces.local
	@echo "installing mongodb"
	@>/dev/null 2>&1 $(KUBECTL) -n daqconfig create secret generic mongodb-root --from-literal=password="${MONGOPASS}" --from-literal=user="mongo_user" ||:
	@>/dev/null 2>&1 $(KUBECTL) create -f manifests/daqconfig/volume-claim.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) create -f manifests/daqconfig/persistent-volume-claim.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) create -f manifests/daqconfig/mongodb-statefulset.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) create -f manifests/daqconfig/mongodb-nodeport-svc.yaml ||:
	@>/dev/null 2>&1 $(KUBECTL) create -f manifests/daqconfig/mongo-express-deployment.yaml ||:


.PHONY: grafana.local
grafana.local: dependency.docker kind kubectl external-manifests namespaces.local helm
	@echo "installing grafana"

	$(KUBECTL) -n monitoring create secret generic grafana-secrets \
	--from-literal=GF_SECURITY_SECRET_KEY="${GF_SECURITY_SECRET_KEY}" \
	--from-literal=GF_SECURITY_ADMIN_PASSWORD="${GF_SECURITY_ADMIN_PASSWORD}" ||:

	$(KUBECTL) -n monitoring create configmap grafana-datasources \
		--from-file=manifests/opmon/grafana/datasources/ ||:

	$(KUBECTL) -n monitoring create configmap grafana-dashboards \
		--from-file=manifests/opmon/grafana/grafana-dashboards/dashboards/pocket-dashboards ||:

	$(KUBECTL) -n monitoring create configmap dashboard-provisioning \
		--from-file=manifests/opmon/grafana/provisioning/ ||:

#	For Future when we have Grafana working
#	$(HELM) -n monitoring install grafana grafana/grafana -f manifests/grafana-dashboards/values.yaml

	@>/dev/null $(KUBECTL) apply -f manifests/opmon/grafana/grafana.yaml


.PHONY: influx.local
influx.local: dependency.docker kind kubectl 
	@echo "installing influx"

	@>/dev/null 2>&1 $(KUBECTL) -n monitoring create secret generic influxdb-secrets \
	--from-literal=INFLUXDB_CONFIG_PATH=/etc/influxdb/influxdb.conf \
	--from-literal=INFLUXDB_DB=influxdb \
	--from-literal=INFLUXDB_URL=http://influxdb.monitoring:8086 \
	--from-literal=INFLUXDB_USER=user \
	--from-literal=INFLUXDB_USER_PASSWORD="${INFLUXDB_USER_PASSWORD}" \
	--from-literal=INFLUXDB_READ_USER=readonly \
	--from-literal=INFLUXDB_READ_USER_PASSWORD=readonly \
	--from-literal=INFLUXDB_ADMIN_USER=dune \
	--from-literal=INFLUXDB_ADMIN_USER_PASSWORD="${INFLUXDB_ADMIN_USER_PASSWORD}" \
	--from-literal=INFLUXDB_HOST=influxdb.monitoring  \
	--from-literal=INFLUXDB_HTTP_AUTH_ENABLED=false ||:

	@>/dev/null $(KUBECTL) apply -f manifests/opmon/influx/

.PHONY: opmon.local
opmon.local: kafka.local influx.local kafka2influx.local grafana.local
	@echo "installing opmon"

.PHONY: kubectl-apply
kubectl-apply: kubectl external-manifests namespaces.local ## apply files in `manifests` using kubectl

	@echo "installing basic services"
	@>/dev/null $(KUBECTL) apply -f manifests


ifeq ($(ERS_ENABLED),0)
	@echo -e "\e[33mskipping installation of Kafka-ERS\e[0m"
else
	@$(MAKE) --no-print-directory ers.local
	@$(MAKE) --no-print-directory ers-topic
endif

ifeq ($(OPMON_ENABLED),0)
	@echo -e "\e[33mskipping installation of opmon\e[0m"
else
	@$(MAKE) --no-print-directory opmon.local
endif

ifeq ($(DQM_ENABLED),0)
	@echo -e "\e[33mskipping installation of DQM\e[0m"
else
	@$(MAKE) --no-print-directory dqm.local
endif

ifeq ($(DAQCONFIG_ENABLED),0)
	@echo -e "\e[33mskipping installation of DAQConfig\e[0m"
else
	@$(MAKE) --no-print-directory daqconfig.local
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

.PHONY: ers-topic
ers-topic: env
	@echo "Configuring Kafka Topic erskafka-reporting"
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic erskafka-reporting ||:

.PHONY: dqm-topic
dqm-topic: env
	@echo "Configuring topics for DQM"
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic testdunedqm ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic kafkaopmon-reporting ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic dune-dqm-messenger ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic dune-dqm-messages ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic dunedqm-incommingchannel1 ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic dunedqm-incommingchannel2 ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic dunedqm-platforminputs ||:
	@>/dev/null 2>&1 $(KUBECTL) -n kafka-kraft exec --stdin --tty kafka-0 -- kafka-topics.sh --create --bootstrap-server kafka-svc.kafka-kraft:9092 --partitions 1 --topic dunedqm-processedchannel1 ||:

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
images: images.grafana images.kafka images.ers images.dqmplatform #images.dqmanalysis ## build all images

.PHONY: images.grafana
images.grafana: ## build Grafana image
	docker buildx build -t dunedaq/pocket-grafana:v1.0.1 images/grafana
# 	docker push juravenator/pocket-grafana:latest

.PHONY: images.kafka
images.kafka: ## build kafka image
	docker buildx build -t dunedaq/pocket-kraft:1.0 images/kafka

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

.PHONY: helm
helm: $(HELM) ## fetch helm binary
	@$(call symlink,$(HELM),$(HELM_NOVER))
$(HELM):
# do not print to stdout when user runs `make env`
ifneq ($(MAKECMDGOALS),env)
	@echo "downloading helm $(HELM_VERSION)"
endif
	@mkdir ${EXTERNALS_BIN_FOLDER}/helm_temp
	@curl -Lo ${EXTERNALS_BIN_FOLDER}/helm_temp/helm-v${HELM_VERSION}-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz 
	@tar xf ${EXTERNALS_BIN_FOLDER}/helm_temp/helm-v${HELM_VERSION}-linux-amd64.tar.gz -C ${EXTERNALS_BIN_FOLDER}/helm_temp
	@mv ${EXTERNALS_BIN_FOLDER}/helm_temp/linux-amd64/helm ${HELM}

.PHONY: external-manifests
external-manifests: manifests/kubernetes-dashboard-recommended.yaml manifests/cvmfs/deploy.yaml

manifests/kubernetes-dashboard-recommended.yaml: # fetch kubernetes dashboard manifest
	@curl -Lo $@ --silent --fail https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

manifests/cvmfs/deploy.yaml: # fetch the CVMFS CSI Driver
	@curl -Lo $@ --silent --fail https://raw.githubusercontent.com/Juravenator/cvmfs-csi/master/deployments/kubernetes/deploy.yaml

share/:
	@mkdir -p $@

include .makefile/help.mk

