variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "allowed_rdp_source_ips" {
  type = list(string)
}

variable "vm_nsg_name" {
  description = "Nom du NSG de la VM"
  type        = string
}