# Example of an Folder Hierarchy deployment
# https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy
# A User Images Project is to be created prior to enabling the related configurations

provider "google" {
  region = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version = "2.7.0"
}

provider "gsuite" {
  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.group"
  ]
  credentials = "${file("${var.credentials_gsuite_file_path}")}"
  impersonated_user_email = "${var.credentials_gsuite_impersonated_user_email}"
  version = "0.1.19"
}


data "google_organization" "org" {
  organization = "${var.org_id}"
}


# Create Organization Owner GSuite Group to associate with the Organization
resource "gsuite_group" "owner" {
  email       = "org-${var.org_id}-owners@${data.google_organization.org.domain}"
  name        = "${replace(data.google_organization.org.domain, ".", "-")}-owners"
  description = "Project Owners"
}

resource "google_organization_iam_member" "org_project_owner" {
  org_id = "${var.org_id}"
  role   = "roles/owner"
  member = "group:${gsuite_group.owner.email}"
}

# Top-level Folders
resource "google_folder" "sandpit" {
  display_name = "sandpit"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "nonprod" {
  display_name = "nonprod"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "prod" {
  display_name = "prod"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "shared" {
  display_name = "shared"
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "subsidiary" {
  display_name = "subsidiary"
  parent       = "organizations/${var.org_id}"
}

# Branch Folders
resource "google_folder" "nonprod_tribe1" {
  display_name = "nonprod-tribe1"
  parent       = "${google_folder.nonprod.name}"
}

resource "google_folder" "nonprod_tribe2" {
  display_name = "nonprod-tribe2"
  parent       = "${google_folder.nonprod.name}"
}

resource "google_folder" "nonprod_tribe3" {
  display_name = "nonprod-tribe3"
  parent       = "${google_folder.nonprod.name}"
}

resource "google_folder" "prod_tribe1" {
  display_name = "prod-tribe1"
  parent       = "${google_folder.prod.name}"
}

resource "google_folder" "prod_tribe2" {
  display_name = "prod-tribe2"
  parent       = "${google_folder.prod.name}"
}

resource "google_folder" "prod_tribe3" {
  display_name = "prod-tribe3"
  parent       = "${google_folder.prod.name}"
}

# Leaf Folders without delegated access
# (Permissions required to managed Shared VPC Networks are nearly equivalent to Organization management)
resource "google_folder" "shared_network" {
  display_name = "shared-network"
  parent       = "${google_folder.shared.name}"
}

# Leaf Folders with delegated access
# (Terraform Service Accounts for Project Resource Management)
# (GSuite Groups for Project Viewers)
module "shared_servers" {
  source = "github.com/wynsen/gcp-enterprise//modules/org-leaf?ref=v0.0.2"
  folder_name = "shared-servers"
  parent_folder_name = "${google_folder.shared.name}"
  admin_project_id = "${var.admin_project_id}"
  host_project_id = "${var.host_project_id}"
  breakglass_enabled = true
}

module "nonprod_tribe1_app1-dev" {
  source = "github.com/wynsen/gcp-enterprise//modules/org-leaf?ref=v0.0.2"
  folder_name = "nonprod-tribe1-app1dev"
  parent_folder_name = "${google_folder.nonprod_tribe1.name}"
  admin_project_id = "${var.admin_project_id}"
  host_project_id = "${var.host_project_id}"
#  images_project_id = "${var.images_project_id}"
  breakglass_enabled = false
}