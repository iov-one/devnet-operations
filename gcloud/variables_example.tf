// example cluster variables config
variable "gcloud_region"        { default = "europe-west1" }
variable "gcloud_zone"          { default = "europe-west1-b" }
variable "gcloud_credentials_path" { default = "${file("your_desired_path/terraform-service-account.json")}" } // enter you actual service-account path here
variable "gcloud_project"       { default = "yourcompany-devnet" }  // identical to TF_VAR_gcloud_project in export_variables.sh
variable "platform_name"        { default = "devnet" } 
variable "work_dir"             { default = "/tmp" }