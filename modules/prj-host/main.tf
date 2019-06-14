# Module to create a Host Project ready for Shared VPC Network deployment

locals {
  deployment_name = "${var.company_id}-${var.asset_id}-${var.component_id}${var.environment_id == "" ? "" : format("-%s", var.environment_id)}${var.instance_id == "" ? "" : format("-%s", var.instance_id)}"
}

# Generate a new ID when a Project name is created or changed
resource "random_id" "project" {
  keepers = {
    name = "${local.deployment_name}"
  }

  byte_length = 3
}

# Create Host Project
# (Auto-Create Network is not set to False due to Organization Policy)
resource "google_project" "project" {
  name            = "${local.deployment_name}"
  project_id      = "${local.deployment_name}${var.project_id_suffix ? format("-%s", random_id.project.hex) : ""}"
  org_id          = "${var.org_id}"
  folder_id       = "${var.folder_id}"
  billing_account = "${var.billing_account_id}"
}

# Enable Compute API in Host Project
resource "google_project_service" "project_compute" {
  project            = "${google_project.project.project_id}"
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Enable Container API in Host Project
resource "google_project_service" "project_container" {
  project            = "${google_project.project.project_id}"
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# Enable Service Networking API in Host Project
resource "google_project_service" "project_servicenetworking" {
  project            = "${google_project.project.project_id}"
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud DNS API in Host Project
resource "google_project_service" "project_dns" {
  project            = "${google_project.project.project_id}"
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

# Set Project to be a Host Project
resource "google_compute_shared_vpc_host_project" "project" {
  project    = "${google_project.project.project_id}"
  depends_on = ["google_project_service.project_compute", "google_project_service.project_container", "google_project_service.project_servicenetworking", "google_project_service.project_dns"]
}