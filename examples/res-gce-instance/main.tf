provider "google" {
  region = "${var.region}"
  credentials = "${file("${var.credentials_file_path}")}"
  version = "2.7.0"
}

# GKE Project Configuration
module "res_vm_instance" {
  source = "github.com/wynsen/gcp-enterprise//modules/res-gce-instance?ref=v0.0.3"

  instance_id     = "nginx"
  project_id      = "${var.project_id}"
  host_project_id = "${var.host_project_id}"
  zone            = "${var.region}-a"
  subnet_name     = "org-app1-vm-dev-subnet"
  preemptible     = false
  machine_type    = "f1-micro"
  image_project   = "debian-cloud"
  image_family    = "debian-9"
}
