output "internal_ip_address_test-vm" {
  value = yandex_compute_instance.test-vm.network_interface.0.ip_address
}

output "external_ip_address_test-vm" {
  value = yandex_compute_instance.test-vm.network_interface.0.nat_ip_address
}