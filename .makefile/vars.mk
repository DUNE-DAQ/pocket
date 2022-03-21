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


##
## Services to install
##
SERVICES ?= ""

ifeq ($(findstring cvmfs,$(SERVICES)),)
	CVMFS_ENABLED=0
else
	CVMFS_ENABLED=1
endif

ifeq ($(findstring opmon,$(SERVICES)),)
	OPMON_ENABLED=0
else
	OPMON_ENABLED=1
endif

ifeq ($(findstring ers,$(SERVICES)),)
	ERS_ENABLED=0
else
	ERS_ENABLED=1
endif

ifeq ($(findstring dqm,$(SERVICES)),)
	DQM_ENABLED=0
else
	DQM_ENABLED=1
endif

ifeq ($(findstring daqconfig,$(SERVICES)),)
	DAQCONFIG_ENABLED=0
else
	DAQCONFIG_ENABLED=1
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
## Helper functions
##

define random_password
$(shell head -c32 <(tr -dc _A-Z-a-z-0-9-=%. < /dev/urandom 2> /dev/null))
endef

define symlink
$(shell rm -f $(2) && ln -s $(1) $(2))
endef

define node_ip
$(shell bash .makefile/print-nodeip.sh)
endef

define node_hostname
$(shell hostname)
endef

ifeq ($(RANDOM_PWDS),1)
	GF_SECURITY_SECRET_KEY := $(call random_password)
	GF_SECURITY_ADMIN_PASSWORD :=$(call random_password)
	INFLUXDB_USER_PASSWORD := $(call random_password)
	INFLUXDB_ADMIN_USER_PASSWORD :=$(call random_password)
	PGPASS :=$(call random_password)
	MONGOPASS :=$(call random_password)
else	
	GF_SECURITY_SECRET_KEY := "01234567890"
	GF_SECURITY_ADMIN_PASSWORD := "run4evah"
	INFLUXDB_USER_PASSWORD := "dunedaq"
	INFLUXDB_ADMIN_USER_PASSWORD := "run4evah"
	PGPASS := "run4evah"
	MONGOPASS := "run4evah"
endif

