variable "resource_group_name" {
  type        = string
  description = "RG name from root"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "dns_zone_name" {
  type        = string
  description = "DNS zone to create"
}

variable "dns_record_name" {
  type        = string
  description = "DNS record name ('@' or 'www')"
  default     = "@"
}
