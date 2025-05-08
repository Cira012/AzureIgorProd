terraform {
  required_version = ">= 1.7.0"
}

provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "dns_zone_name" {
  description = "DNS zone name to use"
  type        = string
}

variable "dns_record_name" {
  description = "DNS record name (A record)"
  type        = string
}

variable "email" {
  description = "Email for certificate registration"
  type        = string
}

variable "ssh_key_bits" {
  description = "Number of bits for SSH key generation"
  type        = number
}

variable "ssh_key_path" {
  description = "Local path to save private key"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Local path to save public key"
  type        = string
}

# 1) Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# 2) Network Module
module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  dns_zone_name       = var.dns_zone_name
  dns_record_name     = var.dns_record_name
}

# 3) Compute Module
module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  subnet_id            = module.network.subnet_ids["workload"]
  public_ip_id         = module.network.public_ip_id
  public_ip_address    = module.network.public_ip_address

  domain_name          = module.network.fqdn
  email                = var.email
  ssh_key_bits         = var.ssh_key_bits
  project_link         = var.project_link
}

# 4) Persist SSH keys locally
resource "local_file" "ssh_private_key" {
  content         = module.compute.ssh_private_key_pem
  filename        = var.ssh_key_path
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content         = module.compute.public_key_openssh
  filename        = var.ssh_public_key_path
  file_permission = "0644"
}
