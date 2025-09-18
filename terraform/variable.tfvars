# Terraform Variables File
# Copy this file to terraform.tfvars and customize the values

# Resource Group Configuration
resource_group_name = "rg-terraform-vm-demo"
location            = "East US"

# Virtual Machine Configuration
vm_name        = "demo-vm"
admin_username = "azureuser"

# SSH Key Configuration (REQUIRED)
# Generate an SSH key pair using: ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# Then copy the content of the public key file (usually ~/.ssh/id_rsa.pub)
admin_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... your-public-key-here"

# GitHub Repository Configuration
# Replace with your actual GitHub repository URL
github_repo_url = "https://github.com/your-username/your-repo-name.git"

# Application Configuration
app_name = "python-flask-app"

# GitHub Token (Optional - for private repositories)
# Leave empty for public repositories
# For private repos, use a Personal Access Token
github_token = ""

# Example values:
# github_repo_url = "https://github.com/johndoe/my-flask-app.git"
# app_name = "my-awesome-app"
# github_token = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Note: 
# - Replace the admin_ssh_key value with your actual SSH public key
# - Replace github_repo_url with your actual repository URL
# - Never commit your private key, tokens, or sensitive information to version control
# - You can also set these values using environment variables:
#   - TF_VAR_admin_ssh_key
#   - TF_VAR_github_repo_url
#   - TF_VAR_github_token