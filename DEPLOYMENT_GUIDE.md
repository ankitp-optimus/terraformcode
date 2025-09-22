# Application Deployment Guide

## 📋 Pre-requisites Checklist

- [ ] Azure subscription with Contributor access
- [ ] Azure DevOps organization and project setup
- [ ] Service connection: `annkitsubserviceconnection` configured in Azure DevOps
- [ ] Secret variable: `VM_ADMIN_PASSWORD` set in Azure DevOps project
- [ ] Target VM already deployed and running with public IP
- [ ] VM configured with password authentication (not SSH keys)

## 🚀 Deployment Process

### Option 1: Complete Infrastructure + Application Deployment (First Time)

1. **Navigate to Azure DevOps** → **Pipelines** → **New pipeline**
2. **Select repository** and choose `azure-pipelines.yml`
3. **Configure pipeline parameters**:
   - `app_name`: `flask-app`
   - `admin_username`: `azureuser`
   - `environment`: `dev`
   - `location`: `East US`
   - `vm_size`: `Standard_B2s`
   - `resource_group_name`: `rg-flask-app-dev-ank`
   - `vm_name`: `vm-flask-app-dev-ank`
   - `admin_password`: (will use secret variable `VM_ADMIN_PASSWORD`)
4. **Run pipeline** and wait for completion (~10-15 minutes)
5. **Note the VM public IP** from pipeline output for future reference

### Option 2: Application-Only Deployment (Recommended for Updates)

1. **Navigate to Azure DevOps** → **Pipelines** → **New pipeline**
2. **Select repository** and choose `app-deployment-pipeline.yml`
3. **Configure pipeline parameters**:
   - `app_name`: Application name (default: `flask-app`)
   - `target_vm_name`: Target VM name (default: `vm-flask-app-dev-ank`)
   - `target_resource_group`: Resource group (default: `rg-flask-app-dev-ank`)
   - `admin_username`: VM admin username (default: `azureuser`)
   - `skip_tests`: Skip validation tests (default: `false`)
4. **Run pipeline** and monitor the deployment stages

## 📊 Pipeline Stages Explained

### Application Deployment Pipeline Stages:

1. **Package Application**: 
   - Copies application files from `sample-python-app/`
   - Adds version information (build number, commit hash, deployment time)
   - Creates pipeline artifact for deployment

2. **Get VM Information**:
   - Retrieves target VM's public IP address
   - Verifies VM is running (starts if stopped)
   - Validates VM accessibility

3. **Deploy Application**:
   - Creates backup of current application (timestamped)
   - Stops existing application service
   - Deploys new application files via SSH/SCP
   - Installs/updates Python dependencies
   - Starts and enables application service

4. **Validate Deployment**:
   - Tests critical endpoints: `/health`, `/`, `/about`
   - Validates application responsiveness
   - Reports deployment success/failure

5. **Rollback (Automatic on Failure)**:
   - Triggers only if deployment/validation fails
   - Restores most recent backup
   - Restarts application service
   - Provides recovery mechanism

## 🔗 Application Access

After successful deployment, access your application at:
- **Main Application**: `http://{vm-public-ip}/`
- **Health Check**: `http://{vm-public-ip}/health`
- **About Page**: `http://{vm-public-ip}/about`
- **API Endpoints**: 
  - `http://{vm-public-ip}/api/deployment` - Deployment information
  - `http://{vm-public-ip}/api/test` - Test endpoint
  - `http://{vm-public-ip}/api/echo` - Echo service

## 🔄 Backup and Rollback Strategy

### Automatic Backup:
- Before each deployment, the pipeline creates a timestamped backup
- Backup location: `/home/{admin_username}/{app_name}_backup_{timestamp}`
- Only the most recent version is backed up (previous backups are overwritten)

### Rollback Process:
- **Automatic**: Triggers when deployment or validation fails
- **Manual**: Can be tested by introducing deployment failures
- Restores the most recent backup and restarts services
- **Note**: Rollback stage is skipped when deployment succeeds (expected behavior)

## 🛠️ Pipeline Management

### Infrastructure Pipeline (`azure-pipelines.yml`)
- **Purpose**: Complete infrastructure setup + initial application deployment
- **When to use**: First-time setup, infrastructure changes, VM configuration updates
- **Stages**: Validate → Setup → Deploy Infrastructure → Package App → Deploy App → Test
- **Duration**: ~10-15 minutes
- **Frequency**: Once initially, then only for infrastructure modifications

### Application Pipeline (`app-deployment-pipeline.yml`)
- **Purpose**: Application-only deployments with backup/rollback
- **When to use**: Application updates, new features, bug fixes, version updates
- **Stages**: Package → Get VM Info → Deploy → Validate → Rollback (if failed)
- **Duration**: ~5-8 minutes
- **Frequency**: Every application update/release

### Key Differences:
- **Infrastructure Pipeline**: Sets up entire environment (VM, networking, services)
- **Application Pipeline**: Updates application code only on existing infrastructure
- **Application Pipeline**: Includes automatic backup and rollback capabilities

## ⚡ Quick Commands

### Check Application Status
```bash
# SSH to VM
ssh azureuser@{vm-public-ip}

# Check application service status
sudo systemctl status flask-app

# Check web server status  
sudo systemctl status nginx

# Check all services
sudo systemctl status flask-app nginx
```

### View Application Logs
```bash
# SSH to VM
ssh azureuser@{vm-public-ip}

# View application logs (real-time)
sudo journalctl -u flask-app -f

# View web server logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# View recent application logs
sudo journalctl -u flask-app --since "1 hour ago"
```

### Test Application Endpoints
```bash
# Health check
curl http://{vm-public-ip}/health

# Main application
curl http://{vm-public-ip}/

# About page
curl http://{vm-public-ip}/about

# API endpoints
curl http://{vm-public-ip}/api/deployment
curl http://{vm-public-ip}/api/test
```

### Manual Service Management
```bash
# SSH to VM
ssh azureuser@{vm-public-ip}

# Restart application
sudo systemctl restart flask-app

# Restart web server
sudo systemctl restart nginx

# Stop/Start application
sudo systemctl stop flask-app
sudo systemctl start flask-app

# Enable service auto-start
sudo systemctl enable flask-app
```

## 🆘 Troubleshooting Guide

### Common Pipeline Issues

#### 1. Authentication Failures
**Symptoms**: Pipeline fails with "Access denied" or "Authentication failed"
**Solutions**:
- Verify service connection `annkitsubserviceconnection` is properly configured
- Check Azure subscription permissions (Contributor role required)
- Ensure service principal has access to target resource group

#### 2. VM Not Found Error
**Symptoms**: "Could not find VM" error in Get VM Info stage
**Solutions**:
- Verify VM name matches exactly: `vm-flask-app-dev-ank`
- Check resource group name: `rg-flask-app-dev-ank`
- Ensure VM exists and is in the correct subscription
- Confirm VM is not deleted or in failed state

#### 3. VM IP Retrieval Issues
**Symptoms**: "VM IP is empty or null" error
**Solutions**:
- Check if VM has a public IP assigned
- Verify VM is running (pipeline will attempt to start it)
- Ensure VM's public IP is not deleted or deallocated

#### 4. SSH Connection Failures
**Symptoms**: "Failed to connect to VM" error during deployment
**Solutions**:
- Verify `VM_ADMIN_PASSWORD` secret variable is correctly set
- Check VM's Network Security Group allows SSH (port 22)
- Ensure VM is using password authentication (not SSH keys)
- Test manual SSH connection: `ssh azureuser@{vm-ip}`

#### 5. Application Not Responding
**Symptoms**: Validation stage fails with endpoint timeouts
**Solutions**:
- SSH to VM and check service status: `sudo systemctl status flask-app`
- Check application logs: `sudo journalctl -u flask-app -f`
- Verify ports are open in NSG (80, 443)
- Restart services manually:
  ```bash
  sudo systemctl restart flask-app
  sudo systemctl restart nginx
  ```

#### 6. Secret Variable Issues
**Symptoms**: "VM_ADMIN_PASSWORD not found" or authentication errors
**Solutions**:
- Verify `VM_ADMIN_PASSWORD` is set as a **secret variable** in Azure DevOps
- Check variable name matches exactly (case-sensitive)
- Ensure variable is accessible to the pipeline

#### 7. Rollback Stage Always Skipped
**Symptoms**: Rollback stage shows as "Skipped" 
**Explanation**: This is **expected behavior** - rollback only runs when deployment fails
**Solutions**: No action needed unless you want to test rollback functionality

### Application-Specific Issues

#### 8. Python Dependencies Installation Fails
**Symptoms**: Deployment succeeds but application doesn't start
**Solutions**:
- Check requirements.txt exists and is valid
- SSH to VM and manually install dependencies:
  ```bash
  cd /home/azureuser/flask-app
  sudo pip3 install -r requirements.txt
  ```

#### 9. Service Start Failures
**Symptoms**: systemctl start fails during deployment
**Solutions**:
- Check if service file exists: `/etc/systemd/system/flask-app.service`
- Reload systemd: `sudo systemctl daemon-reload`
- Check application code for syntax errors

#### 10. Backup Creation Issues
**Symptoms**: "Backup creation failed" warning
**Solutions**:
- Check disk space on VM: `df -h`
- Verify permissions on application directory
- Ensure previous deployment completed successfully

## 📞 Support and Additional Resources

### Getting Help
1. **First**: Check this troubleshooting guide above
2. **Second**: Review pipeline logs in Azure DevOps for specific error messages
3. **Third**: Check Azure portal for resource status and configuration
4. **Fourth**: Review PROJECT_README.md for detailed technical information
5. **Last Resort**: Create an issue in the repository with:
   - Pipeline run URL
   - Error messages from logs
   - Steps to reproduce the issue

### Important Files
- `app-deployment-pipeline.yml` - Application deployment pipeline
- `azure-pipelines.yml` - Infrastructure deployment pipeline  
- `sample-python-app/` - Application source code
- `terraform/` - Infrastructure as Code definitions
- `PROJECT_README.md` - Detailed technical documentation

### Pipeline Parameters Reference
| Parameter | Description | Default Value | Required |
|-----------|-------------|---------------|----------|
| `app_name` | Application name for services | `flask-app` | Yes |
| `target_vm_name` | Name of target VM | `vm-flask-app-dev-ank` | Yes |
| `target_resource_group` | Azure resource group | `rg-flask-app-dev-ank` | Yes |
| `admin_username` | VM admin username | `azureuser` | Yes |
| `skip_tests` | Skip validation tests | `false` | No |

### Required Variables
- `serviceConnectionName`: `annkitsubserviceconnection` (configured in pipeline)
- `VM_ADMIN_PASSWORD`: Secret variable in Azure DevOps project settings

---

**Last Updated**: September 22, 2025  
**Pipeline Version**: Application Deployment v2.0  
**Supports**: Rolling deployments with automatic backup and rollback