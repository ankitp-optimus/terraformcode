# Main Terraform configuration file

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.common_tags
}

# Network module
module "network" {
  source = "./modules/network"

  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  vnet_name               = local.vnet_name
  subnet_name             = local.subnet_name
  nsg_name                = local.nsg_name
  pip_name                = local.pip_name
  nic_name                = local.nic_name
  address_space           = local.address_space
  subnet_address_prefixes = local.subnet_address_prefixes
  security_rules          = local.security_rules
  tags                    = local.common_tags
}

# Compute module
module "compute" {
  source = "./modules/compute"

  vm_name              = local.vm_name
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  admin_username       = var.admin_username
  admin_ssh_key        = var.admin_ssh_key
  network_interface_id = module.network.network_interface_id
  vm_size              = local.vm_size
  tags                 = local.common_tags
}
