output "vm_name" {
  value = "${google_compute_instance.vm.name}"
}

output "private_endpoint" {
  value = "${google_compute_instance.vm.network_interface.0.network_ip}"
}