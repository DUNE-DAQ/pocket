${MY_BINDIR}/kind-${KIND_VERSION}:
	@mkdir -p ${MY_BINDIR}
	@if [ "${KIND_VERSION}" = "latest" ]; then \
		KIND_VERSION=$$(curl -Lfs https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq '.tag_name' | tr -d '"'); \
	fi
	@echo "Downloading kind ${KIND_VERSION} for ${OS} ${PLATFORM}..."
	@echo "  https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${OS}-${PLATFORM}"
	@curl -Lfs https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${OS}-${PLATFORM} -o ${MY_BINDIR}/kind-${KIND_VERSION}
	@chmod +x ${MY_BINDIR}/kind-${KIND_VERSION}
${MY_BINDIR}/kind: ${MY_BINDIR}/kind-${KIND_VERSION}
	@ln -sf ${MY_BINDIR}/kind-${KIND_VERSION} ${MY_BINDIR}/kind
