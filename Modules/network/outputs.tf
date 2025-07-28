output "vm_subnet_id" {
  value = azurerm_subnet.vm_subnet.id
}

output "sql_subnet_id" {
  value = azurerm_subnet.sql_subnet.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion_subnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}


output "sql_private_dns_zone_name" {
  value = azurerm_private_dns_zone.sql_private_dns.name
}

output "sql_private_dns_zone_id" {
  value = azurerm_private_dns_zone.sql_private_dns.id
}

output "appservice_subnet_id" {
  value = azurerm_subnet.appservice_subnet.id
}
