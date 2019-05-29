data "google_folder" "parent" {
  folder              = "${var.parent_folder_name}"
  lookup_organization = true
}

data "google_organization" "org" {
  organization = "${data.google_folder.parent.organization}"
}

resource "google_folder" "folder" {
  display_name = "${var.folder_name}"
  parent       = "${data.google_folder.parent.name}"
}


# Create Terraform Service Account for containing Projects' Resource Management
# Allows multiple Projects' Resources to be managed with a single Terraform Deployment
resource "google_service_account" "terraform" {
  account_id   = "terraform-${replace(google_folder.folder.id, "folders/", "")}"
  display_name = "${google_folder.folder.display_name}"
  project      = "${var.admin_project_id}"
}

# Associate Terraform Delegated Service Account with Editor Role for the Folder
resource "google_folder_iam_member" "terraform_editor" {
  folder = "${google_folder.folder.name}"
  role   = "roles/editor"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Extend the Editor Role privileges with Service Account Admin to manage IAM
resource "google_folder_iam_member" "terraform_iam_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Extend the Editor Role privileges with BigQuery Admin to manage BigQuery
resource "google_folder_iam_member" "terraform_bigquery_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/bigquery.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Extend the Editor Role privileges with Pub/Sub Admin to manage IAM on Topics and Subscriptions
resource "google_folder_iam_member" "terraform_pubsub_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/pubsub.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Extend the Editor Role privileges with Source Repositories Admin to manage IAM on Topics and Subscriptions
resource "google_folder_iam_member" "terraform_source_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/source.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

# Associate Terraform Delegated Service Account with Image User Role for the Images Project
resource "google_project_iam_member" "terraform_images_user" {
  count   = "${var.images_project_id == "" ? 0 : 1}"
  project = "${var.images_project_id}"
  role    = "roles/compute.imageUser"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

# Associate Terraform Delegated Service Account with DNS Reader Role for the Host Project
# Includes VPC Network User View Role necessary for Private Cloud SQL to utilise the PSA Subnet
resource "google_project_iam_member" "terraform_dns_reader" {
  project = "${var.host_project_id}"
  role    = "roles/dns.reader"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}


# Create Viewers GSuite Group to associate with the Folder
resource "gsuite_group" "viewer" {
  email       = "folder-${replace(google_folder.folder.id, "folders/", "")}-viewers@${data.google_organization.org.domain}"
  name        = "${google_folder.folder.display_name}-viewers"
  description = "Project Viewers"
}

# Associate Viewers GSuite Group with Viewers Role for the Folder
resource "google_folder_iam_member" "viewer" {
  folder = "${google_folder.folder.name}"
  role   = "roles/viewer"
  member = "group:${gsuite_group.viewer.email}"
}

# Associate Viewers GSuite Group with Image User Role for the Images Project
resource "google_project_iam_member" "viewer_image_user" {
  count   = "${var.images_project_id == "" ? 0 : 1}"
  project = "${var.images_project_id}"
  role    = "roles/compute.imageUser"
  member  = "group:${gsuite_group.viewer.email}"
}

# Associate Viewers GSuite Group with DNS Reader Role for the Host Project
resource "google_project_iam_member" "viewer_dns_reader" {
  project = "${var.host_project_id}"
  role    = "roles/dns.reader"
  member  = "group:${gsuite_group.viewer.email}"
}


# Create Editors GSuite Group to associate with the Folder
resource "gsuite_group" "editor" {
  email       = "folder-${replace(google_folder.folder.id, "folders/", "")}-editors@${data.google_organization.org.domain}"
  name        = "${google_folder.folder.display_name}-editors"
  description = "Project Editors"
}

# Associate Editors GSuite Group with Editors Role for the Folder
resource "google_folder_iam_member" "editor" {
  folder = "${google_folder.folder.name}"
  role   = "roles/editor"
  member = "group:${gsuite_group.editor.email}"
}

# Extend the Editor GSuite Group with BigQuery Admin to manage BigQuery
resource "google_folder_iam_member" "editor_bigquery_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/bigquery.admin"
  member = "group:${gsuite_group.editor.email}"
}

# Associate Editors GSuite Group with Pub/Sub Admin to manage Pub/Sub Topics and Subscriptions
resource "google_folder_iam_member" "editor_pubsub_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/pubsub.admin"
  member = "group:${gsuite_group.editor.email}"
}

# Associate Editors GSuite Group with Source Repositories Admin to manage Source Repositories
resource "google_folder_iam_member" "editor_source_admin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/source.admin"
  member = "group:${gsuite_group.editor.email}"
}

# Associate Editors GSuite Group with Image User Role for the Images Project
resource "google_project_iam_member" "editor_images_user" {
  count   = "${var.images_project_id == "" ? 0 : 1}"
  project = "${var.images_project_id}"
  role    = "roles/compute.imageUser"
  member  = "group:${gsuite_group.editor.email}"
}

# Associate Editors GSuite Group with DNS Reader Role for the Host Project
# Includes VPC Network User View Role necessary for Private Cloud SQL to utilise the PSA Subnet
resource "google_project_iam_member" "editor_dns_reader" {
  project = "${var.host_project_id}"
  role    = "roles/dns.reader"
  member  = "group:${gsuite_group.editor.email}"
}


# Create GSuite Group for OS Login to associate with the Folder
resource "gsuite_group" "oslogin" {
  email       = "folder-${replace(google_folder.folder.id, "folders/", "")}-oslogin@${data.google_organization.org.domain}"
  name        = "${google_folder.folder.display_name}-oslogin"
  description = "Project OS Login"
}

resource "google_folder_iam_member" "oslogin" {
  folder = "${google_folder.folder.name}"
  role   = "roles/compute.osAdminLogin"
  member = "group:${gsuite_group.oslogin.email}"
}


# Create GSuite Group for Break-Glass events to associate with the Folder
resource "gsuite_group" "breakglass" {
  count       = "${var.breakglass_enabled ? 1 : 0}"
  email       = "folder-${replace(google_folder.folder.id, "folders/", "")}-breakglass@${data.google_organization.org.domain}"
  name        = "${google_folder.folder.display_name}-breakglass"
  description = "Project IAM Admin"
}

resource "google_folder_iam_member" "breakglass" {
  count  = "${var.breakglass_enabled ? 1 : 0}"
  folder = "${google_folder.folder.name}"
  role   = "roles/resourcemanager.projectIamAdmin"
  member = "group:${gsuite_group.breakglass.*.email[count.index]}"
}