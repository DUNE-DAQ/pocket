${MY_BINDIR}/kluctl: | test-jq-is-working
	@mkdir -p ${MY_BINDIR}
	@echo ""
	@if [ "${KLUCTL_VERSION}" = "latest" ]; then \
		KLUCTL_VERSION=$$(curl -Lfs https://api.github.com/repos/kluctl/kluctl/releases/latest | jq '.tag_name' | tr -d '"'); \
	fi
	@echo -e "Downloading \033[1mkluctl\033[0m ${KLUCTL_VERSION} for ${OS} ${PLATFORM}..."
	@echo "  https://github.com/kluctl/kluctl/releases/download/${KLUCTL_VERSION}/kluctl_${KLUCTL_VERSION}_${OS}_${PLATFORM}.tar.gz"
	@curl -Lf https://github.com/kluctl/kluctl/releases/download/${KLUCTL_VERSION}/kluctl_${KLUCTL_VERSION}_${OS}_${PLATFORM}.tar.gz -o ${MY_BINDIR}/kluctl-${KLUCTL_VERSION}.tar.gz
	@cd ${MY_BINDIR} ; tar xf ${MY_BINDIR}/kluctl-${KLUCTL_VERSION}.tar.gz
	@cd ${MY_BINDIR} ; mv kluctl kluctl-${KLUCTL_VERSION}
	@chmod +x ${MY_BINDIR}/kluctl-${KLUCTL_VERSION}
	@ln -sf ${MY_BINDIR}/kluctl-${KLUCTL_VERSION} ${MY_BINDIR}/kluctl
