variable "sql_server_name" {
  type = string
}

variable "sql_database_name" {
  type = string
}

variable "sql_subnet_id" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "admin_login" {
  type = string
  default = "sqladmin" # si tu veux
}

variable "admin_password" {
  type = string
}

variable "aad_admin_admin_login" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "sql_object_id" {
  type = string
}
