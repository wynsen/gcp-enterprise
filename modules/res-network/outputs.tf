output "network_url" {
  value = "${google_compute_network.shared_network.self_link}"
}