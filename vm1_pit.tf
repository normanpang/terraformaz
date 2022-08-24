resource "azurerm_network_interface" "vm1" {
  name                = "pit-lab-vm1-nic"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name

  ip_configuration {
    name                          = "pit-lab-vm1-ifc"
    subnet_id                     = azurerm_subnet.primary.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.primary.id
  }
}

resource "azurerm_public_ip" "primary" {
  name                = "pit-lab-vm1-ppip"
  allocation_method   = "Static"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  sku                 = "Basic"
}

resource "azurerm_virtual_machine" "vm1" {
  name                  = "pit-lab-vm1"
  location              = azurerm_resource_group.primary.location
  resource_group_name   = azurerm_resource_group.primary.name
  vm_size               = "Standard_B2ms"
  network_interface_ids = [azurerm_network_interface.vm1.id]
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true

  storage_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol82-gen2"
    version   = "8.2.01"
  }

  storage_os_disk {
    name              = "pit-lab-vm1-os-disk"
    os_type           = "Linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }


  os_profile {
    admin_username = "pit"
    admin_password = "test-pwd-123!"
    computer_name  = "pit-lab-vm1"
#         custom_data = base64encode(data.local_file.cloudinit.content)
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled             = true
    storage_uri = azurerm_storage_account.primary.primary_blob_endpoint
  }

}
resource "azurerm_managed_disk" "vm1-dd1" {
  name                 = "pit-lab-vm1-dd1"
  location             = azurerm_resource_group.primary.location
  resource_group_name  = azurerm_resource_group.primary.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm1-dda1" {
  managed_disk_id    = azurerm_managed_disk.vm1-dd1.id
  virtual_machine_id = azurerm_virtual_machine.vm1.id
  lun                = "1"
  caching            = "None"
}

resource "azurerm_managed_disk" "vm1-dd2" {
  name                 = "pit-lab-vm1-dd2"
  location             = azurerm_resource_group.primary.location
  resource_group_name  = azurerm_resource_group.primary.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm1-dda2" {
  managed_disk_id    = azurerm_managed_disk.vm1-dd2.id
  virtual_machine_id = azurerm_virtual_machine.vm1.id
  lun                = "2"
  caching            = "None"
}

