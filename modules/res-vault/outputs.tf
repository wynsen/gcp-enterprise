output "cluster_name" {
  value = "${data.google_project.project.name}${local.instance_id}"
}