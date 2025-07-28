resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_rdp_from_ip" {
  name                        = "allow_rdp"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefixes     = var.allowed_rdp_source_ips
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

resource "azuread_user" "admin_user" {
  user_principal_name = "admin-app@tontenant.onmicrosoft.com"
  display_name        = "Admin App"
  password            = "MotDePasseComplexe123!"
  force_password_change = false
}

resource "azuread_user" "reader1" {
  user_principal_name = "reader1-app@tontenant.onmicrosoft.com"
  display_name        = "Reader 1"
  password            = "MotDePasseComplexe123!"
  force_password_change = false
}

resource "azuread_user" "reader2" {
  user_principal_name = "reader2-app@tontenant.onmicrosoft.com"
  display_name        = "Reader 2"
  password            = "MotDePasseComplexe123!"
  force_password_change = false
}

resource "azurerm_role_assignment" "app_admin" {
  scope                = var.azurerm_windows_web_app_id
  role_definition_name = "Contributor"
  principal_id         = azuread_user.admin_user.object_id
}

resource "azurerm_role_assignment" "app_reader1" {
  scope                = var.azurerm_windows_web_app_id
  role_definition_name = "Reader"
  principal_id         = azuread_user.reader1.object_id
}

resource "azurerm_role_assignment" "app_reader2" {
  scope                = var.azurerm_windows_web_app_id
  role_definition_name = "Reader"
  principal_id         = azuread_user.reader2.object_id
}