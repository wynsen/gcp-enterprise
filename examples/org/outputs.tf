output "google_folder_id_shared_network" {
  value = "${google_folder.shared_network.id}"
}

output "google_folder_id_shared_servers" {
  value = "${module.shared_servers.folder_id}"
}