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

# Copy dbt-area here
cp -a  $(basename $1) $HERE/image
rm -rf image/build/*
rm -rf image/install/*

cd $HERE/image/dbt-pyvenv
find -name __pycache__ -exec rm -rf "{}" \;

cd $HERE/image/dbt-pyvenv/bin
sed -i 's|^#!.*|#!'$(realpath ./python)'|' *
sed -i 's|VIRTUAL_ENV=.*|VIRTUAL_ENV=$(cd $(dirname ${BASH_SOURCE[0]})/.. \&\& pwd)|' activate

cd $HERE

cp -a $HERE/../common .

docker build -v /cvmfs/dunedaq.opensciencegrid.org:/cvmfs/dunedaq.opensciencegrid.org  -v /cvmfs/dunedaq-development.opensciencegrid.org:/cvmfs/dunedaq-development.opensciencegrid.org --tag $DKR_TAG:$DKR_VERSION $HERE 
