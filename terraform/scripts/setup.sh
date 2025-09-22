#!/bin/bash

# VM Setup Script for Python Flask App with Nginx
# Application files are copied by the pipeline via SCP

set -e

# Variables (passed from pipeline)
APP_NAME="${1:-flask-app}"
ADMIN_USER="${2:-azureuser}"
APP_DIR="/home/$ADMIN_USER/$APP_NAME"
SERVICE_NAME="$APP_NAME"

echo "Starting VM setup for $APP_NAME..."

# Update and install packages
echo "Installing system packages..."
apt-get update -y >/dev/null 2>&1
apt-get install -y python3 python3-pip python3-venv nginx ufw >/dev/null 2>&1

# Configure firewall
echo "Configuring firewall..."
ufw allow OpenSSH >/dev/null 2>&1
ufw allow 'Nginx Full' >/dev/null 2>&1
ufw --force enable >/dev/null 2>&1

# Wait for application files to be copied
echo "Waiting for application files..."
TIMEOUT=300  # 5 minutes timeout
ELAPSED=0
while [ ! -d "$APP_DIR" ] || [ ! -f "$APP_DIR/app.py" ]; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "ERROR: Timeout waiting for application files in $APP_DIR"
        exit 1
    fi
    sleep 10
    ELAPSED=$((ELAPSED + 10))
    echo "Waiting for files... ($ELAPSED/$TIMEOUT seconds)"
done

echo "Application files found. Setting up environment..."

# Set proper ownership and setup Python environment
chown -R $ADMIN_USER:$ADMIN_USER $APP_DIR
cd $APP_DIR

# Create Python virtual environment
sudo -u $ADMIN_USER python3 -m venv venv
sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip >/dev/null 2>&1

# Install dependencies
if [ -f "$APP_DIR/requirements.txt" ]; then
    echo "Installing Python dependencies from requirements.txt..."
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/requirements.txt >/dev/null 2>&1
else
    echo "Installing default Python dependencies..."
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil >/dev/null 2>&1
fi

# Test application import
echo "Testing application..."
sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app" || {
    echo "ERROR: Failed to import app.py!"
    exit 1
}

# Create systemd service
echo "Creating systemd service..."
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

# Configure Nginx
echo "Configuring Nginx..."
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

# Start services
echo "Starting services..."
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME
systemctl enable nginx
systemctl restart nginx

# Wait and check status
sleep 10
if systemctl is-active --quiet $SERVICE_NAME && systemctl is-active --quiet nginx; then
    echo "✅ Setup completed successfully!"
    echo "✅ $APP_NAME is running on port 80"
else
    echo "❌ Service startup failed"
    systemctl status $SERVICE_NAME --no-pager || true
    systemctl status nginx --no-pager || true
    exit 1
fi

echo "VM setup completed for $APP_NAME"