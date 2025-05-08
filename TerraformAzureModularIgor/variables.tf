variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_zone_name" {
  description = "Your DNS zone (must be delegated to Azure DNS)"
  type        = string
}

variable "dns_record_name" {
  description = "Record in the DNS zone ('@' or 'www')"
  type        = string
  default     = "@"
}

variable "email" {
  description = "Email for Certbot registration"
  type        = string
}

variable "ssh_key_bits" {
  description = "Size of the generated RSA SSH key"
  type        = number
}

variable "ssh_key_path" {
  description = "Local path to save the private key"
  type        = string
  default     = "~/.ssh/terraform_key.pem"
}

variable "ssh_public_key_path" {
  description = "Local path to save the public key"
  type        = string
  default     = "~/.ssh/terraform_key.pub"
}
