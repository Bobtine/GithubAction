
## modules/security/variables.tf
variable "resource_group_name" {}
variable "vm_nsg_name" {}
variable "sql_pe_private_ip" {}
variable "allowed_rdp_source_ips" {
  type = list(string)
}