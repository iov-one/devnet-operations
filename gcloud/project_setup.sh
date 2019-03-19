#!/usr/bin/env bash -eox pipefail

. "export_variables.sh"

gcloud projects create ${TF_VAR_gcloud_project} \
  --set-as-default

gcloud beta billing projects link ${TF_VAR_gcloud_project} \
  --billing-account ${TF_VAR_billing_account}

# # Create a new service account for terraform
gcloud iam service-accounts create terraform \
  --project ${TF_VAR_gcloud_project} \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${GOOGLE_CLOUD_KEYFILE_JSON} \
  --iam-account terraform@${TF_VAR_gcloud_project}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${TF_VAR_gcloud_project} \
  --member serviceAccount:terraform@${TF_VAR_gcloud_project}.iam.gserviceaccount.com \
  --role roles/owner

# # Add humans
for n in ${EMAILS//,/ }; do
gcloud projects add-iam-policy-binding ${TF_VAR_gcloud_project} \
  --member user:${n} \
  --role roles/container.developer
done

# # Enable APIs for terraform
gcloud services enable \
  --project ${TF_VAR_gcloud_project} \
  cloudresourcemanager.googleapis.com \
  cloudbilling.googleapis.com \
  iam.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com 

terraform init

# Generate a plan and store it to a file
terraform plan -state="$TF_STATE" -out "$TF_PLAN"

# Apply the plan
terraform apply -state-out="$TF_STATE" "$TF_PLAN"

# # Import credentials
gcloud container clusters get-credentials $GCLOUD_PLATFORM --zone europe-west1-b --project ${TF_VAR_gcloud_project}

# # Set admin binding
for n in ${ADMIN_EMAILS//,/}; do
    kubectl create clusterrolebinding cluster-admin-binding_${n} --clusterrole=cluster-admin --user=${n}@iov.one
done