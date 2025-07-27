terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "monstorage1753057890"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    tenant_id       = "8d768217-7ee4-4314-802d-3d66f76194db"
    client_id       ="de67da95-4974-4d14-8f84-51c867d76b18"
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
module "network" {
  source              = "./modules/network"
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "vm" {
  source              = "./modules/vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.network.vm_subnet_id
  vm_password         = data.azurerm_key_vault_secret.vmcompute_password.value
}

module "sqlserver" {
  source              = "./modules/sqlserver"
  location            = var.location
  resource_group_name = var.resource_group_name
  admin_password      = data.azurerm_key_vault_secret.sql_password.value
  sql_subnet_id       = module.network.sql_subnet_id
  dns_zone_name       = "privatelink.database.windows.net"
}

module "security" {
  source                 = "./modules/security"
  resource_group_name    = var.resource_group_name
  vm_nsg_name            = module.vm.vm_nsg_id
  sql_pe_private_ip      = module.sqlserver.sql_pe_private_ip
  allowed_rdp_source_ips = ["184.162.0.0/16"]
}