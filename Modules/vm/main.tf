resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-vmcompute"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
}

resource "azurerm_public_ip" "vm_ip" {
  name                = "public-ip-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = var.vm_nsg_id
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "data-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "VmCompute"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  vm_size               = "Standard_B1ms"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = azurerm_managed_disk.data_disk.name
    lun             = 0
    caching         = "None"
    create_option   = "Attach"
    managed_disk_id = azurerm_managed_disk.data_disk.id
    disk_size_gb    = 128
  }

  os_profile {
    computer_name  = "vmcompute"
    admin_username = "azureuser"
    admin_password = var.vm_password
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_virtual_machine_extension" "install_ssms" {
  name                 = "install-ssms"
  virtual_machine_id   = azurerm_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "fileUris": ["https://raw.githubusercontent.com/Bobtine/Script/main/install-ssms.ps1"],
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File install-ssms.ps1"
}
SETTINGS
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bastion-host"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_ip[0].id
  }
}

resource "azurerm_public_ip" "bastion_ip" {
  count               = var.enable_bastion ? 1 : 0
  name                = "bastion-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
