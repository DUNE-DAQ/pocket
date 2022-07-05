#!/usr/bin/bash

if [[ $# -ne 1 ]]; then
    echo "ERROR: Wrong number of arguments: 1 expecgted, $# found."
    exit 2
fi

DUNEDAQ_RELEASE=$1

source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh

echo "------------------------------------------"
echo "Loading daq-buildtool environment"
echo "------------------------------------------"
setup_dbt dunedaq-${DUNEDAQ_RELEASE}


echo "------------------------------------------"
echo "Loading daq-release environment"
echo "------------------------------------------"
dbt-setup-release  dunedaq-${DUNEDAQ_RELEASE}

echo "------------------------------------------"
echo "Capturing runtime environment"
echo "------------------------------------------"
make_env_script.sh

