output "sql_server_fqdn" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_db.name
}

# Supprime cette sortie si tu n'as pas encore créé la ressource sql_pe :
# output "sql_pe_private_ip" {
#   value = azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
# }
