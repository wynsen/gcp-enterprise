# Allow the Shared VPC Network to be accessed by Google Load Balancers for Health-Checking
resource "google_compute_firewall" "lb-healthcheck_ext" {
  name    = "allow-ext-lb-healthcheck"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_ext.network_url}"

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
resource "google_compute_firewall" "management_ext" {
  name    = "allow-ext-management"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_ext.network_url}"

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
resource "google_compute_firewall" "cloudbuild_ext" {
  name    = "allow-ext-gcb-workers-443"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_ext.network_url}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_tags = ["gcb-worker"]
}