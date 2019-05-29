# https://cloud.google.com/resource-manager/docs/cloud-platform-resource-hierarchy

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

# Find Host Project.
data "google_project" "host_project" {
  project_id = "${var.host_project_id}"
}

# Host Project Configuration
module "res_network" {
  source = "github.com/wynsen/gcp-enterprise//modules/res-network?ref=v0.0.1"

  instance_number = ""
  region          = "${var.region}"
  host_project_id = "${var.host_project_id}"
  ipv4_range_psa  = "${var.ipv4_range_psa}"
}


# Cloud Routers
resource "google_compute_router" "primary" {
  name    = "${data.google_project.host_project.name}-pri-rtr"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network.network_url}"
#  bgp {
#    asn = "${var.router_asn}"
#  }
}

# Cloud NAT
resource "google_compute_router_nat" "primary" {
  name                               = "${data.google_project.host_project.name}-pri-nat"
  project                            = "${data.google_project.host_project.project_id}"
  router                             = "${google_compute_router.primary.name}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Private Cloud DNS
resource "google_dns_managed_zone" "private" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}-priv-dns"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "${var.private_dns_zone_name}"
  visibility = "private"

  private_visibility_config {
    networks {
      network_url =  "${module.res_network.network_url}"
    }
  }

/*
  forwarding_config {
    target_name_servers {
      ipv4_address = "172.16.1.10"
    }
    target_name_servers {
      ipv4_address = "172.16.2.10"
    }
  }
*/
}

resource "google_dns_managed_zone" "private_reverse" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}-priv-dns-reverse"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "${var.private_dns_zone_name_reverse}"
  visibility = "private"

  private_visibility_config {
    networks {
      network_url =  "${module.res_network.network_url}"
    }
  }
}

# Public Cloud DNS
/*
resource "google_dns_managed_zone" "public" {
  provider   = "google-beta"
  name       = "${data.google_project.host_project.name}${local.instance_number_insert}-dns-public"
  project    = "${data.google_project.host_project.project_id}"
  dns_name   = "${var.public_dns_zone_name}"
}
*/
