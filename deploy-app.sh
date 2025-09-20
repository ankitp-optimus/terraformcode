#!/bin/bash

# Standalone Application Deployment Script
# This script can be used to deploy application updates to an existing VM
# Usage: ./deploy-app.sh <VM_IP> <SSH_KEY_PATH> [APP_NAME]

set -e

# Configuration
DEFAULT_APP_NAME="python-flask-app"
DEFAULT_ADMIN_USERNAME="azureuser"

# Parse command line arguments
VM_IP="$1"
SSH_KEY_PATH="$2"
APP_NAME="${3:-$DEFAULT_APP_NAME}"
ADMIN_USERNAME="${4:-$DEFAULT_ADMIN_USERNAME}"

# Validate arguments
if [ -z "$VM_IP" ] || [ -z "$SSH_KEY_PATH" ]; then
    echo "Usage: $0 <VM_IP> <SSH_KEY_PATH> [APP_NAME] [ADMIN_USERNAME]"
    echo ""
    echo "Examples:"
    echo "  $0 20.123.45.67 ~/.ssh/id_rsa"
    echo "  $0 20.123.45.67 ~/.ssh/id_rsa my-flask-app"
    echo "  $0 20.123.45.67 ~/.ssh/id_rsa my-flask-app myuser"
    exit 1
fi

# Validate SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "❌ ERROR: SSH key not found at: $SSH_KEY_PATH"
    exit 1
fi

# Validate IP format
if ! [[ $VM_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "❌ ERROR: Invalid IP address format: $VM_IP"
    exit 1
fi

echo "=== APPLICATION DEPLOYMENT ==="
echo "VM IP: $VM_IP"
echo "SSH Key: $SSH_KEY_PATH"
echo "App Name: $APP_NAME"
echo "Admin User: $ADMIN_USERNAME"
echo "=============================="

# Setup SSH
chmod 600 "$SSH_KEY_PATH"
SSH_OPTS="-i $SSH_KEY_PATH -o ConnectTimeout=30 -o StrictHostKeyChecking=no"

# Test SSH connection
echo "Testing SSH connection..."
if ! ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "echo 'SSH connection successful!'"; then
    echo "❌ ERROR: Failed to connect to VM via SSH"
    exit 1
fi

echo "✅ SSH connection established"

# Create deployment script to run on the VM
cat > /tmp/vm_deploy.sh << EOF
#!/bin/bash
set -e

APP_NAME="$APP_NAME"
APP_DIR="/home/$ADMIN_USERNAME/\$APP_NAME"

echo "=== VM DEPLOYMENT SCRIPT ==="
echo "App Name: \$APP_NAME"
echo "App Directory: \$APP_DIR"
echo "Current User: \$(whoami)"
echo "============================"

# Check if app directory exists
if [ ! -d "\$APP_DIR" ]; then
    echo "❌ ERROR: Application directory not found: \$APP_DIR"
    echo "Available directories in /home/$ADMIN_USERNAME:"
    ls -la /home/$ADMIN_USERNAME/
    echo "Please ensure the application was initially deployed via Terraform"
    exit 1
fi

# Navigate to app directory
cd \$APP_DIR
echo "Current directory: \$(pwd)"
echo "Directory contents:"
ls -la

# Check if this is a git repository and pull if possible
echo "Checking git repository status..."
if [ -d ".git" ]; then
    echo "Git repository found, pulling latest changes..."
    git pull origin main || git pull origin master || echo "⚠️ Git pull failed, continuing with existing code"
else
    echo "⚠️ Not a git repository, skipping git pull"
fi

# Check and setup virtual environment
echo "Checking virtual environment..."
if [ ! -f "venv/bin/activate" ]; then
    echo "⚠️ Virtual environment not found, creating new one..."
    python3 -m venv venv
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
pip install --upgrade pip

# Install dependencies based on available requirements.txt
echo "Installing Python dependencies..."
if [ -d "sample-python-app" ]; then
    echo "Found sample-python-app directory, copying files..."
    cp -r sample-python-app/* .
    
    if [ -f "sample-python-app/requirements.txt" ]; then
        echo "Installing dependencies from sample-python-app/requirements.txt..."
        pip install -r sample-python-app/requirements.txt
    elif [ -f "requirements.txt" ]; then
        echo "Installing dependencies from requirements.txt..."
        pip install -r requirements.txt
    else
        echo "No requirements.txt found, installing basic dependencies..."
        pip install flask gunicorn psutil
    fi
else
    echo "Using direct application structure..."
    if [ -f "requirements.txt" ]; then
        echo "Installing dependencies from requirements.txt..."
        pip install -r requirements.txt
    else
        echo "No requirements.txt found, installing basic dependencies..."
        pip install flask gunicorn psutil
    fi
fi

# Test the application
echo "Testing application import..."
source venv/bin/activate
python -c "import app; print('✅ App imports successfully')" || {
    echo "❌ ERROR: Application failed to import"
    exit 1
}

# Restart application service (try both supervisor and systemctl)
echo "Restarting application service..."
if sudo supervisorctl status \$APP_NAME >/dev/null 2>&1; then
    echo "Using supervisor to restart \$APP_NAME..."
    sudo supervisorctl restart \$APP_NAME
    sleep 5
    sudo supervisorctl status \$APP_NAME
elif sudo systemctl is-enabled \$APP_NAME >/dev/null 2>&1; then
    echo "Using systemctl to restart \$APP_NAME..."
    sudo systemctl restart \$APP_NAME
    sleep 5
    sudo systemctl status \$APP_NAME --no-pager -l
else
    echo "⚠️  WARNING: Could not find service \$APP_NAME in supervisor or systemctl"
    echo "You may need to manually restart the application"
fi

# Test and reload nginx
echo "Testing and reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

# Wait for services to stabilize
echo "Waiting for services to stabilize..."
sleep 10

# Test application endpoints locally
echo "Testing application endpoints..."
if curl -f -s http://localhost/health >/dev/null; then
    echo "✅ Health endpoint OK"
else
    echo "❌ Health endpoint failed"
fi

if curl -f -s http://localhost/ >/dev/null; then
    echo "✅ Home page OK"
else
    echo "❌ Home page failed"
fi

echo "✅ Application deployment completed successfully!"
EOF

# Copy and execute deployment script on VM
echo "Copying deployment script to VM..."
scp $SSH_OPTS /tmp/vm_deploy.sh $ADMIN_USERNAME@$VM_IP:/tmp/

echo "Executing deployment script on VM..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "chmod +x /tmp/vm_deploy.sh && /tmp/vm_deploy.sh"

# Clean up local temp file
rm -f /tmp/vm_deploy.sh

# Test application from external access
echo "Testing application from external access..."
sleep 10

if curl -f -s "http://$VM_IP/health" >/dev/null; then
    echo "✅ Application is accessible externally"
else
    echo "❌ Application is not accessible externally"
    echo "Check firewall settings and nginx configuration"
fi

echo ""
echo "=== DEPLOYMENT SUMMARY ==="
echo "✅ Application deployed successfully!"
echo "🌐 Application URL: http://$VM_IP/"
echo "🏥 Health Check: http://$VM_IP/health"
echo "🔑 SSH Access: ssh -i $SSH_KEY_PATH $ADMIN_USERNAME@$VM_IP"
echo "=========================="
