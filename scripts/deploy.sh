#!/usr/bin/env bash -eox pipefail

kustomize build manifests/bns/$@ | kubectl apply -f -
