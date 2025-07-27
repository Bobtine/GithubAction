## modules/sqlserver/outputs.tf
output "sql_pe_private_ip" {
  value = azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
}