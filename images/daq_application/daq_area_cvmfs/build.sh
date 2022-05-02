#!/usr/bin/bash
# Bash/Zsh independent way of determining the source path
SH_SOURCE=${BASH_SOURCE[0]:-${(%):-%x}}
DKR_BUILD_HERE=$(cd $(dirname ${SH_SOURCE}) && pwd)

DKR_TAG=pocket-daq-area-cvmfs
DKR_BASE_IMG=dunedaq/c8-minimal:latest

if [[ $# -ne 1 ]]; then
    echo "ERROR: Wrong number of arguments: 1 expecgted, $# found."
    exit 2
fi


if [[ ! -d $1 && ( -L $1 && ! -d "$(readlink $1)" ) ]]; then
    echo "$1 is not a directory"
    exit 2
fi

SRC_AREA=$(cd $1 && pwd)
DST_AREA="${DKR_BUILD_HERE}/image"

rm -rf ${DST_AREA}

# # Re-create build
mkdir -p ${DST_AREA}

echo "------------------------------------------"
echo "Cloning dbt virtual environment"
echo "------------------------------------------"

DOCKER_OPTS="--user $(id -u):$(id -g) \
    -it \
    -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
    -v /cvmfs/dunedaq.opensciencegrid.org:/cvmfs/dunedaq.opensciencegrid.org:ro \
    -v /cvmfs/dunedaq-development.opensciencegrid.org:/cvmfs/dunedaq-development.opensciencegrid.org:ro"


docker run ${DOCKER_OPTS}\
    -v ${DST_AREA}:/dunedaq/run:z \
    -v ${SRC_AREA}:${SRC_AREA} \
    -v ${DKR_BUILD_HERE}/clone_daq_area.sh:/dunedaq/bin/clone_daq_area.sh \
    ${DKR_BASE_IMG} -- \
    "export PATH=\"/dunedaq/bin/:$PATH\"; clone_daq_area.sh ${SRC_AREA} /dunedaq/run"

echo "------------------------------------------"
echo "Rebuilding workarea '$SRC_AREA' in docker"
echo "------------------------------------------"

docker run ${DOCKER_OPTS}\
    -v ${DST_AREA}:/dunedaq/run:z \
    -v ${DKR_BUILD_HERE}/rebuild_work_area.sh:/dunedaq/bin/rebuild_work_area.sh \
    -v ${DKR_BUILD_HERE}/../common/make_env_script.sh:/dunedaq/bin/make_env_script.sh \
    ${DKR_BASE_IMG} -- \
    "export PATH=\"/dunedaq/bin/:$PATH\"; rebuild_work_area.sh /dunedaq/run"

echo "------------------------------------------"
echo "Building $DKR_TAG:$DKR_VERSION docker image"
echo "------------------------------------------"

DKR_TAG=pocket-daq-area-cvmfs
DKR_VERSION=$(bash -c "source $DKR_BUILD_HERE/image/dbt-settings; echo \$DUNE_DAQ_BASE_RELEASE | sed 's/dunedaq-\([^-]*\).*/\1/'")

cp -a $DKR_BUILD_HERE/../common $DKR_BUILD_HERE
docker buildx build --tag ${DKR_TAG}:${DKR_VERSION} $DKR_BUILD_HERE 




