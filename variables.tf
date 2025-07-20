variable "subscription_id" {
  type        = string
  description = "ID de la souscription Azure"
  default = "58048bb8-7fbe-431d-b28e-d5bca207fbdf"
}

variable "location" {
  type        = string
  default     = "canadacentral"
  description = "Région Azure où les ressources seront déployées"
}

variable "resource_group_name" {
  type        = string
  default     = "EnvironTest"
  description = "Nom du groupe de ressources Azure"
}

variable "app_service_plan_name" {
  type        = string
  default     = "AzureDevPlan"
  description = "Nom du plan App Service"
}

variable "app_service_name" {
  type        = string
  default     = "azure-api-demo123"
  description = "Nom de l'application App Service"
}
