output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    workload = azurerm_subnet.workload.id
  }
}

output "nsg_id" {
  description = "Network Security Group ID"
  value       = azurerm_network_security_group.nsg.id
}

output "public_ip_id" {
  description = "Public IP resource ID"
  value       = azurerm_public_ip.pip.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.pip.ip_address
}

output "fqdn" {
  description = "Full DNS name (apex or www)"
  value       = var.dns_record_name == "@" ? azurerm_dns_zone.zone.name : "${var.dns_record_name}.${azurerm_dns_zone.zone.name}"
}

