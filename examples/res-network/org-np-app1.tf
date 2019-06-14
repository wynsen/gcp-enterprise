# Allow the private GKE Master to be accessed with HTTPS from RFC1918 address space
/*
resource "google_compute_firewall" "org-np-app1_gke_master" {
  name    = "allow-int-app1-gke-master"
  project = "${data.google_project.host_project.project_id}"
  network = "${module.res_network_int.network_url}"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction = "EGRESS"
  destination_ranges = ["10.0.31.0/28"]
}
*/