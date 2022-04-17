# Bash/Zsh independent way of determining the source path
SH_SOURCE=${BASH_SOURCE[0]:-${(%):-%x}}
DKR_BUILD_HERE=$(cd $(dirname ${SH_SOURCE}) && pwd)


DUNEDAQ_RELEASE="v2.10.2"

DKR_TAG=pocket-daq-release-cvmfs
DKR_VERSION=${DUNEDAQ_RELEASE}

source /cvmfs/dunedaq.opensciencegrid.org/setup_dunedaq.sh

echo "------------------------------------------"
echo "Loading daq-buildtool environment"
echo "------------------------------------------"
setup_dbt dunedaq-${DUNEDAQ_RELEASE}


echo "------------------------------------------"
echo "Loading daq-release environment"
echo "------------------------------------------"
dbt-setup-release  dunedaq-${DUNEDAQ_RELEASE}-cs8

echo "------------------------------------------"
echo "Capturing runtime environment"
echo "------------------------------------------"
${DKR_BUILD_HERE}/../common/make_env_script.sh

set -x 
echo "------------------------------------------"
echo "Bringing common scripts in view of docker build"
echo "------------------------------------------"
cp -a $DKR_BUILD_HERE/../common .

docker buildx build --tag $DKR_TAG:$DKR_VERSION $DKR_BUILD_HERE 
