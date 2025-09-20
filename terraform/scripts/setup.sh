#!/bin/bash

# VM Setup Script for Python Flask App with Nginx
# This script sets up the VM environment, clones the GitHub repo, and deploys the Python application

set -e  # Exit on any error

# Variables passed from Terraform
GITHUB_REPO_URL="${github_repo_url}"
APP_NAME="${app_name}"
GITHUB_TOKEN="${github_token}"
ADMIN_USER="${admin_username}"
APP_DIR="/home/$ADMIN_USER/$APP_NAME"
SERVICE_NAME="$APP_NAME"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/app-setup.log
}

log "Starting VM setup for $APP_NAME"

# Update system packages
log "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install required packages
log "Installing required packages..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    git \
    curl \
    supervisor \
    ufw \
    htop \
    unzip

# Configure firewall
log "Configuring firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw allow 5000  # Flask default port
ufw --force enable

# Create application directory
log "Setting up application directory..."
mkdir -p $APP_DIR
chown $ADMIN_USER:$ADMIN_USER $APP_DIR

# Clone GitHub repository
log "Cloning GitHub repository..."
cd /home/$ADMIN_USER

# Remove existing directory if it exists
if [ -d "$APP_NAME" ]; then
    log "Removing existing application directory..."
    rm -rf $APP_NAME
fi

if [ ! -z "$GITHUB_TOKEN" ]; then
    # Use token for private repositories
    REPO_URL_WITH_TOKEN=$(echo $GITHUB_REPO_URL | sed "s|https://|https://$GITHUB_TOKEN@|")
    log "Cloning private repository with token..."
    sudo -u $ADMIN_USER git clone $REPO_URL_WITH_TOKEN $APP_NAME
else
    # Public repository
    log "Cloning public repository..."
    sudo -u $ADMIN_USER git clone $GITHUB_REPO_URL $APP_NAME
fi

# Verify the clone was successful
if [ ! -d "$APP_NAME" ]; then
    log "❌ ERROR: Failed to clone repository!"
    log "Repository URL: $GITHUB_REPO_URL"
    exit 1
fi

log "✅ Repository cloned successfully"
log "Repository contents:"
ls -la /home/$ADMIN_USER/$APP_NAME/

# Navigate to app directory
cd $APP_DIR

# Create Python virtual environment
log "Setting up Python virtual environment..."
sudo -u $ADMIN_USER python3 -m venv venv
sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip

# Install Python dependencies
log "Installing Python dependencies..."

# Check repository structure and organize files
log "Analyzing repository structure..."
ls -la $APP_DIR/

# Check if we have sample-python-app directory structure
if [ -d "$APP_DIR/sample-python-app" ]; then
    log "Found sample-python-app directory structure"
    
    # Copy application files to the root directory
    log "Copying application files from sample-python-app to root..."
    sudo -u $ADMIN_USER cp -r $APP_DIR/sample-python-app/* $APP_DIR/
    
    # Verify the copy was successful
    log "Files after copying:"
    ls -la $APP_DIR/*.py 2>/dev/null || log "No Python files found after copying"
    
    # Install dependencies from sample-python-app if it exists
    if [ -f "$APP_DIR/sample-python-app/requirements.txt" ]; then
        log "Installing dependencies from sample-python-app/requirements.txt..."
        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/sample-python-app/requirements.txt
    elif [ -f "$APP_DIR/requirements.txt" ]; then
        log "Installing dependencies from requirements.txt..."
        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/requirements.txt
    else
        log "No requirements.txt found, installing basic dependencies..."
        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil
    fi
else
    log "Using direct application structure"
    
    # Check if app.py exists in root
    if [ -f "$APP_DIR/app.py" ]; then
        log "✅ Found app.py in root directory"
    else
        log "❌ app.py not found in root directory"
        log "Available files:"
        ls -la $APP_DIR/
        
        # Try to find app.py in subdirectories
        APP_PY_LOCATION=$(find $APP_DIR -name "app.py" -type f | head -1)
        if [ -n "$APP_PY_LOCATION" ]; then
            log "Found app.py at: $APP_PY_LOCATION"
            APP_PY_DIR=$(dirname "$APP_PY_LOCATION")
            log "Copying files from $APP_PY_DIR to root..."
            sudo -u $ADMIN_USER cp -r $APP_PY_DIR/* $APP_DIR/
        else
            log "❌ ERROR: app.py not found anywhere in the repository!"
            exit 1
        fi
    fi
    
    if [ -f "$APP_DIR/requirements.txt" ]; then
        log "Installing dependencies from requirements.txt..."
        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/requirements.txt
    else
        # Install basic Flask dependencies if no requirements.txt
        log "No requirements.txt found, installing basic dependencies..."
        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil
    fi
fi

# Final verification of application files
log "Final verification of application files..."
if [ -f "$APP_DIR/app.py" ]; then
    log "✅ app.py found successfully"
    log "File size: $(stat -c%s $APP_DIR/app.py) bytes"
else
    log "❌ CRITICAL ERROR: app.py still not found after setup!"
    log "Current directory contents:"
    ls -la $APP_DIR/
    exit 1
fi

# Test if app can import successfully
log "Testing Flask application..."
cd $APP_DIR
sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('✅ App imports successfully')" || {
    log "❌ ERROR: App failed to import!"
    log "Checking current directory contents:"
    ls -la $APP_DIR
    log "Trying to install missing dependencies..."
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install psutil flask
    
    # Try importing again
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('✅ App imports successfully after installing dependencies')" || {
        log "❌ CRITICAL ERROR: App still fails to import!"
        log "Python path and files:"
        sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import sys; print('Python path:', sys.path)"
        exit 1
    }
}

# Create Gunicorn configuration
log "Creating Gunicorn configuration..."
cat > /etc/supervisor/conf.d/$SERVICE_NAME.conf << EOF
[program:$SERVICE_NAME]
command=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 2 --timeout 120 --log-level info app:app
directory=$APP_DIR
user=$ADMIN_USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/$SERVICE_NAME.log
EOF

# Create Nginx configuration
log "Configuring Nginx..."
cat > /etc/nginx/sites-available/$SERVICE_NAME << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /health {
        proxy_pass http://127.0.0.1:5000/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Static files (if any)
    location /static {
        alias $APP_DIR/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable Nginx site
ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Create a simple systemd service as backup
log "Creating systemd service..."
cat > /etc/systemd/system/$SERVICE_NAME.service << EOF
[Unit]
Description=$APP_NAME Flask Application
After=network.target

[Service]
Type=simple
User=$ADMIN_USER
WorkingDirectory=$APP_DIR
Environment=PATH=$APP_DIR/venv/bin
ExecStart=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 3 app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create deployment script for future updates
log "Creating deployment script..."
cat > $APP_DIR/deploy.sh << 'EOF'
#!/bin/bash

# Deployment script for application updates
APP_DIR="/home/${admin_username}/${app_name}"
SERVICE_NAME="${app_name}"

cd $APP_DIR

# Pull latest changes
git pull origin main

# Activate virtual environment and install/update dependencies
source venv/bin/activate
pip install -r requirements.txt

# Restart services
sudo supervisorctl restart $SERVICE_NAME
sudo systemctl reload nginx

echo "Deployment completed successfully!"
EOF

chmod +x $APP_DIR/deploy.sh
chown $ADMIN_USER:$ADMIN_USER $APP_DIR/deploy.sh

# Start and enable services
log "Starting services..."
systemctl reload supervisor
supervisorctl reread
supervisorctl update

# Start the application service
log "Starting $SERVICE_NAME service..."
supervisorctl start $SERVICE_NAME

# Check if service started successfully
sleep 10
if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then
    log "✅ $SERVICE_NAME service started successfully"
else
    log "❌ $SERVICE_NAME service failed to start"
    log "Service status:"
    supervisorctl status $SERVICE_NAME
    log "Application logs:"
    tail -20 /var/log/$SERVICE_NAME.log || echo "No logs found"
    
    # Try to start with systemd as fallback
    log "Trying to start with systemd as fallback..."
    systemctl enable $SERVICE_NAME
    systemctl start $SERVICE_NAME
    sleep 5
    
    if systemctl is-active --quiet $SERVICE_NAME; then
        log "✅ $SERVICE_NAME started successfully with systemd"
    else
        log "❌ $SERVICE_NAME failed to start with systemd too"
        systemctl status $SERVICE_NAME --no-pager -l
    fi
fi

# Start nginx
log "Starting nginx..."
systemctl enable nginx
systemctl restart nginx

# Check nginx status
if systemctl is-active --quiet nginx; then
    log "✅ Nginx started successfully"
else
    log "❌ Nginx failed to start"
    systemctl status nginx --no-pager -l
fi

systemctl daemon-reload
systemctl enable $SERVICE_NAME

# Create health check script
cat > $APP_DIR/health_check.sh << EOF
#!/bin/bash
echo "Testing Flask app directly..."
curl -f http://localhost:5000/health || exit 1
echo "Testing through nginx..."
curl -f http://localhost/health || exit 1
echo "✅ All health checks passed!"
EOF

chmod +x $APP_DIR/health_check.sh
chown $ADMIN_USER:$ADMIN_USER $APP_DIR/health_check.sh

# Final status check and application testing
log "Performing final status check..."
sleep 15

# Check service status
SERVICE_RUNNING=false
if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then
    log "✅ Application is running successfully via supervisor"
    SERVICE_RUNNING=true
elif systemctl is-active --quiet $SERVICE_NAME; then
    log "✅ Application is running successfully via systemd"
    SERVICE_RUNNING=true
else
    log "❌ Application failed to start with both supervisor and systemd"
    log "Supervisor status:"
    supervisorctl status $SERVICE_NAME || echo "Supervisor not managing service"
    log "Systemd status:"
    systemctl status $SERVICE_NAME --no-pager -l || echo "Systemd not managing service"
    log "Application logs:"
    tail -30 /var/log/$SERVICE_NAME.log || echo "No logs found"
fi

if systemctl is-active --quiet nginx; then
    log "✅ Nginx is running successfully"
else
    log "❌ Nginx failed to start. Check logs: journalctl -u nginx"
    systemctl status nginx --no-pager -l
fi

# Test application endpoints if service is running
if [ "$SERVICE_RUNNING" = true ]; then
    log "Testing application endpoints..."
    
    # Wait a bit more for the application to fully start
    sleep 10
    
    # Test Flask app directly
    if curl -f -s http://localhost:5000/health >/dev/null 2>&1; then
        log "✅ Flask app responding on port 5000"
    else
        log "❌ Flask app not responding on port 5000"
        log "Checking if port 5000 is listening:"
        netstat -tlnp | grep :5000 || echo "Port 5000 not listening"
    fi
    
    # Test through nginx
    if curl -f -s http://localhost/health >/dev/null 2>&1; then
        log "✅ Application accessible through nginx"
    else
        log "❌ Application not accessible through nginx"
        log "Nginx error logs:"
        tail -10 /var/log/nginx/error.log || echo "No nginx error logs"
    fi
else
    log "⚠️  Skipping endpoint tests as application service is not running"
fi

# Display useful information
log "Setup completed!"
log "Application URL: http://$(curl -s ifconfig.me)/"
log "Application logs: /var/log/$SERVICE_NAME.log"
log "Nginx logs: /var/log/nginx/"
log "To deploy updates: cd $APP_DIR && ./deploy.sh"
log "To check health: cd $APP_DIR && ./health_check.sh"

# Create status script for easy monitoring
cat > /home/$ADMIN_USER/status.sh << EOF
#!/bin/bash
echo "=== System Status ==="
echo "Date: \$(date)"
echo ""
echo "=== Service Status ==="
supervisorctl status $SERVICE_NAME
systemctl status nginx --no-pager -l
echo ""
echo "=== Application Health ==="
$APP_DIR/health_check.sh
echo ""
echo "=== System Resources ==="
df -h | grep -E "(Filesystem|/dev/)"
free -h
echo ""
echo "=== Recent Logs ==="
echo "--- Application Logs (last 5 lines) ---"
tail -5 /var/log/$SERVICE_NAME.log
echo "--- Nginx Access Logs (last 5 lines) ---"
tail -5 /var/log/nginx/access.log
EOF

chmod +x /home/$ADMIN_USER/status.sh
chown $ADMIN_USER:$ADMIN_USER /home/$ADMIN_USER/status.sh

log "VM setup completed successfully! 🎉"