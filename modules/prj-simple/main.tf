# Module to create a Service Project without Subnet
# Including the Host Project ID enables PSA networking privileges (e.g. for Cloud SQL)

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

# Create Project
# (Auto-Create Network is not set to False due to Organization Policy)
resource "google_project" "project" {
  name            = "${local.deployment_name}"
  project_id      = "${local.deployment_name}${var.project_id_suffix ? format("-%s", random_id.project.hex) : ""}"
  org_id          = "${var.org_id}"
  folder_id       = "${var.folder_id}"
  billing_account = "${var.billing_account_id}"
}

# Enable Compute API in Service Project
resource "google_project_service" "compute" {
  project            = "${google_project.project.project_id}"
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Set Project to be a Service Project & associate with Host Project
resource "google_compute_shared_vpc_service_project" "project" {
  count           = "${var.host_project_id == "" ? 0 : 1}"
  host_project    = "${var.host_project_id}"
  service_project = "${google_project.project.project_id}"
  depends_on      = ["google_project_service.compute"]
}

# Enable Service Networking API in Service Project
resource "google_project_service" "servicenetworking" {
  count              = "${var.host_project_id == "" ? 0 : 1}"
  project            = "${google_project.project.project_id}"
  service            = "servicenetworking.googleapis.com"
  depends_on         = ["google_compute_shared_vpc_service_project.project"]
  disable_on_destroy = false
}