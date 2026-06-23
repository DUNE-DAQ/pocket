${MY_BINDIR}/helm: | test-jq-is-working
	@mkdir -p ${MY_BINDIR}
	@echo ""
	@echo -e "Finding latest version of \033[1mhelm\033[0m..."
	$(eval HELM_VERSION=$(shell curl -Lfs https://api.github.com/repos/helm/helm/releases/latest | jq '.tag_name' | tr -d '"'))
	@echo -e "Downloading \033[1mhelm\033[0m ${HELM_VERSION} for ${OS} ${PLATFORM}..."
	@echo "  https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${PLATFORM}.tar.gz"
	@curl -Lf https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${PLATFORM}.tar.gz -o ${MY_BINDIR}/helm-${HELM_VERSION}.tar.gz
	@cd ${MY_BINDIR} ; tar xf ${MY_BINDIR}/helm-${HELM_VERSION}.tar.gz
	@cd ${MY_BINDIR} ; mv ${OS}-${PLATFORM}/helm helm-${HELM_VERSION}
	@chmod +x ${MY_BINDIR}/helm-${HELM_VERSION}
	@ln -sf ${MY_BINDIR}/helm-${HELM_VERSION} ${MY_BINDIR}/helm
