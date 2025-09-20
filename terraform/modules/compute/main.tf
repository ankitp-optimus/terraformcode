# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  # Disable password authentication and use SSH keys only
  disable_password_authentication = true

  network_interface_ids = [var.network_interface_id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_publisher
    offer     = var.source_image_offer
    sku       = var.source_image_sku
    version   = var.source_image_version
  }

  computer_name              = var.vm_name
  provision_vm_agent         = true
  allow_extension_operations = true

  tags = var.tags
}

# VM Extension for custom script execution
resource "azurerm_virtual_machine_extension" "custom_script" {
  name                 = "${var.vm_name}-script"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = jsonencode({
    "commandToExecute" = templatefile("${path.root}/scripts/setup.sh", {
      github_repo_url = var.github_repo_url
      app_name        = var.app_name
      github_token    = var.github_token
      admin_username  = var.admin_username
    })
  })

  tags = var.tags
}