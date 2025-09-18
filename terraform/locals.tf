# Local values for orchestration and configuration management
locals {
  # Environment and project settings
  environment = "dev"
  project     = "terraform-vm-deploy"

  # Resource naming with consistent naming convention
  resource_group_name = var.resource_group_name
  location            = var.location

  # Network configuration
  vnet_name               = "${var.vm_name}-vnet"
  subnet_name             = "${var.vm_name}-subnet"
  nsg_name                = "${var.vm_name}-nsg"
  pip_name                = "${var.vm_name}-pip"
  nic_name                = "${var.vm_name}-nic"
  address_space           = ["10.0.0.0/16"]
  subnet_address_prefixes = ["10.0.1.0/24"]

  # VM configuration
  vm_name = var.vm_name
  vm_size = "Standard_B2s"  # Upgraded for better performance with Python apps
  
  # GitHub and deployment configuration
  github_repo_url = var.github_repo_url
  app_name        = var.app_name
  app_port        = 5000  # Default Flask port

  # Common tags for all resources
  common_tags = {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    AppName     = var.app_name
  }

  # Security rules configuration
  security_rules = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTP"
      priority                   = 1002
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "HTTPS"
      priority                   = 1003
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Flask-App"
      priority                   = 1004
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}