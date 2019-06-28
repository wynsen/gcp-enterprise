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

# Create a Service Account for the VM Instance for use by Firewall Rules
resource "google_service_account" "vm" {
  account_id   = "${data.google_project.project.name}${local.instance_id}"
  project      = "${var.project_id}"
  display_name = "Compute service account"
}

# Add viewer role to Service Account restricting access to less than default (i.e. Editor)
resource "google_project_iam_member" "vm_viewer" {
  project = "${var.project_id}"
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.vm.email}"
}


resource "google_compute_instance" "private_vm" {
	count        = "${var.assign_public_ip ? 0 : 1}"

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

  service_account {
    email = "${google_service_account.vm.email}"
    scopes = [
      "userinfo-email", 
      "compute-ro", 
      "storage-ro"
    ]
  }

	tags = ["${var.project_id}"]
}

resource "google_compute_instance" "public_vm" {
  count        = "${var.assign_public_ip ? 1 : 0}"

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

	  access_config {
			# Ephemeral IP
		}
	}

  scheduling {
		automatic_restart = "${var.preemptible ? false : true}"
    preemptible       = "${var.preemptible}"
  }

  service_account {
    email = "${google_service_account.vm.email}"
    scopes = [
      "userinfo-email", 
      "compute-ro", 
      "storage-ro"
    ]
  }

	tags                      = ["${var.project_id}"]
	allow_stopping_for_update = true
}