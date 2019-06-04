output "project_id" {
  value = "${google_project.project.project_id}"
}

output "subnet_name" {
  value = "${google_compute_subnetwork.service_subnet.name}"
}