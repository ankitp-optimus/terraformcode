# Quick Deployment Guide

## 📋 Pre-requisites Checklist

- [ ] Azure subscription with Contributor access
- [ ] Azure DevOps organization and project
- [ ] Service connection: `annkitsubserviceconnection` configured
- [ ] Secret variable: `VM_ADMIN_PASSWORD` set in Azure DevOps

## 🚀 Deployment Steps

### Step 1: Infrastructure Deployment (First Time)

1. **Go to Azure DevOps** → **Pipelines** → **New pipeline**
2. **Select repository** and choose `azure-pipelines.yml`
3. **Configure parameters**:
   - app_name: `flask-app`
   - admin_username: `azureuser`
   - environment: `dev`
   - location: `East US`
   - vm_size: `Standard_B2s`
   - resource_group_name: `rg-flask-app-dev-ank`
   - vm_name: `vm-flask-app-dev-ank`
4. **Run pipeline** and wait for completion (~10-15 minutes)
5. **Note the VM public IP** from pipeline output

### Step 2: Application Updates (Subsequent Deployments)

1. **Go to Azure DevOps** → **Pipelines** → **New pipeline**
2. **Select repository** and choose `app-deployment-pipeline.yml`
3. **Configure parameters**:
   - app_name: `flask-app`
   - target_vm_name: `vm-flask-app-dev-ank`
   - target_resource_group: `rg-flask-app-dev-ank`
   - admin_username: `azureuser`
   - skip_tests: `false`
4. **Run pipeline** and wait for completion (~5-8 minutes)

## 🔗 Application Access

After successful deployment:
- **Main App**: `http://{vm-public-ip}/`
- **Health Check**: `http://{vm-public-ip}/health`
- **About Page**: `http://{vm-public-ip}/about`

## 🛠️ Pipeline Management

### Infrastructure Pipeline
- **File**: `azure-pipelines.yml`
- **Use for**: Initial setup, infrastructure changes
- **Stages**: Validate → Setup → Deploy → Package → Deploy App → Test
- **Frequency**: Once initially, then only for infrastructure changes

### Application Pipeline
- **File**: `app-deployment-pipeline.yml`
- **Use for**: Application updates, new features, bug fixes
- **Stages**: Package → Get VM Info → Deploy → Validate → Rollback
- **Frequency**: Every application update

## ⚡ Quick Commands

### Check Application Status
```bash
ssh azureuser@{vm-public-ip}
sudo systemctl status flask-app
sudo systemctl status nginx
```

### View Logs
```bash
ssh azureuser@{vm-public-ip}
sudo journalctl -u flask-app -f
sudo tail -f /var/log/nginx/access.log
```

### Test Application
```bash
curl http://{vm-public-ip}/health
curl http://{vm-public-ip}/
```

## 🆘 Troubleshooting Quick Fixes

### Pipeline Fails at Authentication
- Check service connection `annkitsubserviceconnection`
- Verify Azure permissions

### VM Not Found Error
- Ensure resource group and VM name match exactly
- Check VM is running in Azure portal

### Application Not Responding
- SSH to VM and check service status
- Restart services if needed:
  ```bash
  sudo systemctl restart flask-app
  sudo systemctl restart nginx
  ```

### Secret Variable Issues
- Verify `VM_ADMIN_PASSWORD` is set as secret variable
- Check variable name matches exactly in pipeline

## 📞 Support

For issues:
1. Check troubleshooting section in PROJECT_README.md
2. Review pipeline logs in Azure DevOps
3. Check Azure portal for resource status
4. Create issue in repository