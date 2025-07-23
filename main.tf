terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "monstorage1753057890"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    tenant_id       = var.tenant_id
    client_id       = var.client_id
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  use_oidc         = true
  tenant_id       = var.tenant_id
  client_id       = var.client_id
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

# Réseau
resource "azurerm_virtual_network" "Poc_vnet" {
  name                = "vnet-poc"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-vm"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.Poc_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "VMhead_nsg" {
  name                = "vmhead-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_sql_out" {
  name                        = "AllowOutboundSQLToSQLServer"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.VMhead_nsg.name
}

resource "azurerm_network_interface" "vmcompute969_z1" {
  name                = "nic-vmcompute"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg" {
  network_interface_id      = azurerm_network_interface.vmcompute969_z1.id
  network_security_group_id = azurerm_network_security_group.VMhead_nsg.id
}

resource "azurerm_managed_disk" "VmCompute_disk1" {
  name                 = "VmCompute-disk1"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine" "VmCompute" {
  name                            = "VmCompute"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = [azurerm_network_interface.vmcompute969_z1.id]
  vm_size                         = "Standard_B1ms"
  delete_os_disk_on_termination   = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "VmCompute_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = azurerm_managed_disk.VmCompute_disk1.name
    lun             = 0
    caching         = "None"
    create_option   = "Attach"
    managed_disk_id = azurerm_managed_disk.VmCompute_disk1.id
    disk_size_gb    = 128
  }

  os_profile {
    computer_name  = "vmcompute"
    admin_username = "azureuser"
    admin_password = data.azurerm_key_vault_secret.vmcompute_password.value
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

# Extension CustomScript pour installer SSMS
resource "azurerm_virtual_machine_extension" "install_ssms" {
  name                 = "install-ssms"
  virtual_machine_id   = azurerm_virtual_machine.VmCompute.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "fileUris": ["https://raw.githubusercontent.com/Bobtine/Script/main/install-ssms.ps1"],
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File install-ssms.ps1"
}
SETTINGS
}

# VNet et sous-réseau SQL
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-sql"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet_sql" {
  name                 = "subnet-sql"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "sql_nsg" {
  name                = "sql-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "sql_nsg_link" {
  subnet_id                 = azurerm_subnet.subnet_sql.id
  network_security_group_id = azurerm_network_security_group.sql_nsg.id
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "sqlserverexample123bobby" # vérifier unicité
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = data.azurerm_key_vault_secret.sql_password.value

  minimum_tls_version          = "1.2"
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "sql_db" {
  name               = "exampledb"
  server_id          = azurerm_mssql_server.sql_server.id
  sku_name           = "S0"
  collation          = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb        = 5
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "sql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.subnet_sql.id

  private_service_connection {
    name                           = "sqlpsc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link_to_poc" {
  name                  = "sql-dns-link-to-poc"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.Poc_vnet.id
}

resource "azurerm_private_dns_a_record" "sql_dns_record" {
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address]
}

# Peering bidirectionnel
resource "azurerm_virtual_network_peering" "poc_to_sql" {
  name                      = "poc-to-sql"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.Poc_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "sql_to_poc" {
  name                      = "sql-to-poc"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = azurerm_virtual_network.Poc_vnet.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_network_security_rule" "allow_rdp" {
  name                        = "Allow-RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = ["184.162.17.138"] # exemple : ["207.96.192.0/24"]
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.VMhead_nsg.name
}

resource "azurerm_public_ip" "vm_ip" {
  name                = "public-ip-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
