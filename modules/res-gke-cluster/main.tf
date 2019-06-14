# Module to create a Virtual Machine Instance
# https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
# https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
# https://cloud.google.com/sdk/gcloud/reference/container/clusters/create
# https://developers.google.com/identity/protocols/googlescopes

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

# Find Key Ring
data "google_kms_key_ring" "ring" {
  name     = "${var.key_ring}"
  project  = "${var.project_id}"
  location = "${var.region}"
}

# Create a Cloud KMS Key for GKE Etcd Encryption/Decryption
data "google_kms_crypto_key" "gke" {
  name     = "${var.gke_key}"
  key_ring = "${data.google_kms_key_ring.ring.self_link}"
}

# Create GKE Private Cluster
resource "google_container_cluster" "cluster" {
  provider                  = "google-beta"
  name                      = "${data.google_project.project.name}-gke"
  project                   = "${data.google_project.project.project_id}"
  network                   = "${data.google_compute_subnetwork.subnet.network}"
  subnetwork                = "${data.google_compute_subnetwork.subnet.self_link}"
  location                  = "${var.location}"
  remove_default_node_pool  = true
  initial_node_count        = "1"
  default_max_pods_per_node = "${var.max_pods_per_node}"

  master_authorized_networks_config {
    # Does not work with Terraform 0.12
    # cidr_blocks = "${var.master_authorized_networks_cidr_blocks}"

    cidr_blocks {
      cidr_block   = "10.0.0.0/8"
      display_name = "private"
    }

    cidr_blocks {
      cidr_block   = "${var.master_authorized_network1_cidr_block}"
      display_name = "${var.master_authorized_network1_display_name}"
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${data.google_compute_subnetwork.subnet.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${data.google_compute_subnetwork.subnet.secondary_ip_range.1.range_name}"
  }

  private_cluster_config {
    enable_private_endpoint = "${var.private_master_only}"
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "${var.ipv4_range_master}"
  }

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Disable HTTP Load Balancing addon as this creates public Load Balancers
  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  database_encryption {
    key_name = "${data.google_kms_crypto_key.gke.self_link}"
    state    = "ENCRYPTED"
  }
}

# Create GKE Node Pool
resource "google_container_node_pool" "cluster" {
  provider           = "google-beta"
  name               = "${data.google_project.project.name}-pool"
  project            = "${data.google_project.project.project_id}"
  location           = "${var.location}"
  cluster            = "${google_container_cluster.cluster.name}"
  initial_node_count = "${length(split("-", var.location)) == 2 ? 1 : 3}"
  max_pods_per_node  = "${var.max_pods_per_node}"

  node_config {
    preemptible     = "${var.preemptible}"
    machine_type    = "${var.machine_type}"
    service_account = "${var.service_account}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = "${var.oauth_scopes}"
  }

  autoscaling {
		min_node_count = "${length(split("-", var.location)) == 2 ? 1 : 3}"
		max_node_count = "${var.max_node_count}"
	}
}