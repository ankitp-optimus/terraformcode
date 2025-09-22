# Python Flask App on Azure VM - Complete CI/CD with Azure DevOps

This project demonstrates a complete DevOps pipeline for deploying Python Flask applications to Azure Virtual Machines using Terraform Infrastructure as Code and Azure DevOps Pipelines.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │ Azure DevOps     │    │   Azure VM      │
│                 │    │                  │    │                 │
│ • Flask App     │───▶│ • Infrastructure │───▶│ • Python Flask  │
│ • Terraform     │    │   Pipeline       │    │ • Nginx Proxy   │
│ • Pipeline YAML │    │ • App Deployment │    │ • Auto-Deploy   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🚀 Features

### Infrastructure as Code
- **Terraform**: Modular infrastructure with separate network and compute modules
- **Azure Resources**: VM, VNet, NSG, Public IP, NIC with security best practices
- **Security**: Password authentication, firewall rules, secret management

### Application Deployment
- **Python Flask**: Modern web application with health monitoring endpoints
- **Nginx**: Reverse proxy with load balancing and static file serving
- **Systemd**: Service management for application lifecycle
- **Automated Setup**: Streamlined deployment process

### Dual Pipeline Strategy
- **Infrastructure Pipeline** (`azure-pipelines.yml`): Complete infrastructure + application deployment
- **Application Pipeline** (`app-deployment-pipeline.yml`): Application-only updates to existing VMs

## 📁 Project Structure

```
.
├── azure-pipelines.yml         # Main infrastructure + app pipeline
├── app-deployment-pipeline.yml # Application-only deployment pipeline
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                # Main orchestration
│   ├── variables.tf           # Input variables with parameters
│   ├── locals.tf              # Local values and configuration
│   ├── outputs.tf             # Output values (VM name, public IP)
│   ├── provider.tf            # Azure provider configuration
│   ├── scripts/
│   │   └── setup.sh          # VM setup automation script
│   └── modules/
│       ├── network/          # Network module (VNet, NSG, etc.)
│       └── compute/          # Compute module (VM, network interface)
├── sample-python-app/         # Sample Flask application
│   ├── app.py                # Main Flask application
│   ├── requirements.txt      # Python dependencies
│   └── templates/           # HTML templates
└── PROJECT_README.md         # This documentation
```

## 🛠️ Prerequisites

### Required Tools
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) - Azure command line interface
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5.0 - Infrastructure as Code
- Azure DevOps organization and project
- Azure DevOps service connection

### Azure Requirements
- Azure subscription with Contributor access
- Service Principal for Azure DevOps (configured via service connection)

### Azure DevOps Requirements
- Azure DevOps project with Pipelines enabled
- Service connection to Azure subscription
- Pipeline variables and secret variables configured

## ⚙️ Setup Instructions

### 1. Azure DevOps Service Connection

Create a service connection in Azure DevOps:

1. Go to **Project Settings** → **Service connections**
2. Click **New service connection** → **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Select your Azure subscription
5. Name it: `annkitsubserviceconnection`
6. Save the service connection

### 2. Pipeline Variables Configuration

Set up the secret variable in Azure DevOps:

1. Go to **Pipelines** → **Library** or edit your pipeline
2. Add a **variable**: `VM_ADMIN_PASSWORD`
3. Set the value to your desired VM admin password
4. **Check "Keep this value secret"**
5. Save the variable

### 3. Repository Setup

1. **Clone this repository** to Azure DevOps Repos or connect GitHub repo
2. **Review pipeline parameters** in `azure-pipelines.yml`:
   ```yaml
   parameters:
   - name: app_name
     default: 'flask-app'
   - name: admin_username  
     default: 'azureuser'
   - name: environment
     default: 'dev'
   - name: location
     default: 'East US'
   - name: vm_size
     default: 'Standard_B2s'
   - name: resource_group_name
     default: 'rg-flask-app-dev-ank'
   - name: vm_name
     default: 'vm-flask-app-dev-ank'
   ```

3. **Customize your Flask application** in `sample-python-app/` directory

## 🚀 Deployment Options

### Option 1: Complete Infrastructure + Application Deployment

Use the main pipeline (`azure-pipelines.yml`) for initial deployment:

1. **Create a new pipeline** in Azure DevOps:
   - Go to **Pipelines** → **New pipeline**
   - Select your repository
   - Choose **Existing Azure Pipelines YAML file**
   - Select `azure-pipelines.yml`

2. **Run the pipeline**:
   - You'll see a parameter form to customize deployment
   - Review and adjust parameters as needed
   - Click **Run**

3. **Monitor the deployment**:
   - Watch progress through stages:
     - ✅ Validate Terraform Configuration
     - ✅ Setup Environment  
     - ✅ Deploy Infrastructure
     - ✅ Package Application
     - ✅ Deploy Application to VM
     - ✅ Final Validation and Testing

### Option 2: Application-Only Updates

Use the application deployment pipeline (`app-deployment-pipeline.yml`) for updates:

1. **Create application deployment pipeline**:
   - Go to **Pipelines** → **New pipeline**
   - Select `app-deployment-pipeline.yml`

2. **Deploy application updates**:
   - Specify target VM and resource group
   - Pipeline will:
     - ✅ Package new application version
     - ✅ Backup current application
     - ✅ Deploy to existing VM
     - ✅ Validate deployment
     - ✅ Rollback if needed

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

   - Application will be available at: `http://{vm-public-ip}/`

## 📊 Monitoring and Management

### Application Endpoints

Once deployed, your application provides several monitoring endpoints:

- **Main Application**: `http://{vm-public-ip}/`
- **Health Check**: `http://{vm-public-ip}/health`
- **About Page**: `http://{vm-public-ip}/about`
- **Status Page**: `http://{vm-public-ip}/status`

### VM Management

Connect to your VM using password authentication:

```bash
# Connect via SSH (using sshpass or manual password entry)
ssh azureuser@{vm-public-ip}

# Check application service status
sudo systemctl status flask-app

# View application logs
sudo journalctl -u flask-app -f

# Check nginx status
sudo systemctl status nginx

# View nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Application Updates

To update your application, use the **Application Deployment Pipeline**:

1. **Trigger the app-deployment pipeline** in Azure DevOps
2. **Specify target VM** parameters
3. **Monitor deployment** progress:
   - ✅ Package Application
   - ✅ Get VM Information  
   - ✅ Deploy Application (with backup)
   - ✅ Validate Deployment
   - 🔄 Rollback (if needed)

## 🔧 Customization

### Modifying the Flask Application

1. Update files in `sample-python-app/` directory
2. Modify `requirements.txt` for additional dependencies
3. Update templates in `templates/` directory
4. Run the application deployment pipeline to deploy changes

### Infrastructure Customization

1. **VM Size**: Modify `vm_size` parameter in pipeline
2. **Location**: Update `location` parameter  
3. **Resource Names**: Customize `resource_group_name` and `vm_name`
4. **Environment**: Change `environment` parameter (dev/staging/prod)
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

### Security Considerations

1. **Password Management**: Always use Azure DevOps secret variables for passwords
2. **Network Security**: NSG rules restrict access to required ports only
3. **Service Management**: Application runs as systemd service with proper isolation

## 🐛 Troubleshooting

### Common Issues

1. **Pipeline Authentication Issues**:
   - Verify Azure DevOps service connection is working
   - Check service connection permissions (Contributor role required)

2. **Secret Variable Issues**:
   - Ensure `VM_ADMIN_PASSWORD` is set as secret variable
   - Verify variable name matches exactly in pipeline

3. **Terraform Validation Errors**:
   - Check Terraform syntax in modules
   - Verify all required outputs are defined in compute module

4. **Application Deployment Failures**:
   - Check VM is running and accessible
   - Verify SSH connection using password authentication
   - Review application logs on VM

5. **Application Not Responding**:
   - Check systemd service status: `sudo systemctl status flask-app`
   - Review nginx configuration and status
   - Verify application is listening on correct port

### Debug Commands

```bash
# Connect to VM
ssh azureuser@{vm-public-ip}

# Check service status
sudo systemctl status flask-app
sudo systemctl status nginx

# View application logs
sudo journalctl -u flask-app -n 50

# Check application is running
curl localhost:5000/health

# Test nginx proxy
curl localhost/health

# Check open ports
sudo netstat -tlnp | grep -E ":(80|5000)"
```

### Pipeline Debugging

1. **Infrastructure Pipeline Issues**:
   - Check Terraform validation stage for syntax errors
   - Verify all pipeline parameters are correctly set
   - Monitor Terraform apply logs for resource creation issues

2. **Application Pipeline Issues**:
   - Verify target VM exists and is running
   - Check VM IP retrieval in "Get VM Information" stage
   - Monitor deployment logs for SSH connection issues

## 🔄 Pipeline Management

### Infrastructure Pipeline (`azure-pipelines.yml`)
- **Use for**: Initial deployment, infrastructure changes
- **Stages**: Validate → Setup → Deploy → Package → Deploy App → Test
- **Duration**: ~10-15 minutes
- **Triggers**: Manual or on code changes

### Application Pipeline (`app-deployment-pipeline.yml`)  
- **Use for**: Application updates, bug fixes, new features
- **Stages**: Package → Get VM Info → Deploy → Validate → Rollback (if needed)
- **Duration**: ~5-8 minutes  
- **Triggers**: Manual or automated on app changes

## 📚 Additional Resources

- [Azure DevOps Pipelines Documentation](https://docs.microsoft.com/en-us/azure/devops/pipelines/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Azure VM Documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test using the application deployment pipeline
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙋‍♂️ Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review Azure DevOps pipeline logs
3. Check Azure portal for resource status
4. Create an issue in this repository

---

**Built with ❤️ using Azure DevOps, Terraform, and Flask**

**Happy Deploying!** 🚀