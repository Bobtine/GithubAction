terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "monstorage1753057890"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    tenant_id       = "8d768217-7ee4-4314-802d-3d66f76194db"
    client_id       ="de67da95-4974-4d14-8f84-51c867d76b18"
 }
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_oidc         = true
  tenant_id       = "8d768217-7ee4-4314-802d-3d66f76194db"
  client_id       = "de67da95-4974-4d14-8f84-51c867d76b18"
}

# Récupérer le Key Vault et les secrets
data "azurerm_key_vault" "main" {
  name                = "kv-environtest3"
  resource_group_name = "Key"
}

data "azurerm_key_vault_secret" "vmcompute_password" {
  name         = "vmcompute-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

data "azurerm_key_vault_secret" "sql_password" {
  name         = "sqladmin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}
module "vm" {
  source              = "./Modules/vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.network.vm_subnet_id
  vm_password         = data.azurerm_key_vault_secret.vmcompute_password.value
}

module "sqlserver" {
  source              = "./Modules/sqlserver"
  location            = var.location
  resource_group_name = var.resource_group_name
  admin_password      = data.azurerm_key_vault_secret.sql_password.value
  sql_subnet_id       = module.network.sql_subnet_id
  dns_zone_name       = "privatelink.database.windows.net"

  sql_server_name     = "sqlserverexample123bobby"
  sql_database_name   = "TestProduitsDB"
}


module "security" {
  source                 = "./Modules/security"
  location            = var.location
  resource_group_name    = var.resource_group_name
  vm_nsg_name            = module.vm.vm_nsg_id
  allowed_rdp_source_ips = ["184.162.0.0/16"]
}

module "appservice" {
  source = "./Modules/appservice"

  app_service_plan_name = var.app_service_plan_name
  app_service_name      = var.app_service_name
  location              = var.location
  resource_group_name   = var.resource_group_name

  sql_server_fqdn   = module.sqlserver.sql_server_fqdn
  sql_database_name = module.sqlserver.sql_database_name
  vnet_name         = module.network.vnet_name
}
module "network" {
  source              = "./Modules/network"
  location            = var.location
  resource_group_name = var.resource_group_name
}


