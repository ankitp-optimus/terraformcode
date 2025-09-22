# Azure Service Connection Setup

## The Problem
Your pipeline is failing because it references a service connection `$(serviceConnectionName)` that doesn't exist yet.

## Quick Fix Options

### Option 1: Create Service Connection in Azure DevOps (Recommended)

1. **Go to Azure DevOps**:
   - Navigate to your project in Azure DevOps
   - Go to **Project Settings** (bottom left)

2. **Create Service Connection**:
   - Click **Service connections** 
   - Click **New service connection**
   - Select **Azure Resource Manager**
   - Choose **Service principal (automatic)**
   - Select your **Subscription**
   - Leave **Resource group** empty (for full subscription access)
   - **Service connection name**: Enter `Azure-Service-Connection`
   - Click **Save**

3. **Grant Pipeline Permission**:
   - After creating, click on the service connection
   - Go to **Security** tab
   - Check **Grant access permission to all pipelines**

### Option 2: Update Pipeline with Your Existing Service Connection

If you already have a service connection:

1. **Find Your Service Connection Name**:
   - Go to **Project Settings** > **Service connections**
   - Copy the exact name of your existing Azure service connection

2. **Update the Pipeline**:
   - In `azure-pipelines.yml`, line 9, replace:
   ```yaml
   serviceConnectionName: 'Azure-Service-Connection'
   ```
   - With your actual service connection name:
   ```yaml
   serviceConnectionName: 'YourActualServiceConnectionName'
   ```

### Option 3: Use Direct Service Connection Reference

Alternative: Replace the variable reference directly in the pipeline:

In line 65, change:
```yaml
azureSubscription: '$(serviceConnectionName)'
```

To your actual service connection name:
```yaml
azureSubscription: 'YourActualServiceConnectionName'
```

## Verify Setup

After creating the service connection, run the pipeline again. It should now be able to authenticate with Azure and deploy your infrastructure.

## Security Note

The service connection will have permissions to create resources in your Azure subscription. Make sure it has appropriate permissions (Contributor role is typically sufficient for this demo).