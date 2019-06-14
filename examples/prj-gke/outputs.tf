output "project_id" {
  value = "${module.prj_gke.project_id}"
}


output "subnet_name" {
  value = "${module.prj_gke.subnet_name}"
}

output "project_service_account" {
  value = "${module.prj_gke.project_service_account}"
}

output "gke_service_account" {
  value = "${module.prj_gke.gke_service_account}"
}

output "key_ring" {
  value = "${module.prj_gke.key_ring}"
}

output "gke_key" {
  value = "${module.prj_gke.gke_key}"
}