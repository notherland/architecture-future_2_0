output "network_id" {
  description = "VPC network ID"
  value       = yandex_vpc_network.future20.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = yandex_vpc_subnet.platform.id
}

output "nat_gateway_id" {
  description = "NAT gateway ID"
  value       = yandex_vpc_gateway.nat.id
}

output "vm_id" {
  description = "Compute instance ID"
  value       = yandex_compute_instance.platform.id
}

output "vm_public_ip" {
  description = "VM public IP"
  value       = yandex_compute_instance.platform.network_interface[0].nat_ip_address
}

output "vm_private_ip" {
  description = "VM private IP"
  value       = yandex_compute_instance.platform.network_interface[0].ip_address
}

output "data_disk_id" {
  description = "Secondary disk ID"
  value       = yandex_compute_disk.app_data.id
}
