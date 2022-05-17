#!/usr/bin/bash
# Bash/Zsh independent way of determining the source path
SH_SOURCE=${BASH_SOURCE[0]:-${(%):-%x}}
DKR_BUILD_HERE=$(cd $(dirname ${SH_SOURCE}) && pwd)


DUNEDAQ_RELEASE="v2.10.2"

DKR_TAG=pocket-daq-release-cvmfs
DKR_VERSION=${DUNEDAQ_RELEASE}
DKR_BASE_IMG=dunedaq/c8-minimal:latest

DST_AREA="${DKR_BUILD_HERE}/image"

rm -rf ${DST_AREA}
mkdir -p ${DST_AREA}

DOCKER_OPTS="--user $(id -u):$(id -g) \
    -it \
    -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro \
    -v /cvmfs/dunedaq.opensciencegrid.org:/cvmfs/dunedaq.opensciencegrid.org \
    -v /cvmfs/dunedaq-development.opensciencegrid.org:/cvmfs/dunedaq-development.opensciencegrid.org"

docker run ${DOCKER_OPTS}\
    -v ${DST_AREA}:/dunedaq/run:z \
    -v ${DKR_BUILD_HERE}/../common/make_env_script.sh:/dunedaq/bin/make_env_script.sh \
    -v ${DKR_BUILD_HERE}/capture_release_env.sh:/dunedaq/bin/capture_release_env.sh \
    ${DKR_BASE_IMG} -- \
    "export PATH=\"/dunedaq/bin/:$PATH\"; cd /dunedaq/run; capture_release_env.sh ${DUNEDAQ_RELEASE}"

echo "------------------------------------------"
echo "Bringing common scripts in view of docker build"
echo "------------------------------------------"
cp -a $DKR_BUILD_HERE/../common .


echo "------------------------------------------"
echo "Building $DKR_TAG:$DKR_VERSION docker image"
echo "------------------------------------------"
docker buildx build --tag $DKR_TAG:$DKR_VERSION $DKR_BUILD_HERE 
