output "web_app_url" {
  description = "URL de l'application Web"
  value       = azurerm_windows_web_app.app.default_hostname
}

output "web_app_id" {
  value = azurerm_windows_web_app.app.id
}
