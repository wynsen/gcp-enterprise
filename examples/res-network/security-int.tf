# Allow the Shared VPC Network to be accessed by Google Load Balancers for Health-Checking
resource "google_compute_firewall" "lb-healthcheck_int" {
  name    = "allow-int-lb-healthcheck"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_int.network_url}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

# Allow the Shared VPC Network to be accessed with ICMP, SSH, RDP and WinRM from RFC1918 address space
resource "google_compute_firewall" "management_int" {
  name    = "allow-int-management"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_int.network_url}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389", "5896"]
  }

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

# Allow the Shared VPC Network to be accessed by Private Cloud Build Custom Workers
resource "google_compute_firewall" "cloudbuild_int" {
  name    = "allow-int-gcb-workers-443"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_int.network_url}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_tags = ["gcb-worker"]
}

# Allow the Dataflow Workers to be accessed by Dataflow Workers
# https://cloud.google.com/dataflow/docs/guides/routes-firewall
resource "google_compute_firewall" "dataflow_int" {
  name    = "allow-int-dataflow-workers-all"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_int.network_url}"

  allow {
    protocol = "tcp"
  }

  source_tags = ["dataflow"]
  target_tags = ["dataflow"]
}