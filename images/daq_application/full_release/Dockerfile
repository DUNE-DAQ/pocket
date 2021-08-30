# syntax=docker/dockerfile:1
ARG DUNEDAQ_RELEASE=v2.8.0
FROM docker.io/dunedaq/sl7:dunedaq-${DUNEDAQ_RELEASE}
# Yes, it needs to be repeated...
ARG DUNEDAQ_RELEASE

SHELL ["/bin/bash", "-c"] 

RUN mkdir dunedaq && \
    cd dunedaq && \
    source /cvmfs/dunedaq.opensciencegrid.org/tools/dbt/dunedaq-${DUNEDAQ_RELEASE}/env.sh && \
    dbt-create.sh dunedaq-${DUNEDAQ_RELEASE} run && \
    cd run && \
    dbt-workarea-env && \
    echo export CET_PLUGIN_PATH=$CET_PLUGIN_PATH >> run_env.sh && \
    echo export DUNEDAQ_SHARE_PATH=$DUNEDAQ_SHARE_PATH >> run_env.sh && \
    echo export LD_LIBRARY_PATH=$LD_LIBRARY_PATH >> run_env.sh && \
    echo export PATH=$PATH >> run_env.sh && \
    echo export READOUT_SHARE=$READOUT_SHARE >> run_env.sh && \
    echo export TIMING_SHARE=$TIMING_SHARE >> run_env.sh && \
    echo export TRACE_FILE=$TRACE_FILE >> run_env.sh && \
    echo "done"

COPY ./app-entrypoint.sh /dunedaq/run
RUN chmod 755 /dunedaq/run/app-entrypoint.sh

ENTRYPOINT [ "/dunedaq/run/app-entrypoint.sh" ]
