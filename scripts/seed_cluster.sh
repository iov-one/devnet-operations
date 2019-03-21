#!/usr/bin/env bash -eox pipefail
manifestsPath=$(pwd)/manifests
. "$(pwd)/scripts/seed_variables.sh"

lego \
--path=$certPath \
--email="$certEmail" \
--domains="*.$baseDomain" \
--dns="cloudflare" \
run

cp "$certPath/certificates/_.$baseDomain.crt" /tmp/cert.crt
cp "$certPath/certificates/_.$baseDomain.key" /tmp/cert.key

kubectl create secret generic traefik-public-certs --from-file="/tmp/cert.crt" \
--from-file="/tmp/cert.key"

rm -rf /tmp/cert.crt
rm -rf /tmp/cert.key

kustomize build ${manifestsPath}/traefik/${networkName} | kubectl apply -f -

kustomize build manifests/weave/zebranet/bns | sed 's/base/bns/' | kubectl apply -f -
kustomize build manifests/weave/zebranet/bcp | sed 's/base/bcp/' | kubectl apply -f -

# experimental: set DNS records
# public traefik
set +e
IP=$(kubectl get service traefik-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
while [ "$IP" == "" ]; do
    sleep 5
    IP=$(kubectl get service traefik-public -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
done
set -e

EMAIL="$CLOUDFLARE_EMAIL"; \
KEY="$CLOUDFLARE_API_KEY"; \
DOMAIN="$ROOT_DOMAIN"; \
TYPE="A"; \
NAME="*.$baseDomain"; \
CONTENT="$IP"; \
PROXIED="false"; \
TTL="1"; \
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID/dns_records/" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"'"$TYPE"'","name":"'"$NAME"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}'

set +e