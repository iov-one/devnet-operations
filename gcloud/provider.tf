provider "google" {
  credentials = "${file(var.gcloud_credentials_path)}"
  project     = "${var.gcloud_project}"
  region      = "${var.gcloud_region}"
}
