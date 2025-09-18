# Azure DevOps Pipeline Setup Guide

## Prerequisites

Before using this Azure DevOps pipeline, ensure you have the following configured:

### 1. Azure Service Connection
1. Go to your Azure DevOps project
2. Navigate to Project Settings → Service connections
3. Create a new Azure Resource Manager service connection
4. Choose "Service principal (automatic)" 
5. Select your Azure subscription and resource group scope
6. Name it `azure-service-connection` (or update the variable in pipeline)

### 2. Pipeline Variables
Update these variables in the pipeline YAML file or in Azure DevOps:

```yaml
variables:
  azureServiceConnection: 'your-service-connection-name'  # Update this
  location: 'East US'  # Choose your preferred Azure region
  resource_group_prefix: 'rg-flask-app'  # Customize as needed
  vm_name_prefix: 'vm-flask'  # Customize as needed
  admin_username: 'azureuser'  # VM admin username
```

### 3. Repository Structure
Ensure your repository has this structure:
```
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── locals.tf
│   └── modules/
├── sample-python-app/
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
└── azure-pipelines-fixed.yml
```

## Pipeline Features

### 🔑 Automatic SSH Key Generation
- Pipeline automatically generates SSH key pairs
- Public key is used for VM provisioning
- Private key is securely stored for SSH access testing
- Keys are published as pipeline artifacts

### 🏗️ Infrastructure as Code
- Terraform provisions Azure resources
- Modular architecture with network and compute modules
- Automatic resource naming with build ID suffix
- Clean resource group organization

### 🚀 Application Deployment
- Python Flask app with nginx reverse proxy
- Supervisor for process management
- Health monitoring endpoints
- Bootstrap UI with system status

### 🧪 Automated Testing
- Infrastructure validation with Terraform
- Application endpoint testing
- SSH connectivity verification
- Health check monitoring

### 📊 Comprehensive Reporting
- Deployment summary with all connection details
- Resource information and URLs
- SSH access commands
- Pipeline artifacts for troubleshooting

## Pipeline Stages

### 1. Validate
- **Purpose**: Code validation and SSH key generation
- **Actions**:
  - Install Terraform
  - Generate SSH key pair
  - Validate Terraform configuration
  - Validate Python application
  - Publish SSH keys as artifacts

### 2. Deploy
- **Purpose**: Infrastructure provisioning
- **Actions**:
  - Download SSH keys
  - Deploy Azure infrastructure with Terraform
  - Configure VM with custom script extension
  - Output connection details

### 3. Validate_Deployment
- **Purpose**: Application and connectivity testing
- **Actions**:
  - Test application endpoints
  - Verify SSH access
  - Check service status
  - Generate deployment summary

### 4. Cleanup (Optional)
- **Purpose**: Resource cleanup
- **Trigger**: Set `cleanup_resources` variable to `true`
- **Actions**: Delete resource group and all resources

## Usage Instructions

### Setup Pipeline
1. Copy `azure-pipelines-fixed.yml` to your repository root
2. Update the `azureServiceConnection` variable
3. Commit and push to trigger the pipeline

### Customize Configuration
```yaml
# In azure-pipelines-fixed.yml, update these variables:
variables:
  azureServiceConnection: 'your-connection-name'
  location: 'East US'  # Your preferred region
  app_name: 'your-app-name'
  resource_group_prefix: 'rg-your-app'
```

### Monitor Deployment
1. Check pipeline progress in Azure DevOps
2. View artifacts for SSH keys and deployment summary
3. Access application at the provided public IP
4. Use SSH commands from deployment summary

### Access Your Application
After successful deployment, you can access:
- **Application**: `http://<VM_PUBLIC_IP>/`
- **Health Check**: `http://<VM_PUBLIC_IP>/health`
- **System Status**: `http://<VM_PUBLIC_IP>/status`
- **API**: `http://<VM_PUBLIC_IP>/api/info`

### SSH Access
```bash
# Use the private key from pipeline artifacts
ssh -i path/to/private/key azureuser@<VM_PUBLIC_IP>
```

## Troubleshooting

### Pipeline Fails at Terraform Install
- Ensure the Azure service connection has proper permissions
- Check that the subscription has available quota

### Application Not Responding
- Check the VM custom script extension logs
- Verify nginx and supervisor service status via SSH
- Review application logs at `/var/log/your-app/`

### SSH Connection Issues
- Ensure NSG allows SSH traffic (port 22)
- Verify the SSH key was properly generated and deployed
- Check VM network configuration

### Resource Naming Conflicts
- Pipeline uses build ID suffix to ensure uniqueness
- If needed, manually clean up existing resources

## Security Considerations

### SSH Keys
- Keys are automatically generated per deployment
- Private keys are marked as secret variables
- Keys are published as secure artifacts

### Network Security
- NSG rules allow only required ports (22, 80, 443, 5000)
- VM uses public key authentication only
- No password authentication enabled

### Resource Management
- Resources are tagged with deployment information
- Optional cleanup stage for development environments
- Production resources should be manually managed

## Cost Optimization

### VM Size
Default configuration uses `Standard_B1s` (1 vCPU, 1 GB RAM)
```hcl
# In terraform/modules/compute/main.tf
vm_size = "Standard_B1s"  # Modify for your needs
```

### Resource Cleanup
Enable automatic cleanup for development:
```yaml
# Set pipeline variable
cleanup_resources: 'true'
```

## Next Steps

1. **Custom Domain**: Configure DNS and SSL certificates
2. **Load Balancing**: Add Azure Load Balancer for multiple VMs
3. **Monitoring**: Integrate with Azure Monitor and Application Insights
4. **Database**: Add Azure Database for PostgreSQL/MySQL
5. **Container Deployment**: Migrate to Azure Container Instances or AKS

## Support

For issues or questions:
1. Check Azure DevOps pipeline logs
2. Review Terraform state and outputs
3. Examine VM extension logs via SSH
4. Consult Azure documentation for service-specific issues