##############################################
# Networking
##############################################
resource "google_compute_network" "platform" {
  project = "${var.gcloud_project}"
  name       = "${var.platform_name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "primary" {
  project       = "${var.gcloud_project}"
  name          = "net-${var.platform_name}-${var.gcloud_region}"
  ip_cidr_range = "10.1.2.0/24"
  network       = "${google_compute_network.platform.self_link}"
  region        = "${var.gcloud_region}"
  private_ip_google_access = true

  secondary_ip_range { # pods
    range_name    = "container-range-1"
    ip_cidr_range = "10.20.0.0/16"
  }

  secondary_ip_range { # services
    range_name    = "service-range-1"
    ip_cidr_range = "10.39.0.0/16"
  }
}

##############################################
# Google Service Accounts for k8s nodes
##############################################
resource "google_service_account" "k8s-node" {
  project = "${var.gcloud_project}"
  account_id = "k8s-node"
  display_name = "k8s-node"
}

resource "google_project_iam_binding" "k8s-node-log" {
  project = "${var.gcloud_project}"
  role    = "roles/logging.logWriter"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}
resource "google_project_iam_binding" "k8s-node-metric" {
  project = "${var.gcloud_project}"
  role    = "roles/monitoring.metricWriter"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}
resource "google_project_iam_binding" "k8s-node-monitoring" {
  project = "${var.gcloud_project}"
  role    = "roles/monitoring.viewer"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}
resource "google_project_iam_binding" "k8s-node-storage" {
  project = "${var.gcloud_project}"
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}
resource "google_project_iam_binding" "k8s-node-zones" {
  project = "${var.gcloud_project}"
  role    = "roles/dataproc.viewer"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}
resource "google_project_iam_binding" "k8s-node-snapshots" {
  project = "${var.gcloud_project}"
  role    = "roles/compute.storageAdmin"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}
resource "google_project_iam_binding" "k8s-node-instances" {
  project = "${var.gcloud_project}"
  role    = "roles/compute.viewer"
  members = [
    "serviceAccount:${google_service_account.k8s-node.email}",
  ]
}

##############################################
# Google Kubernetes Engine
##############################################
resource "google_container_cluster" "primary" {
  depends_on  = ["google_compute_subnetwork.primary"]
  project     = "${var.gcloud_project}"
  name        = "${var.platform_name}"
  network     = "${google_compute_network.platform.name}"
  subnetwork  = "${google_compute_subnetwork.primary.name}"
  zone        = "${var.gcloud_zone}"

  # This enabled useIpAliases automatically
  ip_allocation_policy {
    cluster_secondary_range_name  = "${google_compute_subnetwork.primary.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.primary.secondary_ip_range.1.range_name}"
  }

  # find master versions: gcloud container get-server-config
  min_master_version = "1.12.5-gke.10"

  lifecycle {
    ignore_changes = ["node_pool"]
  }
  node_pool {
    name = "main-pool"
    initial_node_count = 2 # in each zone

    autoscaling {
      max_node_count = 10 # in each zone
      min_node_count = 1 # in each zone
    }
    node_config {
      machine_type = "n1-standard-4"
      service_account = "${google_service_account.k8s-node.email}"

      oauth_scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append",
        "https://www.googleapis.com/auth/compute", # required to list zones
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "04:00" # GMT
    }
  }

  network_policy {
    enabled = true
  }
}