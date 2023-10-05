${MY_BINDIR}/kind-${KIND_VERSION}:
	@mkdir -p ${MY_BINDIR}
	@echo "Downloading kind..."
	@curl -Lfs https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${OS}-${PLATFORM} -o ${MY_BINDIR}/kind-${KIND_VERSION}
	@chmod +x ${MY_BINDIR}/kind-${KIND_VERSION}
${MY_BINDIR}/kind: ${MY_BINDIR}/kind-${KIND_VERSION}
	@ln -sf ${MY_BINDIR}/kind-${KIND_VERSION} ${MY_BINDIR}/kind
