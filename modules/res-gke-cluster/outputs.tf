output "cluster_name" {
  value = "${google_container_cluster.cluster.name}"
}

output "private_endpoint" {
  value = "${google_container_cluster.cluster.private_cluster_config.0.private_endpoint}"
}

output "public_endpoint" {
  value = "${google_container_cluster.cluster.private_cluster_config.0.public_endpoint}"
}

output "node_config" {
  value = "${google_container_node_pool.cluster.node_config}"
}

output "instance_group_urls" {
  value = "${google_container_node_pool.cluster.instance_group_urls}"
}