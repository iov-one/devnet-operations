#!/usr/bin/env bash -eox pipefail
manifestsPath=$(pwd)/manifests
networkName=$@
. "$(pwd)/scripts/seed_variables.sh"

lego \
--path=$certPath \
--email="$certEmail" \
--domains="*.$baseDomain" \
--dns="cloudflare" \
run

kubectl create secret generic traefik-public-certs --from-file="$certPath/certificates/_.$baseDomain.crt" \
--from-file="$certPath/certificates/_.$baseDomain.key"

kustomize build ${manifestsPath}/bns/${networkName} | kubectl apply -f -
