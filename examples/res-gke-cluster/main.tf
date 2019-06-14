# https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy

provider "google" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version = "2.8.0"
}

provider "google-beta" {
  region = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version = "2.8.0"
}

# Find Service Project
data "google_project" "project" {
  project_id = "${var.project_id}"
}

# Find Subnet
data "google_compute_subnetwork" "subnet" {
  provider = "google"
  name     = "org-app1-gke-dev-subnet"
  project  = "${var.host_project_id}"
  region   = "${var.region}"
}

# GKE Project Configuration
/*
# Create Regional GKE Cluster
module "res_gke_cluster" {
  source = "github.com/wynsen/gcp-enterprise//modules/res-gke-cluster?ref=v0.0.3"

  region                                  = "${var.region}"
  location                                = "${var.region}"
  project_id                              = "${var.project_id}"
  host_project_id                         = "${var.host_project_id}"
  subnet_name                             = "${data.google_compute_subnetwork.subnet.name}"
  ipv4_range_master                       = "10.0.31.0/28"
  preemptible                             = "true"
  machine_type                            = "n1-standard-1"
  private_master_only                     = false
  master_authorized_networks_cidr_blocks  = [{ cidr_block = "123.123.123.123/32", display_name = "office-edge" }]
  master_authorized_network1_cidr_block   = "123.123.123.123/32"
  master_authorized_network1_display_name = "office-edge"
  max_pods_per_node                       = 30
  oauth_scopes                            = ["compute-rw" ,"cloud-platform", "cloud-source-repos" ,"datastore" , "pubsub" ,"bigquery" ,"storage-full" ,"taskqueue" ,"userinfo-email" ,"https://www.googleapis.com/auth/ndev.clouddns.readwrite" ,"sql-admin"]
  max_node_count                          = 10
  key_ring                                = "org-app1-gke-dev-ring"
  gke_key                                 = "org-app1-gke-dev-gke-key"
}

# Create Load Balancer Backend for Regional GKE Cluster with three Instance Groups
resource "google_compute_region_backend_service" "cluster" {
  name                            = "${data.google_project.project.name}-lb"
  project                         = "${data.google_project.project.project_id}"
  region                          = "${var.region}"
  health_checks                   = ["${google_compute_health_check.cluster.self_link}"]
  connection_draining_timeout_sec = 10
  session_affinity                = "CLIENT_IP"

  backend {
    group = "${replace(module.res_gke_cluster.instance_group_urls[0], "instanceGroupManagers", "instanceGroups")}"
  }

  backend {
    group = "${replace(module.res_gke_cluster.instance_group_urls[1], "instanceGroupManagers", "instanceGroups")}"
  }

  backend {
    group = "${replace(module.res_gke_cluster.instance_group_urls[2], "instanceGroupManagers", "instanceGroups")}"
  }
}
*/

# Create Zonal GKE Cluster
module "res_gke_cluster" {
  source = "github.com/wynsen/gcp-enterprise//modules/res-gke-cluster?ref=v0.0.3"

  region                                  = "${var.region}"
  location                                = "${var.region}-a"
  project_id                              = "${var.project_id}"
  host_project_id                         = "${var.host_project_id}"
  subnet_name                             = "org-app1-gke-dev-subnet"
  ipv4_range_master                       = "10.0.31.0/28"
  preemptible                             = "true"
  machine_type                            = "n1-standard-1"
  private_master_only                     = false
  master_authorized_networks_cidr_blocks  = [{ cidr_block = "123.123.123.123/32", display_name = "office-edge" }]
  master_authorized_network1_cidr_block   = "123.123.123.123/32"
  master_authorized_network1_display_name = "office-edge"
  max_pods_per_node                       = 30
  oauth_scopes                            = ["cloud-platform", "taskqueue", "userinfo-email"]
  max_node_count                          = 10
  key_ring                                = "org-app1-gke-dev-ring"
  gke_key                                 = "org-app1-gke-dev-gke-key"
}

# Create Load Balancer Backend for Zonal GKE Cluster with single Instance Group
# When re-creating a GKE Cluster ensure the Backend Groups list is empty
resource "google_compute_region_backend_service" "cluster" {
  name                            = "${data.google_project.project.name}-gke-lb"
  project                         = "${data.google_project.project.project_id}"
  region                          = "${var.region}"
  health_checks                   = ["${google_compute_health_check.cluster.self_link}"]
  connection_draining_timeout_sec = 10
  session_affinity                = "CLIENT_IP"

  backend {
    group = "${replace(module.res_gke_cluster.instance_group_urls[0], "instanceGroupManagers", "instanceGroups")}"
  }
}

# Create Internal Load Balancer for GKE Cluster
resource "google_compute_forwarding_rule" "cluster" {
  name                  = "${data.google_project.project.name}-gke-forward"
  project               = "${data.google_project.project.project_id}"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  network               = "${data.google_compute_subnetwork.subnet.network}"
  subnetwork            = "${data.google_compute_subnetwork.subnet.self_link}"
  backend_service       = "${google_compute_region_backend_service.cluster.self_link}"
}

# Create Health Check for GKE Cluster
resource "google_compute_health_check" "cluster" {
  name                = "${data.google_project.project.name}-gke-health"
  project             = "${data.google_project.project.project_id}"
  check_interval_sec  = 8
  timeout_sec         = 1
  unhealthy_threshold = 3

  http_health_check {
    request_path        = "/healthz"
    port                = 10256
  }
}