# DevNet Operations
Kubernetes manifest and Terraform operation files and doc.

## Spinning up a cluster
Currently we support only Google Cloud setup via terraform

### Prerequisites
Tested with Terraform 0.11+, kubectl v1.11+ and gcloud SDK 209+ on OS X and Linux  
Google cloud billing account  

### Setup
* Run `make variables` to set you up with sample `gcloud/export_variables.sh` and `gcloud/variables.tf`  
* Modify these files as suggested in comments to each variable  
* Make sure all the generated paths like terraform plans/state and account are pointing to a secure place and not `/tmp`  
* Run `make setup_cluster`
* Enjoy your newly created Kubernetes cluster on Gcloud!
