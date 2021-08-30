# Bash/Zsh independent way of determining the source path
SH_SOURCE=${BASH_SOURCE[0]:-${(%):-%x}}
HERE=$(cd $(dirname ${SH_SOURCE}) && pwd)

TAG=pocket-daq-cvmfs
VERSION=v0.1.0

docker build -v /cvmfs/dunedaq.opensciencegrid.org:/cvmfs/dunedaq.opensciencegrid.org  -v /cvmfs/dunedaq-development.opensciencegrid.org:/cvmfs/dunedaq-development.opensciencegrid.org --tag $TAG:$VERSION $HERE 
