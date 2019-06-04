
# https://cloud.google.com/dns/docs/overview
# https://cloud.google.com/compute/docs/internal-dns
# https://cloud.google.com/compute/docs/instances/custom-hostname-vm

# A separate Terraform deployment per Host Project is to be configured and executed in the context
# of a Host Project Administrator, so that GCE Instances, etc. can subsequently have Private Cloud
# DNS Records associated with them. These DNS Records are to be created in the Security Context of
# the Host Project Administrator.

# A separate DNS TF File per Service Project is to be configured with Code Owners security in GIT and
# managed by the Project Editor Team (owning the GCE Instances, etc.) and reviewed + executed by
# the DNS Team to ensure no conflicts exist or unintended configurations result.

# Note that the GCE Instance Hostname parameter is NOT to be utilised to configure DNS A Records
# associated with GCE Instances in Cloud DNS or Internal DNS.

provider "google" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

provider "google-beta" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.7.0"
}

# Find Host Project
data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

data "google_compute_network" "shared_vpc" {
  name    = "${var.shared_vpc_name}"
  project = "${var.host_project_id}"
}

# Private Cloud DNS
resource "google_dns_managed_zone" "private" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}-prv-dns"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "domain.internal."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "${data.google_compute_network.shared_vpc.self_link}"
    }
  }
}

resource "google_dns_managed_zone" "private_reverse" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}-prv-dns-reverse"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "0.10.in-addr.arpa."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "${data.google_compute_network.shared_vpc.self_link}"
    }
  }
}

# Public Cloud DNS
/*
resource "google_dns_managed_zone" "public" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}-pub-dns"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "domain.com."
}
*/

# Private Cloud DNS
resource "google_dns_managed_zone" "onprem" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}-onprem-dns"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "onprem.domain.internal."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "${data.google_compute_network.shared_vpc.self_link}"
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = "172.16.1.10"
    }
    target_name_servers {
      ipv4_address = "172.16.2.10"
    }
  }
}

resource "google_dns_policy" "private" {
  provider                  = "google-beta"
  name                      = "${data.google_project.host_project.name}-prv-dns-policy"
  project                   = "${data.google_project.host_project.project_id}"
  enable_inbound_forwarding = true
  enable_logging            = false

  networks {
    network_url = "${data.google_compute_network.shared_vpc.self_link}"
  }
}