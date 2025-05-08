output "private_ip" {
  value = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}

output "ssh_private_key_pem" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}

output "public_key_openssh" {
  value = tls_private_key.ssh.public_key_openssh
}
