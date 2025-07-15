${MY_BINDIR}/kluctl: test-jq-is-working
	@mkdir -p ${MY_BINDIR}
	@echo ""
	@echo "Finding latest version of kluctl..."

	@ARCH=$$(uname -m); \
	if [ "$$ARCH" = "x86_64" ]; then \
		KEY="darwin_amd64"; \
	elif [ "$$ARCH" = "arm64" ]; then \
		KEY="darwin_arm64"; \
	else \
		echo "Unsupported architecture: $$ARCH"; exit 1; \
	fi; \
	KLUCTL_URL=$$(curl -s https://api.github.com/repos/kluctl/kluctl/releases/latest | \
		jq -r ".assets[] | select(.name | test(\"$$KEY\")) | .browser_download_url"); \
	if [ -z "$$KLUCTL_URL" ]; then \
		echo "Error: no matching release asset found for $$KEY"; exit 1; \
	fi; \
	echo "Downloading binary with key $$KEY from $$KLUCTL_URL..."; \
	curl -L $$KLUCTL_URL -o ${MY_BINDIR}/kluctl; \
	chmod +x ${MY_BINDIR}/kluctl

test-jq-is-working:
	@command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required but not installed."; exit 1; }

