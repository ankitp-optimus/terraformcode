#!/bin/bash

# VM Setup Script for Python Flask App with Nginx
# Application files are pre-copied by the pipeline

set -e

# Variables
APP_NAME="${app_name}"
ADMIN_USER="${admin_username}"
APP_DIR="/home/$ADMIN_USER/$APP_NAME"
SERVICE_NAME="$APP_NAME"

# Update and install packages
apt-get update -y >/dev/null 2>&1
apt-get install -y python3 python3-pip python3-venv nginx git curl supervisor ufw htop unzip >/dev/null 2>&1

# Configure firewall
ufw allow OpenSSH >/dev/null 2>&1
ufw allow 'Nginx Full' >/dev/null 2>&1
ufw allow 5000 >/dev/null 2>&1
ufw --force enable >/dev/null 2>&1

# Verify application files exist
if [ ! -d "$APP_DIR" ]; then
    echo "ERROR: Application directory $APP_DIR not found!"
    exit 1
fi

# Set proper ownership and setup Python environment
cd $APP_DIR
chown -R $ADMIN_USER:$ADMIN_USER $APP_DIR
sudo -u $ADMIN_USER python3 -m venv venv >/dev/null 2>&1
sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip >/dev/null 2>&1

# Install dependencies
if [ -f "$APP_DIR/requirements.txt" ]; then
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/requirements.txt >/dev/null 2>&1
else
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil >/dev/null 2>&1
fi

# Test application import
sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app" || {
    echo "ERROR: App failed to import!"
    exit 1
}
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

# Configure Nginx
cat > /etc/nginx/sites-available/$SERVICE_NAME << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t

# Create systemd service
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

[Install]
WantedBy=multi-user.target
EOF
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
# Start services
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME
systemctl enable nginx
systemctl restart nginx

# Wait and check status
sleep 10
if systemctl is-active --quiet $SERVICE_NAME && systemctl is-active --quiet nginx; then
    log "Setup completed successfully"
else
    log "ERROR: Service startup failed"
    systemctl status $SERVICE_NAME --no-pager
    systemctl status nginx --no-pager
    exit 1
fi

log "VM setup completed for $APP_NAME"