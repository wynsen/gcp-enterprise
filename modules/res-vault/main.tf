# Module to create a HashiCorp Vault Cluster

locals {
  instance_id = "${var.instance_id == "" ? "" : format("-%s", var.instance_id)}"
}

# Find Service Project
data "google_project" "project" {
  project_id = "${var.project_id}"
}

# Find Subnet
data "google_compute_subnetwork" "subnet" {
  name    = "${var.subnet_name}"
  project = "${var.host_project_id}"
  region  = "${var.region}"
}

# Find VM Image
data "google_compute_image" "image" {
	family  = "${var.image_family}"
	project = "${var.image_project}"
}

data "template_file" "startup_script" {
  template = "${file("${path.module}/startup-script-vault.sh")}"

  vars = {
    vault_bucket_name       = "${data.google_project.project.name}-vault-bucket"
    consul_cluster_tag_name = "${data.google_project.project.name}-consul"
    enable_vault_ui         = "--enable-ui"
    lb_ip                   = "${var.lb_ip}"
  }
}


# Create a Service Account for the Vault VM Instances for use by Firewall Rules & Cloud Storage Access
resource "google_service_account" "vault" {
  account_id   = "${var.instance_id}"
  project      = "${var.project_id}"
  display_name = "Vault service account"
}

# Add viewer role to Vault Service Account restricting access to less than default (i.e. Editor)
resource "google_project_iam_member" "vault_viewer" {
  project = "${var.project_id}"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.vault.email}"
}


resource "google_compute_instance_template" "vault" {
  name_prefix  = "${var.instance_id}"
  project      = "${var.project_id}"
  machine_type = "${var.machine_type}"

  tags                    = ["${var.project_id}", "${data.google_project.project.name}${local.instance_id}"]
  metadata_startup_script = "${data.template_file.startup_script.rendered}"
  metadata                = "${merge(map("cluster-size", var.cluster_size), var.custom_metadata)}"

  scheduling {
    automatic_restart = "${var.preemptible ? false : true}"
    preemptible       = "${var.preemptible}"
  }

  disk {
    boot         = true
    auto_delete  = true
    source_image = "${data.google_compute_image.image.self_link}"
    disk_size_gb = "${var.disk_size}"
    disk_type    = "${var.disk_type}"
  }

  network_interface {
		subnetwork         = "${var.subnet_name}"
		subnetwork_project = "${var.host_project_id}"
  }

  service_account {
    email = "${google_service_account.vault.email}"
    scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "vault" {
  name               = "${data.google_project.project.name}${local.instance_id}-ig"
  project            = "${var.project_id}"
  base_instance_name = "${data.google_project.project.name}${local.instance_id}"
  instance_template  = "${google_compute_instance_template.vault.self_link}"
  region             = "${var.region}"
  target_size        = "${var.cluster_size}"
}


# Create Health Check for Vault Cluster
resource "google_compute_health_check" "vault" {
  name                = "${data.google_project.project.name}-vault-health"
  project             = "${data.google_project.project.project_id}"
  check_interval_sec  = 15
  timeout_sec         = 5
	healthy_threshold   = 2
  unhealthy_threshold = 2

  https_health_check {
    request_path = "/v1/sys/health?standbyok=true"
    port         = 8200
  }
}

# Create Load Balancer Backend for Regional Vault Cluster with single Regional Instance Group
# When re-creating a Vault Cluster ensure the Backend Groups list is empty
resource "google_compute_region_backend_service" "vault" {
  name                            = "${data.google_project.project.name}-vault-lb"
  project                         = "${data.google_project.project.project_id}"
  region                          = "${var.region}"
  health_checks                   = ["${google_compute_health_check.vault.self_link}"]
  connection_draining_timeout_sec = 10
  session_affinity                = "CLIENT_IP"

  backend {
    group = "${replace(google_compute_region_instance_group_manager.vault.self_link, "instanceGroupManagers", "instanceGroups")}"
  }
}

# Create Internal Load Balancer for Vault Cluster
resource "google_compute_forwarding_rule" "vault" {
  name                  = "${data.google_project.project.name}-vault-forward"
  project               = "${data.google_project.project.project_id}"
  ip_address            = "${var.lb_ip}"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
  network               = "${data.google_compute_subnetwork.subnet.network}"
  subnetwork            = "${data.google_compute_subnetwork.subnet.self_link}"
  backend_service       = "${google_compute_region_backend_service.vault.self_link}"
}


# Create a Google Cloud Storage Bucket to use as Vault Storage Backend
resource "google_storage_bucket" "vault" {
  name               = "${data.google_project.project.name}-vault-bucket"
	project            = "${data.google_project.project.project_id}"
  location           = "${var.region}"
  storage_class      = "REGIONAL"
  bucket_policy_only = true

  force_destroy      = "${var.bucket_force_destroy}"
}

# Assign the Object Admin role to the Vault Service Account
resource "google_storage_bucket_iam_member" "vault_objectadmin" {
  bucket = "${google_storage_bucket.vault.name}"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vault.email}"
}

# Upload an improved run-vault script with Load Balancer IP
resource "google_storage_bucket_object" "vault_run" {
  name   = "run-vault"
  source = "${path.module}/run-vault"
  bucket = "${google_storage_bucket.vault.name}"
}