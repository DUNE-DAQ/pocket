#!/usr/bin/env bash

# Source:
# curl -O https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/release-0.8/build.sh

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

go get github.com/google/go-jsonnet/cmd/jsonnet
go get github.com/brancz/gojsontoyaml

# Make sure to use project tooling
PATH="$(pwd)/tmp/bin:$(go env GOPATH)/bin:${PATH}"

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir -p manifests/setup

# Calling gojsontoyaml is optional, but we would like to generate yaml, not json
jsonnet -J vendor -m manifests "${1-example.jsonnet}" | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml' -- {}

# Make sure to remove json files
find manifests -type f ! -name '*.yaml' -delete
rm -f kustomization

