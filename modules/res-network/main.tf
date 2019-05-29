# https://cloud.google.com/vpc/docs/shared-vpc
# https://cloud.google.com/vpc/docs/configure-private-services-access

locals {
  instance_number_insert = "${var.instance_number == "" ? "" : format("-%02s", var.instance_number)}"
}

# Find Host Project.
data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

# Create Shared VPC Network in the Host Project
resource "google_compute_network" "shared_network" {
  name                    = "${data.google_project.host_project.name}${local.instance_number_insert}-vpc"
  project                 = "${data.google_project.host_project.project_id}"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# Private Services Access
resource "google_compute_global_address" "private_services_access" {
  provider      = "google-beta"
  count         = "${var.ipv4_range_psa == "" ? 0 : 1}"
  name          = "${data.google_project.host_project.name}${local.instance_number_insert}-psa"
  project       = "${data.google_project.host_project.project_id}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = "${element(split("/", var.ipv4_range_psa), 1)}"
  address       = "${element(split("/", var.ipv4_range_psa), 0)}"
  network       = "${google_compute_network.shared_network.self_link}"
}

resource "google_service_networking_connection" "private_services_access" {
  provider                = "google-beta"
  count                   = "${var.ipv4_range_psa == "" ? 0 : 1}"
  network                 = "${google_compute_network.shared_network.self_link}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_services_access.*.name[count.index]}"]
}

