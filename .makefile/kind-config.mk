# this is crazy ugly, but cat <<EOF is inconsistent
# between Linux and MacOS make parsing
${MY_KIND_CLUSTER_CONFIG}: remove-kind-config get-kube-daq
	@mkdir -p ${MY_PERSISTENT_STORAGE}
	@echo ""
	@echo "Writing kind cluster config line by line..."
	@mkdir -p ${MY_CONFIGDIR}
	@echo "---" > ${MY_KIND_CLUSTER_CONFIG}
	@echo "apiVersion: kind.x-k8s.io/v1alpha4" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "kind: Cluster" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "name: ${KIND_CLUSTER_NAME}" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "networking:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  ipFamily: ipv4" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  podSubnet: 10.244.0.0/16" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  serviceSubnet: 10.96.0.0/12" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  disableDefaultCNI: False" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "kubeadmConfigPatches:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "- |-" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  kind: ClusterConfiguration" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  controllerManager:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    extraArgs:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      bind-address: 0.0.0.0" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  etcd:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    local:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      extraArgs:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "        listen-metrics-urls: http://0.0.0.0:2381" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  scheduler:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    extraArgs:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      bind-address: 0.0.0.0" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "- |-" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  kind: KubeProxyConfiguration" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  metricsBindAddress: 0.0.0.0" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "- |-" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  apiVersion: kubelet.config.k8s.io/v1beta1" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  kind: KubeletConfiguration" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  ProtectKernelDefaults: true" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  serverTLSBootstrap: true" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  rotateCertificates: true" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  failSwapOn: false" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "- |-" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  apiVersion: kubeadm.k8s.io/v1beta3" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  kind: ClusterConfiguration" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  clusterName: ${KIND_CLUSTER_NAME}" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  apiServer:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    extraArgs:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      enable-aggregator-routing: \"true\"" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      enable-bootstrap-token-auth: \"true\"" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      authorization-mode: \"Node,RBAC\"" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      profiling: \"true\"" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "nodes:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "- role: control-plane" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  image: ${KIND_NODE_VERSION}" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  kubeadmConfigPatches:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  - |-" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    apiVersion: kubeadm.k8s.io/v1beta3" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    kind: InitConfiguration" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    nodeRegistration:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "      kubeletExtraArgs:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "        node-labels: "ingress-ready=true"" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  extraPortMappings:" >> ${MY_KIND_CLUSTER_CONFIG}
	@for port in $$(cd ${MAKEFILE_DIR}/daq-kube/dune_daq_services/node-ports && grep nodePort * | cut -d':' -f3 | sort -n | grep -v nodePort); do echo "  - containerPort: $$port" >> ${MY_KIND_CLUSTER_CONFIG}; echo "    hostPort: $$port" >> ${MY_KIND_CLUSTER_CONFIG}; done
	@echo "" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "- role: worker" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  image: ${KIND_NODE_VERSION}" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  extraMounts:" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "  - hostPath: ${MY_PERSISTENT_STORAGE}" >> ${MY_KIND_CLUSTER_CONFIG}
	@echo "    containerPath: /var/local-path-provisioner" >> ${MY_KIND_CLUSTER_CONFIG}
