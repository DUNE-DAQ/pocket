#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "ERROR: Wrong number of arguments: 1 expected, $# found."
    exit 2
fi

DOCKER_REPO="np04docker.cern.ch/dunedaq-local"
docker tag ${1} ${DOCKER_REPO}/${1}
docker push ${DOCKER_REPO}/${1}

