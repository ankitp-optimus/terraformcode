# Main outputs from the Terraform deployment

# Resource Group Information
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.rg.location
}

# Network Information
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.network.vnet_name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.network.subnet_id
}

# VM Information
output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.compute.vm_id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.compute.vm_name
}

output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.network.public_ip_address
}

# SSH Connection Information
output "ssh_connection" {
  description = "SSH connection string for the VM"
  value       = "ssh ${var.admin_username}@${module.network.public_ip_address}"
}

# Network Security Group
output "nsg_id" {
  description = "ID of the network security group"
  value       = module.network.nsg_id
}
