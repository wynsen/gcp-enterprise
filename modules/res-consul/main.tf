# Module to create a HashiCorp Consul (Server) Cluster
# A Load Balancer is not preferred, specifically if clients are Consul Agents 

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
  template = "${file("${path.module}/startup-script-consul.sh")}"

  vars = {
    cluster_tag_name = "${data.google_project.project.name}${local.instance_id}"
  }
}


# Create a Service Account for the Consul VM Instances for use by Firewall Rules
resource "google_service_account" "consul" {
  account_id   = "${var.instance_id}"
  project      = "${var.project_id}"
  display_name = "Consul service account"
}

# Add viewer role to Consul Service Account restricting access to less than default (i.e. Editor)
resource "google_project_iam_member" "consul_viewer" {
  project = "${var.project_id}"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.consul.email}"
}


resource "google_compute_instance_template" "consul" {
  name_prefix  = "${data.google_project.project.name}${local.instance_id}"
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
    email = "${google_service_account.consul.email}"
    scopes = [
      "userinfo-email", 
      "compute-ro", 
      "storage-ro"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "consul" {
  name               = "${data.google_project.project.name}${local.instance_id}-ig"
  project            = "${var.project_id}"
  base_instance_name = "${data.google_project.project.name}${local.instance_id}"
  instance_template  = "${google_compute_instance_template.consul.self_link}"
  region             = "${var.region}"
  target_size        = "${var.cluster_size}"
}