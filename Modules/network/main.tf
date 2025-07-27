resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-poc"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-vm"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "subnet-sql"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet_network_policy" "sql_policy" {
  name                                      = azurerm_subnet.sql_subnet.name
  subnet_id                                 = azurerm_subnet.sql_subnet.id
  private_endpoint_network_policies_enabled = false
}
