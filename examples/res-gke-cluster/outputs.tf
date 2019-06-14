output "cluster_name" {
  value = "${module.res_gke_cluster.cluster_name}"
}

output "private_endpoint" {
  value = "${module.res_gke_cluster.private_endpoint}"
}

output "public_endpoint" {
  value = "${module.res_gke_cluster.public_endpoint}"
}

output "node_config" {
  value = "${module.res_gke_cluster.node_config}"
}

output "instance_group_urls" {
  value = "${module.res_gke_cluster.instance_group_urls}"
}

output "lb_ip_address" {
  value ="${google_compute_forwarding_rule.cluster.ip_address}"
}