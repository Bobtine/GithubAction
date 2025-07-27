
# 📦 Module: security
# Chemin: modules/security

## modules/security/main.tf
resource "azurerm_network_security_rule" "allow_sql_out" {
  name                        = "AllowOutboundSQLToSQLServer"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "*"
  destination_address_prefix  = var.sql_pe_private_ip
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.vm_nsg_name
}

resource "azurerm_network_security_rule" "allow_rdp" {
  name                        = "Allow-RDP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = var.allowed_rdp_source_ips
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.vm_nsg_name
}

