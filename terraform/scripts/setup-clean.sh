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
apt-get install -y python3 python3-pip python3-venv nginx git curl ufw >/dev/null 2>&1

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
nginx -t >/dev/null

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

# Start services
systemctl daemon-reload
systemctl enable $SERVICE_NAME >/dev/null 2>&1
systemctl start $SERVICE_NAME
systemctl enable nginx >/dev/null 2>&1
systemctl restart nginx

# Wait and check status
sleep 10
if systemctl is-active --quiet $SERVICE_NAME && systemctl is-active --quiet nginx; then
    echo "Setup completed successfully"
else
    echo "ERROR: Service startup failed"
    exit 1
fi