# Module to create a Virtual Machine Instance
# https://cloud.google.com/compute/docs/instances/
# https://cloud.google.com/compute/docs/instances/managing-instance-access
# https://cloud.google.com/security/shielded-cloud/shielded-vm
# https://cloud.google.com/compute/docs/images

locals {
  instance_id = "${var.instance_id == "" ? "" : format("-%s", var.instance_id)}"
}

# Find Service Project
data "google_project" "project" {
  project_id = "${var.project_id}"
}

# Find VM Image
data "google_compute_image" "image" {
	family  = "${var.image_family}"
	project = "${var.image_project}"
}

resource "google_compute_instance" "vm" {
	name         = "${data.google_project.project.name}${local.instance_id}-vm"
	machine_type = "${var.machine_type}"
	zone         = "${var.zone}"
	project      = "${var.project_id}"

	boot_disk {
		initialize_params{
			image = "${data.google_compute_image.image.self_link}"
		}
	}

	network_interface {
		subnetwork         = "${var.subnet_name}"
		subnetwork_project = "${var.host_project_id}"
	}

  scheduling {
    preemptible = "${var.preemptible}"
  }
}