output "vm_name" {
  value = "${element(concat(google_compute_instance.private_vm.*.name, google_compute_instance.public_vm.*.name), 0)}"
}

output "private_endpoint" {
  value = "${element(concat(google_compute_instance.private_vm.*.network_interface.0.network_ip, google_compute_instance.public_vm.*.network_interface.0.network_ip), 0)}"
}