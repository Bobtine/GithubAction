output "vm_nsg_id" {
  value = azurerm_network_security_group.vm_nsg.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_ip.ip_address
}
