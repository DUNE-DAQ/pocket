#!/usr/bin/bash
HERE=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
echo "Building dbt work area in $HERE"
cd $HERE
source ./dbt-env.sh
dbt-workarea-env
dbt-build.py -c
echo export CET_PLUGIN_PATH=$CET_PLUGIN_PATH >> run_env.sh
echo export DUNEDAQ_SHARE_PATH=$DUNEDAQ_SHARE_PATH >> run_env.sh
echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH >> run_env.sh
echo export PATH=$PATH >> run_env.sh
echo export READOUT_SHARE=$READOUT_SHARE >> run_env.sh
echo export TIMING_SHARE=$TIMING_SHARE >> run_env.sh
echo export TRACE_BIN=$TRACE_BIN >> run_env.sh
echo export TRACE_FILE=$TRACE_FILE >> run_env.sh
echo "Build completed"
