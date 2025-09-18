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

if [ ! -z "$GITHUB_TOKEN" ]; then
    # Use token for private repositories
    REPO_URL_WITH_TOKEN=$(echo $GITHUB_REPO_URL | sed "s|https://|https://$GITHUB_TOKEN@|")
    sudo -u $ADMIN_USER git clone $REPO_URL_WITH_TOKEN $APP_NAME
else
    # Public repository
    sudo -u $ADMIN_USER git clone $GITHUB_REPO_URL $APP_NAME
fi

# Navigate to app directory
cd $APP_DIR

# Create Python virtual environment
log "Setting up Python virtual environment..."
sudo -u $ADMIN_USER python3 -m venv venv
sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip

# Install Python dependencies
log "Installing Python dependencies..."
if [ -f "requirements.txt" ]; then
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r requirements.txt
else
    # Install basic Flask dependencies if no requirements.txt
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil
fi

# Test if app can import successfully
log "Testing Flask application..."
cd $APP_DIR
sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('App imports successfully')" || {
    log "ERROR: App failed to import!"
    # Try to install missing dependencies
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install psutil
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
sleep 5
if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then
    log "✅ $SERVICE_NAME service started successfully"
else
    log "❌ $SERVICE_NAME service failed to start"
    log "Service status:"
    supervisorctl status $SERVICE_NAME
    log "Application logs:"
    tail -10 /var/log/$SERVICE_NAME.log || echo "No logs found"
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

# Final status check
log "Performing final status check..."
sleep 10

if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then
    log "✅ Application is running successfully"
else
    log "❌ Application failed to start. Check logs: /var/log/$SERVICE_NAME.log"
fi

if systemctl is-active --quiet nginx; then
    log "✅ Nginx is running successfully"
else
    log "❌ Nginx failed to start. Check logs: journalctl -u nginx"
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