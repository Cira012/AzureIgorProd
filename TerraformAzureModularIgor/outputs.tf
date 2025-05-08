output "network_public_ip" {
  description = "Public IP from the Network module"
  value       = module.network.public_ip_address
}

output "network_fqdn" {
  description = "FQDN from the Network module"
  value       = module.network.fqdn
}

output "vm_public_ip" {
  description = "Public IP of the VM"
  value       = module.network.public_ip_address
}

output "vm_private_ip" {
  description = "Private IP of the VM"
  value       = module.compute.private_ip
}

output "ssh_private_key_pem" {
  description = "SSH private key PEM (sensitive)"
  value       = module.compute.ssh_private_key_pem
  sensitive   = true
}

output "ssh_public_key_openssh" {
  description = "SSH public key"
  value       = module.compute.public_key_openssh
}
