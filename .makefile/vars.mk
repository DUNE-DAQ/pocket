
##
## Services to install
##
SERVICES ?= ECK,opmon

ifeq ($(findstring opmon,$(SERVICES)),)
	OPMON_ENABLED=0
else
	OPMON_ENABLED=1
endif

ifeq ($(findstring ECK,$(SERVICES)),)
	ECK_ENABLED=0
else
	ECK_ENABLED=1
endif

##
## Helper variables so we download the right binaries for your machine
##
# Linux: 'linux'
# MacOS: 'darwin'
uname_s := $(shell uname -s | tr '[:upper:]' '[:lower:]')
# x86_64: 'x86_64'
# Apple M1: 'arm64'
uname_m := $(shell uname -m)

COMMON_ARCH.x86_64 := amd64
COMMON_ARCH := $(or ${COMMON_ARCH.${uname_m}},${uname_m})

OS=unknown
OS_VERSION=unknown

ifeq ($(uname_s),linux)
	PRETTY_NAME := $(shell source /etc/os-release && echo $$PRETTY_NAME)
	ifneq ($(findstring CentOS,$(PRETTY_NAME)),)
		OS=centos
	endif

	ifneq ($(findstring CentOS Linux 7,$(PRETTY_NAME)),)
		OS_VERSION=7
	else ifneq ($(findstring CentOS Linux 8,$(PRETTY_NAME)),)
		OS_VERSION=8
	endif
else ifeq ($(uname_s),darwin)
	OS=macos
endif

##
## Version information and locations of external binaries
##

EXTERNALS_BIN_FOLDER ?= $(shell pwd)/external/bin

TERRAFORM_VERSION ?= 0.15.3
TERRAFORM_NOVER := $(EXTERNALS_BIN_FOLDER)/terraform
TERRAFORM := $(TERRAFORM_NOVER)-$(TERRAFORM_VERSION)

KIND_VERSION ?= 0.11.1
KIND_NOVER := $(EXTERNALS_BIN_FOLDER)/kind
KIND := $(KIND_NOVER)-$(KIND_VERSION)

KUBECTL_VERSION ?= 1.21.1
KUBECTL_NOVER := $(EXTERNALS_BIN_FOLDER)/kubectl
KUBECTL := $(KUBECTL_NOVER)-$(KUBECTL_VERSION)
