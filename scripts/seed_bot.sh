#!/usr/bin/env bash -eox pipefail
manifestsPath=$(pwd)/manifests
. "$(pwd)/scripts/seed_variables.sh"

kustomize build ${manifestsPath}/kubebot/${networkName} | kubectl apply -f -
