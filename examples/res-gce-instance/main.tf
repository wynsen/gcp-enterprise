provider "google" {
  region = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version = "2.7.0"
}

# Bastion Configuration
module "res_vm_bastion" {
#  source = "github.com/wynsen/gcp-enterprise//modules/res-gce-instance?ref=v0.0.4"
  source = "../../modules/res-gce-instance"

  instance_id      = "bastion"
  project_id       = "${var.project_id}"
  host_project_id  = "${var.host_project_id}"
  zone             = "${var.region}-a"
  subnet_name      = "org-app1-vm-dev-subnet"
  preemptible      = true
  machine_type     = "n1-standard-1"
  image_project    = "debian-cloud"
  image_family     = "debian-9"
  assign_public_ip = true
}