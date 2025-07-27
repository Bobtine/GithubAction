output "vm_subnet_id" {
  value = azurerm_subnet.vm.id
}

output "sql_subnet_id" {
  value = azurerm_subnet.sql.id
}

output "bastion_subnet_id" {
  value = azurerm_subnet.bastion.id
}

output "vnet_name" {
  value = azurerm_virtual_network.main.name
}
