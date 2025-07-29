variable "azurerm_windows_web_app_id" {
  description = "ID of the Azure Windows Web App"
  type        = string
}
variable "location" {
  description = "Emplacement Azure (ex: eastus)"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
}