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
# Windows: 'msys_nt-10.0-19042'
# Windows: 'windows_nt', 'mingw64_nt-10.0-17763', 'msys_nt-6.1', 'windowsnt'
uname_s := $(shell uname -s | tr '[:upper:]' '[:lower:]')
# x86_64: 'x86_64'
# Apple M1: 'arm64'
uname_m := $(shell uname -m)

COMMON_ARCH.x86_64 := amd64
COMMON_ARCH := $(or ${COMMON_ARCH.${uname_m}},${uname_m})

COMMON_SYSTEM := $(uname_s)
ifneq ($(findstring msys_nt,$(uname_s)),)
COMMON_SYSTEM=windows
endif

CURL=curl
ifeq ($(COMMON_SYSTEM),windows)
CURL=curl.exe
endif

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

# $(shell pwd) is compatible with everything except windows
EXTERNALS_BIN_FOLDER ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST)))../)/external/bin

TERRAFORM_VERSION ?= 0.15.3
TERRAFORM_NOVER := $(EXTERNALS_BIN_FOLDER)/terraform
TERRAFORM := $(TERRAFORM_NOVER)-$(TERRAFORM_VERSION)
ifeq ($(COMMON_SYSTEM),windows)
TERRAFORM_NOVER := $(TERRAFORM_NOVER).exe
TERRAFORM := $(TERRAFORM).exe
endif

KIND_VERSION ?= 0.11.1
KIND_NOVER := $(EXTERNALS_BIN_FOLDER)/kind
KIND := $(KIND_NOVER)-$(KIND_VERSION)
ifeq ($(COMMON_SYSTEM),windows)
KIND_NOVER := $(KIND_NOVER).exe
KIND := $(KIND).exe
endif

KUBECTL_VERSION ?= 1.21.1
KUBECTL_NOVER := $(EXTERNALS_BIN_FOLDER)/kubectl
KUBECTL := $(KUBECTL_NOVER)-$(KUBECTL_VERSION)
ifeq ($(COMMON_SYSTEM),windows)
KUBECTL_NOVER := $(KUBECTL_NOVER).exe
KUBECTL := $(KUBECTL).exe
endif


##
## Helper functions
##

define random_password
$(shell head -c32 <(tr -dc _A-Z-a-z-0-9-=%. < /dev/urandom 2> /dev/null))
endef