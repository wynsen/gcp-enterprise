# Module to create a Service Project with a Subnet with 2 Secondary IP Ranges for GKE
# https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips

locals {
  deployment_name = "${var.company_id}-${var.asset_id}-${var.component_id}${var.environment_id == "" ? "" : format("-%s", var.environment_id)}${var.instance_id == "" ? "" : format("-%s", var.instance_id)}"
}

# Find Host Project
data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

data "google_compute_network" "shared" {
  name    = "${var.shared_network_name}"
  project = "${var.host_project_id}"
}

# Generate a new ID when a Project name is created or changed
resource "random_id" "project" {
  keepers = {
    name = "${local.deployment_name}"
  }

  byte_length = 3
}

# Create Service Project
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
  host_project    = "${var.host_project_id}"
  service_project = "${google_project.project.project_id}"
  depends_on      = ["google_project_service.compute"]
}

# Create a Subnet for Service Project with 2 Secondary IP Ranges (e.g. for GKE)
resource "google_compute_subnetwork" "subnet" {
  name                     = "${local.deployment_name}-subnet"
  project                  = "${var.host_project_id}"
  region                   = "${var.region}"
  ip_cidr_range            = "${var.ipv4_range_primary}"
  network                  = "${data.google_compute_network.shared.self_link}"
  enable_flow_logs         = "${var.subnet_flow_logs}"
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "${var.ipv4_range_secondary0}"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "${var.ipv4_range_secondary1}"
  }
}

# Enable Container API in Service Project
resource "google_project_service" "container" {
  project            = "${google_project.project.project_id}"
  service            = "container.googleapis.com"
  depends_on         = ["google_compute_shared_vpc_service_project.project"]
  disable_on_destroy = false
}

# Enable Service Networking API in Service Project
resource "google_project_service" "servicenetworking" {
  project            = "${google_project.project.project_id}"
  service            = "servicenetworking.googleapis.com"
  depends_on         = ["google_compute_shared_vpc_service_project.project"]
  disable_on_destroy = false
}

# Enable Cloud KMS API in Service Project
resource "google_project_service" "kms" {
  project            = "${google_project.project.project_id}"
  service            = "cloudkms.googleapis.com"
  depends_on         = ["google_compute_shared_vpc_service_project.project"]
  disable_on_destroy = false
}


# Assign Subnet User privileges
# Needs to be manually re-run a second time if Subnetwork is re-created
resource "google_compute_subnetwork_iam_member" "subnetuser_cloudservices" {
  provider   = "google-beta"
  project    = "${var.host_project_id}"
  region     = "${var.region}"
  subnetwork = "${google_compute_subnetwork.subnet.name}"
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${google_project.project.number}@cloudservices.gserviceaccount.com"
  depends_on = ["google_compute_shared_vpc_service_project.project"]
}

resource "google_compute_subnetwork_iam_member" "subnetuser_terraform" {
  provider   = "google-beta"
  project    = "${var.host_project_id}"
  region     = "${var.region}"
  subnetwork = "${google_compute_subnetwork.subnet.name}"
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${var.terraform_delegate_email}"
  depends_on = ["google_compute_shared_vpc_service_project.project"]
}

resource "google_compute_subnetwork_iam_member" "subnetuser_editors" {
  provider   = "google-beta"
  project    = "${var.host_project_id}"
  region     = "${var.region}"
  subnetwork = "${google_compute_subnetwork.subnet.name}"
  role       = "roles/compute.networkUser"
  member     = "group:${var.editor_group_email}"
  depends_on = ["google_compute_shared_vpc_service_project.project"]
}

resource "google_compute_subnetwork_iam_member" "subnetuser_gke" {
  provider   = "google-beta"
  project    = "${var.host_project_id}"
  region     = "${var.region}"
  subnetwork = "${google_compute_subnetwork.subnet.name}"
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
  depends_on = ["google_project_service.container"]
}


# Assign Host Service Agent User privileges to the Service Project's Google APIs Service Agent with IAM
resource "google_project_iam_member" "hostagentuser_gke" {
  project    = "${var.host_project_id}"
  role       = "roles/container.hostServiceAgentUser"
  member     = "serviceAccount:service-${google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
  depends_on = ["google_project_service.container"]
}


# Assign Key Encrypter Decrypter privileges to the Service Project's Google APIs Service Agent with IAM
resource "google_project_iam_member" "kms_gke" {
  project    = "${google_project.project.project_id}"
  role       = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member     = "serviceAccount:service-${google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
  depends_on = ["google_project_service.container"]
}

# Create a Cloud KMS Key Ring for GKE Etcd Encryption/Decryption
resource "google_kms_key_ring" "ring" {
  name     = "${local.deployment_name}-ring"
  project  = "${google_project.project.project_id}"
  location = "${var.region}"
}

# Create a Cloud KMS Key for GKE Etcd Encryption/Decryption
resource "google_kms_crypto_key" "gke" {
  name     = "${local.deployment_name}-gke-key"
  key_ring = "${google_kms_key_ring.ring.self_link}"
}