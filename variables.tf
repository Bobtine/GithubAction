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

variable "tenant_id" {
  default = "8d768217-7ee4-4314-802d-3d66f76194db"
  description = "ID du locataire Azure"
}
variable "client_id" {
  default = "de67da95-4974-4d14-8f84-51c867d76b18" 
  description = "ID du client pour l'authentification Azure"
}