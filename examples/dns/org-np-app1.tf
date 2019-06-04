# Find GCE Instances
data "google_compute_instance" "server1" {
    name    = "org-app1-vm-dev-nginx-vm"
    project = "${var.service_project_id}"
    zone    = "${var.region}-a"
}

# DNS Records Configuration
resource "google_dns_record_set" "server1" {
  name    = "server1.${google_dns_managed_zone.private.dns_name}"
  project = "${var.host_project_id}"
  type    = "A"
  ttl     = 300

  managed_zone = "${google_dns_managed_zone.private.name}"

  rrdatas = ["${data.google_compute_instance.server1.network_interface.0.network_ip}"]
}

resource "google_dns_record_set" "server1_reverse" {
  name    = "${element(split(".", google_dns_record_set.server1.rrdatas.0), 3)}.${element(split(".", "${google_dns_record_set.server1.rrdatas.0}"), 2)}.${google_dns_managed_zone.private_reverse.dns_name}"
  project = "${var.host_project_id}"
  type    = "PTR"
  ttl     = 300

  managed_zone = "${google_dns_managed_zone.private_reverse.name}"

  rrdatas = ["${google_dns_record_set.server1.name}"]
}