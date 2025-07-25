variable "app_service_plan_name" {
  description = "Nom du App Service Plan"
  type        = string
}

variable "app_service_name" {
  description = "Nom de l'App Service"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "sql_server_fqdn" {
  description = "FQDN du SQL Server"
  type        = string
}

variable "sql_database_name" {
  description = "Nom de la base de données SQL"
  type        = string
}

variable "vnet_name" {
  description = "Nom du Virtual Network pour l'intégration"
  type        = string
}
