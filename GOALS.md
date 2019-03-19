## We want:
* Terraform for K8s project setup
* Kustomize for multiple network support
* All configs should go PR into master
* Networks are defined as layers in subfolders
* Aim for simplicity rather than security
* Document the files and processes in the repo

## We don't want:
* Long living branches
* Credentials in repo
* Features like disruption-budget, autoscaling, security policies

## Assumptions:
- We are not going to recreate an old network
