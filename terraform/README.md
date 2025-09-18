# Terraform Azure VM Deployment - Modular Architecture

This Terraform configuration deploys a Linux VM on Azure using a modular architecture following best practices.

## Architecture Overview

```
terraform/
├── main.tf              # Main orchestration file
├── variables.tf         # Input variables
├── locals.tf           # Local values for orchestration
├── outputs.tf          # Output values
├── provider.tf         # Provider configuration
├── variable.tfvars     # Example values (rename to terraform.tfvars)
└── modules/
    ├── network/        # Network module
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/        # Compute module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Features

### Modular Design
- **Network Module**: Manages VNet, subnet, NSG, public IP, and NIC
- **Compute Module**: Manages Linux VM and its configuration
- **Separation of Concerns**: Each module handles specific resources

### Best Practices Implemented
- **Locals for Orchestration**: Common values defined in `locals.tf`
- **Consistent Naming**: Resource names follow a pattern using VM name prefix
- **Comprehensive Tagging**: All resources tagged with environment, project, and metadata
- **Security**: SSH key authentication only, password authentication disabled
- **Dynamic Security Rules**: NSG rules defined in locals and applied dynamically

### Resource Tags
All resources are tagged with:
- Environment
- Project
- ManagedBy
- Owner
- CostCenter

## Prerequisites

1. **Azure CLI** installed and configured
2. **Terraform** >= 1.3.0 installed
3. **SSH Key Pair** generated

### Generate SSH Key (if you don't have one)
```bash
# Linux/macOS/WSL
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Windows (Git Bash or PowerShell with OpenSSH)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

## Quick Start

1. **Clone and Navigate**
   ```bash
   cd terraform
   ```

2. **Copy Variables File**
   ```bash
   cp variable.tfvars terraform.tfvars
   ```

3. **Edit terraform.tfvars**
   - Update `admin_ssh_key` with your SSH public key content
   - Customize other values as needed

4. **Initialize Terraform**
   ```bash
   terraform init
   ```

5. **Plan Deployment**
   ```bash
   terraform plan
   ```

6. **Deploy Infrastructure**
   ```bash
   terraform apply
   ```

7. **Connect to VM**
   ```bash
   ssh azureuser@<public_ip_from_output>
   ```

## Configuration

### Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `resource_group_name` | Resource group name | `rg-terraform-vm` |
| `location` | Azure region | `East US` |
| `vm_name` | VM name prefix | `terraform-vm` |
| `admin_username` | VM admin username | `azureuser` |
| `admin_ssh_key` | SSH public key | *Required* |

### Local Values
The `locals.tf` file defines:
- **Naming conventions** for all resources
- **Network configuration** (address spaces, subnets)
- **Common tags** applied to all resources
- **Security rules** for NSG
- **VM specifications**

## Security Configuration

### Network Security Group Rules
- **SSH (Port 22)**: Allows inbound SSH connections
- **HTTP (Port 80)**: Allows inbound HTTP connections

### VM Security
- **SSH Key Authentication**: Only SSH key authentication enabled
- **No Password Authentication**: Password authentication disabled
- **Standard Security**: Uses Azure standard security practices

## Outputs

After deployment, the following information is available:
- Resource group details
- Network information (VNet, subnet IDs)
- VM details (ID, name, IPs)
- SSH connection string
- NSG ID

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Module Details

### Network Module
**Purpose**: Manages all networking components
**Resources**:
- Virtual Network
- Subnet
- Network Security Group
- Public IP (Static, Standard SKU)
- Network Interface
- NSG-Subnet Association

### Compute Module  
**Purpose**: Manages VM and compute resources
**Resources**:
- Linux Virtual Machine
- OS Disk configuration
- SSH key configuration

## Customization

### Adding Security Rules
Edit `locals.tf` to add more security rules:
```hcl
security_rules = [
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
  }
]
```

### Changing VM Size
Update `vm_size` in `locals.tf`:
```hcl
vm_size = "Standard_B2s"  # or any other Azure VM size
```

### Environment-Specific Configurations
Create separate `.tfvars` files for different environments:
- `dev.tfvars`
- `staging.tfvars`
- `prod.tfvars`

Deploy with:
```bash
terraform apply -var-file="dev.tfvars"
```

## Troubleshooting

### Common Issues
1. **SSH Key Format**: Ensure SSH public key is in the correct format
2. **Azure Permissions**: Ensure your Azure account has Contributor access
3. **Region Availability**: Verify the VM size is available in your chosen region

### Validation
```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Check state
terraform show
```