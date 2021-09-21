# Bash/Zsh independent way of determining the source path
SH_SOURCE=${BASH_SOURCE[0]:-${(%):-%x}}
HERE=$(cd $(dirname ${SH_SOURCE}) && pwd)

DKR_TAG=pocket-daq-cvmfs
DKR_VERSION=v0.1.0

if [[ $# -ne 1 ]]; then
    echo "Illegal number of parameters"
    exit 2
fi

if [[ ! -d $1 && ( -L $1 && ! -d "$(readlink $1)" )]]; then
    echo "$1 is not a directory"
    exit 2
fi

rm -rf $HERE/image

cd $(dirname $1)

echo "Building context"
echo "- Copying work area"
# Copy dbt-area here
cp -a  $(basename $1) $HERE/image

echo "- Removing build products"
rm -rf image/build/*
rm -rf image/install/*

echo "- Patching python environment "
cd $HERE/image/dbt-pyvenv
find -name __pycache__ -type d -prune -execdir rm -rf "{}" "+"

set -x
cd $HERE/image/dbt-pyvenv/bin
sed -i 's|^#!.*|#!/dunedaq/run/dbt-pyvenv/bin/python|' *
sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=$(cd $(dirname ${BASH_SOURCE[0]})/.. \&\& pwd)|' activate
set +x

cd $HERE

cp -a $HERE/../common .
cp rebuild_work_area.sh ./image/

# chmod 777 image/.rebuild_work_area.sh

docker run --user $(id -u):$(id -g) -i -t --rm -v /cvmfs/dunedaq.opensciencegrid.org:/cvmfs/dunedaq.opensciencegrid.org  -v /cvmfs/dunedaq-development.opensciencegrid.org:/cvmfs/dunedaq-development.opensciencegrid.org -v ${HERE}/image:/dunedaq/run:z dunedaq/sl7-minimal:latest -- /dunedaq/run/rebuild_work_area.sh

rm -rf image/build/*

docker buildx build --tag $DKR_TAG:$DKR_VERSION $HERE 
