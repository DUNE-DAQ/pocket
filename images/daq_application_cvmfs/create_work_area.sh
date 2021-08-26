#!/bin/bash

mkdir dunedaq
cd dunedaq
source /cvmfs/dunedaq.opensciencegrid.org/tools/dbt/dunedaq-v2.8.0/env.sh
dbt-create.sh dunedaq-v2.8.0 run
cd run
dbt-workarea-env
echo export CET_PLUGIN_PATH=$CET_PLUGIN_PATH >> run_env.sh
echo export DUNEDAQ_SHARE_PATH=$DUNEDAQ_SHARE_PATH >> run_env.sh
echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH >> run_env.sh
echo export PATH=$PATH >> run_env.sh
echo export READOUT_SHARE=$READOUT_SHARE >> run_env.sh
echo export TIMING_SHARE=$TIMING_SHARE >> run_env.sh
echo export TRACE_FILE=$TRACE_FILE >> run_env.sh    
echo "done"
