${MAKEFILE_DIR}/daq-kube/.kluctl.yaml:
	@echo "Fetching daq-kube repo..."
	@cd ${MAKEFILE_DIR} && git clone  https://github.com/DUNE-DAQ/daq-kube.git --recursive
