output "project_id" {
  value = "${google_project.project.project_id}"
}

output "subnet_name" {
  value = "${google_compute_subnetwork.subnet.name}"
}

output "project_service_account" {
  value = "${google_compute_subnetwork_iam_member.subnetuser_cloudservices.member}"
}

output "gke_service_account" {
  value = "${google_project_iam_member.hostagentuser_gke.member}"
}

output "key_ring" {
  value = "${google_kms_key_ring.ring.name}"
}

output "gke_key" {
  value = "${google_kms_crypto_key.gke.name}"
}