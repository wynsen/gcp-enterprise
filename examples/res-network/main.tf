# https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy

provider "google" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

provider "google-beta" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

# Find Host Project
data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

# Obtain Load Balancer IP Ranges for Firewall Rules
data "google_compute_lb_ip_ranges" "ranges" {}

# Internal Shared VPC Network
module "res_network_int" {
  source = "github.com/wynsen/gcp-enterprise//modules/res-network?ref=v0.0.3"

  instance_id     = "int"
  host_project_id = "${var.host_project_id}"
  ipv4_range_psa  = "10.0.240.0/20"
  router          = true
  router_asn      = "64514"
  nat             = true
}

# External Shared VPC Network
module "res_network_ext" {
  source = "github.com/wynsen/gcp-enterprise//modules/res-network?ref=v0.0.3"

  instance_id     = "ext"
  host_project_id = "${var.host_project_id}"
  router          = false
  nat             = false
}