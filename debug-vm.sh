#!/bin/bash

# VM Debugging Script
# This script helps debug issues with the VM deployment and application
# Usage: ./debug-vm.sh <VM_IP> <SSH_KEY_PATH> [APP_NAME] [ADMIN_USERNAME]

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
    echo "  $0 20.123.45.67 ~/.ssh/id_rsa python-flask-app azureuser"
    exit 1
fi

# Validate SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "❌ ERROR: SSH key not found at: $SSH_KEY_PATH"
    exit 1
fi

echo "=== VM DEBUGGING SCRIPT ==="
echo "VM IP: $VM_IP"
echo "SSH Key: $SSH_KEY_PATH"
echo "App Name: $APP_NAME"
echo "Admin User: $ADMIN_USERNAME"
echo "=========================="

# Setup SSH
chmod 600 "$SSH_KEY_PATH"
SSH_OPTS="-i $SSH_KEY_PATH -o ConnectTimeout=30 -o StrictHostKeyChecking=no"

echo ""
echo "=== 1. TESTING BASIC CONNECTIVITY ==="
echo "Testing ping..."
if ping -c 3 $VM_IP; then
    echo "✅ VM is reachable via ping"
else
    echo "❌ VM is not reachable via ping"
fi

echo ""
echo "Testing SSH connectivity..."
if ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "echo 'SSH connection successful!'"; then
    echo "✅ SSH connection successful"
else
    echo "❌ SSH connection failed"
    exit 1
fi

echo ""
echo "=== 2. CHECKING VM SETUP STATUS ==="
echo "Checking VM extension script logs..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "tail -20 /var/log/app-setup.log 2>/dev/null || echo 'Setup log not found'"

echo ""
echo "Checking if setup completed successfully..."
if ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "grep -q 'VM setup completed successfully' /var/log/app-setup.log 2>/dev/null"; then
    echo "✅ VM setup script completed successfully"
else
    echo "❌ VM setup script may not have completed successfully"
fi

echo ""
echo "=== 3. CHECKING SYSTEM SERVICES ==="
echo "Checking nginx status..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo systemctl status nginx --no-pager -l"

echo ""
echo "Checking application service (supervisor)..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo supervisorctl status $APP_NAME 2>/dev/null || echo 'Not managed by supervisor'"

echo ""
echo "Checking application service (systemd)..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo systemctl status $APP_NAME --no-pager -l 2>/dev/null || echo 'Not managed by systemd'"

echo ""
echo "=== 4. CHECKING NETWORK PORTS ==="
echo "Checking listening ports..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo netstat -tlnp | grep -E ':(80|5000|22)'"

echo ""
echo "Testing port 80 from outside..."
if nc -zv $VM_IP 80; then
    echo "✅ Port 80 is accessible"
else
    echo "❌ Port 80 is not accessible"
fi

echo ""
echo "=== 5. CHECKING APPLICATION STATUS ==="
echo "Testing Flask app directly (port 5000)..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "curl -f -s http://localhost:5000/health 2>/dev/null && echo '✅ Flask app responding' || echo '❌ Flask app not responding'"

echo ""
echo "Testing through nginx (port 80)..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "curl -f -s http://localhost/health 2>/dev/null && echo '✅ Nginx proxy working' || echo '❌ Nginx proxy not working'"

echo ""
echo "Testing from external access..."
if curl -f -s "http://$VM_IP/health" >/dev/null 2>&1; then
    echo "✅ Application accessible externally"
    curl -s "http://$VM_IP/health"
else
    echo "❌ Application not accessible externally"
fi

echo ""
echo "=== 6. CHECKING LOGS ==="
echo "Application logs (last 20 lines)..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo tail -20 /var/log/$APP_NAME.log 2>/dev/null || echo 'No application logs found'"

echo ""
echo "Nginx error logs (last 10 lines)..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo tail -10 /var/log/nginx/error.log 2>/dev/null || echo 'No nginx error logs'"

echo ""
echo "=== 7. CHECKING APPLICATION FILES ==="
echo "Application directory contents..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "ls -la /home/$ADMIN_USERNAME/$APP_NAME/"

echo ""
echo "Checking if app.py exists and is readable..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "test -f /home/$ADMIN_USERNAME/$APP_NAME/app.py && echo '✅ app.py exists' || echo '❌ app.py not found'"

echo ""
echo "Testing Python import..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "cd /home/$ADMIN_USERNAME/$APP_NAME && source venv/bin/activate && python -c 'import app; print(\"✅ App imports successfully\")' 2>/dev/null || echo '❌ App import failed'"

echo ""
echo "=== 8. FIREWALL AND SECURITY ==="
echo "Checking firewall status..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "sudo ufw status"

echo ""
echo "=== 9. SYSTEM RESOURCES ==="
echo "Checking system resources..."
ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP "free -h && df -h | head -5"

echo ""
echo "=== DEBUGGING COMPLETE ==="
echo "If the application is still not working, check:"
echo "1. Azure NSG rules allow HTTP (port 80) and SSH (port 22)"
echo "2. VM extension script completed successfully"
echo "3. Application service is running (supervisor or systemd)"
echo "4. Nginx is configured correctly and running"
echo "5. Application files are in the correct location"
echo ""
echo "To manually restart services:"
echo "ssh $SSH_OPTS $ADMIN_USERNAME@$VM_IP 'sudo supervisorctl restart $APP_NAME && sudo systemctl reload nginx'"
