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