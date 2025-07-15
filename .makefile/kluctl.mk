${MY_BINDIR}/kluctl: test-jq-is-working
	@mkdir -p ${MY_BINDIR}
	@echo ""
	@echo -e "Finding latest version of \033[1mkluctl\033[0m..."
	$(eval KLUCTL_VERSION=$(shell curl -Lfs https://api.github.com/repos/kluctl/kluctl/releases/latest | jq '.tag_name' | tr -d '"'))
	@echo -e "Downloading \033[1mkluctl\033[0m ${KLUCTL_VERSION} for ${OS} ${PLATFORM}..."
	@curl -Lfs https://github.com/kluctl/kluctl/releases/download/${KLUCTL_VERSION}/kluctl_${KLUCTL_VERSION}_${OS}_${PLATFORM}.tar.gz -o ${MY_BINDIR}/kluctl-${KLUCTL_VERSION}.tar.gz
	@cd ${MY_BINDIR} ; tar xf ${MY_BINDIR}/kluctl-${KLUCTL_VERSION}.tar.gz
	@cd ${MY_BINDIR} ; mv kluctl kluctl-${KLUCTL_VERSION}
	@chmod +x ${MY_BINDIR}/kluctl-${KLUCTL_VERSION}
	@ln -sf ${MY_BINDIR}/kluctl-${KLUCTL_VERSION} ${MY_BINDIR}/kluctl
