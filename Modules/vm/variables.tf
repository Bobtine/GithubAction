variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "vm_password" {}
variable "bastion_subnet_id" {
  type    = string
  default = null
}
variable "enable_bastion" {
  type    = bool
  default = false
}
