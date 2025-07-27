variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "admin_login" {
  type    = string
  default = "sqladminuser"
}

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
