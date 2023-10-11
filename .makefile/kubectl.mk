${MAKEFILE_DIR}/bin/kubectl-${KUBERNETES_VERSION}:
	@mkdir -p ${MY_BINDIR}
	@echo "Dowloading kubectl..."
	@curl -Lf https://dl.k8s.io/release/${KUBERNETES_VERSION}/bin/${OS}/${PLATFORM}/kubectl -o ${MY_BINDIR}/kubectl-${KUBERNETES_VERSION}
	@chmod +x ${MY_BINDIR}/kubectl-${KUBERNETES_VERSION}
${MAKEFILE_DIR}/bin/kubectl: ${MAKEFILE_DIR}/bin/kubectl-${KUBERNETES_VERSION}
	@ln -sf ${MY_BINDIR}/kubectl-${KUBERNETES_VERSION} ${MY_BINDIR}/kubectl
