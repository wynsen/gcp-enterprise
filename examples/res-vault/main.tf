provider "google" {
  region      = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version     = "2.9.0"
}


# Find Service Project
data "google_project" "project" {
  project_id = "${var.project_id}"
}


# Vault Cluster Configuration
module "res_vault" {
#  source = "github.com/wynsen/gcp-enterprise//modules/res-vault?ref=v0.0.4"
  source = "../../modules/res-vault"

  instance_id          = "vault"
  project_id           = "${var.project_id}"
  host_project_id      = "${var.host_project_id}"
  region               = "${var.region}"
  subnet_name          = "org-app1-vm-dev-subnet"
  preemptible          = true
  machine_type         = "n1-standard-1"
  image_project        = "${var.image_project}"
  image_family         = "${var.vault_image_family}"
  disk_size            = 30
  disk_type            = "pd-standard"
  cluster_size         = 3
  bucket_force_destroy = true
  lb_ip                = "10.0.1.253"
}

# Consul Cluster Configuration
module "res_consul" {
#  source = "github.com/wynsen/gcp-enterprise//modules/res-consul?ref=v0.0.4"
  source = "../../modules/res-consul"

  instance_id          = "consul"
  project_id           = "${var.project_id}"
  host_project_id      = "${var.host_project_id}"
  region               = "${var.region}"
  subnet_name          = "org-app1-vm-dev-subnet"
  preemptible          = true
  machine_type         = "n1-standard-1"
  image_project        = "${var.image_project}"
  image_family         = "${var.consul_image_family}"
  disk_size            = 30
  disk_type            = "pd-standard"
  cluster_size         = 3
}