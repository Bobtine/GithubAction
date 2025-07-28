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
variable "appservice_subnet_id" {
  description = "ID du subnet délégué pour l'App Service"
  type        = string
}

variable "compte_storage_account_name" {
  description = "Nom du compte de stockage pour les logs"
  type        = string
}

variable "tenant_id" {
  description = "ID du tenant Azure AD"
  type        = string
}
variable "client_id" {
  description = "Client ID de l'administrateur Azure AD"
  type        = string
}