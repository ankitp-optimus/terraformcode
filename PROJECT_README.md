# Python Flask App on Azure VM - Complete CI/CD Pipeline

This project demonstrates a complete DevOps pipeline for deploying Python Flask applications to Azure Virtual Machines using Terraform Infrastructure as Code and GitHub Actions CI/CD.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │  GitHub Actions  │    │   Azure VM      │
│                 │    │                  │    │                 │
│ • Flask App     │───▶│ • Terraform      │───▶│ • Python Flask  │
│ • Terraform     │    │ • VM Provisioning│    │ • Nginx Proxy   │
│ • CI/CD Config  │    │ • App Deployment │    │ • Auto-Deploy   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Features

### Infrastructure as Code
- **Terraform**: Modular infrastructure with separate network and compute modules
- **Azure Resources**: VM, VNet, NSG, Public IP, NIC with best practices
- **Security**: SSH key authentication, firewall rules, least privilege access

### Application Deployment
- **Python Flask**: Modern web application with health monitoring
- **Nginx**: Reverse proxy with load balancing and static file serving
- **Supervisor**: Process management for application lifecycle
- **Auto-deployment**: Automated GitHub repository cloning and setup

### CI/CD Pipeline
- **GitHub Actions**: Complete pipeline with infrastructure provisioning
- **Automated Testing**: Health checks, performance testing, security scanning
- **Monitoring**: Real-time application and system monitoring
- **Cleanup**: Optional infrastructure destruction for cost management

## 📁 Project Structure

```
.
├── .github/workflows/
│   └── deploy.yml              # GitHub Actions CI/CD pipeline
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                # Main orchestration
│   ├── variables.tf           # Input variables
│   ├── locals.tf              # Local values and configuration
│   ├── outputs.tf             # Output values
│   ├── provider.tf            # Provider configuration
│   ├── variable.tfvars        # Example variable values
│   ├── scripts/
│   │   └── setup.sh          # VM setup automation script
│   └── modules/
│       ├── network/          # Network module (VNet, NSG, etc.)
│       └── compute/          # Compute module (VM, extensions)
├── sample-python-app/         # Sample Flask application
│   ├── app.py                # Main Flask application
│   ├── requirements.txt      # Python dependencies
│   └── templates/           # HTML templates
└── README.md                 # This file
```

## 🛠️ Prerequisites

### Required Tools
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) - Azure command line interface
- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0 - Infrastructure as Code
- [Git](https://git-scm.com/downloads) - Version control
- SSH key pair for VM authentication

### Azure Requirements
- Azure subscription with Contributor access
- Service Principal for GitHub Actions (see setup below)

### GitHub Requirements
- GitHub repository with Actions enabled
- Repository secrets configured (see setup below)

## ⚙️ Setup Instructions

### 1. Azure Service Principal Setup

Create a service principal for GitHub Actions:

```bash
# Login to Azure
az login

# Create service principal
az ad sp create-for-rbac --name "github-actions-terraform" \
  --role contributor \
  --scopes /subscriptions/{subscription-id} \
  --sdk-auth
```

### 2. SSH Key Generation

Generate SSH key pair for VM access:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/azure_vm_key

# Copy public key content
cat ~/.ssh/azure_vm_key.pub
```

### 3. GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | Output from step 1 |
| `SSH_PUBLIC_KEY` | SSH public key content | Content from step 2 |

To add secrets:
1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the appropriate value

### 4. Repository Configuration

1. **Fork or clone this repository**
2. **Update `terraform/variable.tfvars`**:
   ```hcl
   # Update with your values
   resource_group_name = "rg-your-flask-app"
   vm_name = "your-flask-vm"
   admin_username = "azureuser"
   admin_ssh_key = "ssh-rsa AAAAB3NzaC1yc2E... your-public-key"
   github_repo_url = "https://github.com/your-username/your-repo.git"
   app_name = "your-flask-app"
   ```

3. **Customize your Flask application** in `sample-python-app/` directory

## 🚀 Deployment

### Automated Deployment (Recommended)

1. **Push to main branch**:
   ```bash
   git add .
   git commit -m "Deploy Flask app to Azure"
   git push origin main
   ```

2. **Monitor the deployment**:
   - Go to **Actions** tab in your GitHub repository
   - Watch the deployment progress
   - View deployment summary with VM details

3. **Access your application**:
   - Application URL will be displayed in the GitHub Actions summary
   - SSH access details provided for troubleshooting

### Manual Deployment

For local testing or manual deployment:

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply deployment
terraform apply -var-file="terraform.tfvars"

# Get outputs
terraform output
```

## 📊 Monitoring and Management

### Application Endpoints

Once deployed, your application provides several monitoring endpoints:

- **Main Application**: `http://{vm-ip}/`
- **Health Check**: `http://{vm-ip}/health`
- **System Status**: `http://{vm-ip}/status`
- **System Info API**: `http://{vm-ip}/api/info`

### VM Management

SSH into your VM for management:

```bash
# SSH into VM
ssh azureuser@{vm-ip}

# Check application status
sudo supervisorctl status python-flask-app

# View application logs
sudo tail -f /var/log/python-flask-app.log

# Check nginx status
sudo systemctl status nginx

# Run status script
./status.sh
```

### Application Updates

To update your application:

```bash
# SSH into VM
ssh azureuser@{vm-ip}

# Navigate to app directory
cd /home/azureuser/python-flask-app

# Run deployment script
./deploy.sh
```

## 🔧 Customization

### Modifying the Flask Application

1. Update files in `sample-python-app/` directory
2. Modify `requirements.txt` for additional dependencies
3. Update templates in `templates/` directory
4. Commit and push changes to trigger deployment

### Infrastructure Customization

1. **VM Size**: Modify `vm_size` in `locals.tf`
2. **Network**: Update address spaces in `locals.tf`
3. **Security Rules**: Add/modify rules in `locals.tf`
4. **Tags**: Update common tags in `locals.tf`

### Pipeline Customization

1. **Deployment Triggers**: Modify `on:` section in `.github/workflows/deploy.yml`
2. **Testing**: Add additional testing steps in the pipeline
3. **Notifications**: Add Slack/Teams notifications on deployment
4. **Environment**: Add staging/production environment support

## 🛡️ Security Best Practices

### Implemented Security Features

- ✅ SSH key-only authentication (no passwords)
- ✅ Network Security Groups with minimal required ports
- ✅ UFW firewall configuration
- ✅ Non-root application execution
- ✅ Secure service management with Supervisor
- ✅ Regular security updates in setup script

### Additional Security Recommendations

- 🔒 Use Azure Key Vault for secrets management
- 🔒 Implement SSL/TLS certificates for HTTPS
- 🔒 Set up Azure Security Center monitoring
- 🔒 Configure log analytics and alerting
- 🔒 Implement backup and disaster recovery

## 💰 Cost Management

### Cost Optimization

- **VM Size**: Use appropriate VM size for your workload
- **Auto-shutdown**: Implement VM auto-shutdown schedules
- **Resource Cleanup**: Use GitHub Actions cleanup job
- **Monitoring**: Set up Azure cost alerts

### Cleanup

To destroy infrastructure and stop costs:

1. **Via GitHub Actions**:
   - Go to **Actions** → **Deploy Python Flask App to Azure VM**
   - Click **Run workflow**
   - Set **Destroy infrastructure** to `true`

2. **Manual cleanup**:
   ```bash
   cd terraform
   terraform destroy -var-file="terraform.tfvars"
   ```

## 🐛 Troubleshooting

### Common Issues

1. **SSH Key Issues**:
   - Ensure SSH public key is correctly formatted
   - Verify key permissions (600 for private key)

2. **Terraform Errors**:
   - Check Azure credentials and permissions
   - Verify subscription ID and region availability

3. **Application Not Starting**:
   - Check VM extension logs: `/var/log/waagent.log`
   - Review application logs: `/var/log/python-flask-app.log`

4. **Network Issues**:
   - Verify NSG rules allow required ports
   - Check UFW firewall status

### Debug Commands

```bash
# SSH into VM
ssh azureuser@{vm-ip}

# Check all services
sudo systemctl list-units --failed

# View setup logs
sudo tail -f /var/log/app-setup.log

# Check nginx configuration
sudo nginx -t

# Test application locally
curl localhost:5000/health
```

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure VM Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review GitHub Actions logs for deployment issues
3. Check Azure portal for resource status
4. Create an issue in this repository

---

**Happy Deploying!** 🚀