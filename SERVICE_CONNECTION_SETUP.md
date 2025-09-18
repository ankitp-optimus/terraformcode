# Azure DevOps Service Connection Setup Guide

## 🚨 IMPORTANT: Pipeline Setup Required

Before running the Azure DevOps pipeline, you **MUST** create an Azure service connection. The pipeline cannot run without this step.

## Step 1: Create Azure Service Connection

### 1.1 Navigate to Service Connections
1. Go to your Azure DevOps project
2. Click on **Project Settings** (gear icon in bottom left)
3. Under **Pipelines**, click **Service connections**

### 1.2 Create New Service Connection
1. Click **New service connection**
2. Select **Azure Resource Manager**
3. Click **Next**

### 1.3 Choose Authentication Method
1. Select **Service principal (automatic)**
2. Click **Next**

### 1.4 Configure Connection Details
1. **Scope level**: Choose `Subscription`
2. **Subscription**: Select your Azure subscription
3. **Resource group**: Leave empty (or select specific RG if preferred)
4. **Service connection name**: Enter a name like:
   - `azure-terraform-connection`
   - `azure-flask-app-connection`
   - `my-azure-connection`
5. **Description**: Optional description
6. **Grant access permission to all pipelines**: ✅ Check this box
7. Click **Save**

## Step 2: Update Pipeline Configuration

After creating the service connection, update the pipeline variable:

```yaml
# In azure-pipelines.yml, line ~23
azureServiceConnection: 'your-actual-service-connection-name'
```

### Example Update:
```yaml
# Before (will fail)
azureServiceConnection: 'YOUR_AZURE_SERVICE_CONNECTION_NAME'

# After (with your actual name)
azureServiceConnection: 'azure-terraform-connection'
```

## Step 3: Verify Permissions

Ensure your service connection has the required permissions:

### Required Azure Permissions:
- **Contributor** role on the subscription or resource group
- Ability to create:
  - Resource Groups
  - Virtual Machines
  - Virtual Networks
  - Network Security Groups
  - Public IP addresses
  - Storage Accounts

### Check Permissions:
1. Go to Azure Portal
2. Navigate to **Subscriptions** → Your subscription
3. Click **Access control (IAM)**
4. Look for your service principal with **Contributor** role

## Step 4: Test the Connection

### 4.1 Test in Azure DevOps
1. Go back to **Service connections**
2. Find your newly created connection
3. Click the **three dots** → **Verify**
4. Ensure the test passes

### 4.2 Run Pipeline
1. Commit and push your code changes
2. Go to **Pipelines** in Azure DevOps
3. Run your pipeline
4. The connection should now work

## Troubleshooting

### Error: "Service connection not found"
**Solution**: 
- Double-check the service connection name matches exactly
- Ensure the connection exists and is enabled
- Verify pipeline has permission to use the connection

### Error: "Authorization failed"
**Solution**:
- Check Azure permissions (Contributor role required)
- Verify the service principal is active
- Try recreating the service connection

### Error: "Access denied"
**Solution**:
- Ensure "Grant access permission to all pipelines" was checked
- Manually authorize the pipeline to use the connection:
  1. Go to Service connections
  2. Click your connection
  3. Go to **Security** tab
  4. Add your pipeline

## Alternative: Manual Service Principal Setup

If automatic setup doesn't work, you can create a service principal manually:

### 1. Create Service Principal (Azure CLI)
```bash
az ad sp create-for-rbac --name "terraform-pipeline-sp" \
    --role contributor \
    --scopes /subscriptions/{subscription-id}
```

### 2. Create Service Connection with Manual Values
1. Choose **Service principal (manual)**
2. Enter the values from step 1:
   - **Service Principal Id** (appId)
   - **Service Principal Key** (password)
   - **Tenant ID** (tenant)

## Quick Reference

### Common Service Connection Names:
- `azure-terraform-connection`
- `azure-service-connection`
- `my-azure-subscription`
- `azure-flask-app`

### Pipeline Variable Update Locations:
```yaml
# Line ~23 in azure-pipelines.yml
azureServiceConnection: 'your-connection-name'
```

### Required Azure Roles:
- **Contributor** (minimum)
- **Owner** (if you need to assign roles to resources)

## Next Steps

1. ✅ Create service connection
2. ✅ Update pipeline variable
3. ✅ Commit changes
4. ✅ Run pipeline
5. ✅ Monitor deployment

Once your service connection is set up correctly, the pipeline will be able to:
- Generate SSH keys automatically
- Provision Azure infrastructure
- Deploy your Python Flask application
- Test the deployment

**Need help?** Check the Azure DevOps documentation or your Azure subscription permissions.