${MAKEFILE_DIR}/daq-kube/.kluctl.yaml:
	@echo "Fetching daq-kube repo..."
	@echo "  git clone https://github.com/DUNE-DAQ/daq-kube.git --recursive --depth 1"
	@cd ${MAKEFILE_DIR} && git clone https://github.com/DUNE-DAQ/daq-kube.git --recursive --depth 1
