# Module to create a Shared VPC Network, etc.
# https://cloud.google.com/vpc/docs/shared-vpc
# https://cloud.google.com/vpc/docs/configure-private-services-access

locals {
  instance_id = "${var.instance_id == "" ? "" : format("-%s", var.instance_id)}"
}

# Find Host Project
data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

# Create Shared VPC Network in the Host Project
resource "google_compute_network" "shared_network" {
  name                    = "${data.google_project.host_project.name}${local.instance_id}-vpc"
  project                 = "${data.google_project.host_project.project_id}"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# Private Services Access
resource "google_compute_global_address" "private_services_access" {
  provider      = "google-beta"
  count         = "${var.ipv4_range_psa == "" ? 0 : 1}"
  name          = "${data.google_project.host_project.name}${local.instance_id}-psa"
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

# Primary Cloud Router
resource "google_compute_router" "primary" {
  count   = "${var.router ? 1 : 0}"
  name    = "${data.google_project.host_project.name}${local.instance_id}-pri-rtr"
  project = "${data.google_project.host_project.project_id}"
  network = "${google_compute_network.shared_network.self_link}"

  bgp {
    asn = "${var.router_asn}"
  }
}

# Cloud NAT
resource "google_compute_router_nat" "primary" {
  count                              = "${var.nat ? 1 : 0}"
  name                               = "${data.google_project.host_project.name}${local.instance_id}-pri-nat"
  project                            = "${data.google_project.host_project.project_id}"
  router                             = "${google_compute_router.primary.*.name[count.index]}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}