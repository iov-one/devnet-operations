#!/usr/bin/env bash -eox pipefail
manifestsPath=$(pwd)/manifests
. "$(pwd)/scripts/seed_variables.sh"

kustomize build ${manifestsPath}/chatbot/${networkName} | kubectl apply -f -
