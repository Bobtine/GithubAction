resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = "12.0"
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
  minimum_tls_version          = "1.2"
  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "sql_db" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sql_server.id
  sku_name       = "S0"
  max_size_gb    = 10
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "sql-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.sql_subnet_id

  private_service_connection {
    name                           = "sqlpsc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_a_record" "sql_dns_record" {
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = var.dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address]
  depends_on = [azurerm_private_endpoint.sql_pe]
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}