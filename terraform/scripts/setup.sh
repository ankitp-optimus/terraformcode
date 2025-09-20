#!/bin/bash
set -e

# Variables (replace these or template with Terraform variables)
GITHUB_REPO_URL="${github_repo_url}"
APP_NAME="${app_name}"
GITHUB_TOKEN="${github_token}"
ADMIN_USER="${admin_username}"

# Derived variables
APP_DIR="/home/$ADMIN_USER/$APP_NAME"
SERVICE_NAME="$APP_NAME"
LOG_FILE="/var/log/vm-setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== VM Setup Started ==="
log "GitHub URL: $GITHUB_REPO_URL"
log "Application Name: $APP_NAME"
log "Admin User: $ADMIN_USER"

# Update and install required packages
log "Updating system packages..."
apt-get update -y
apt-get upgrade -y
apt-get install -y python3 python3-pip python3-venv nginx git curl supervisor ufw htop unzip

# Configure firewall
log "Configuring firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw allow 5000  # Flask default port
ufw --force enable

# Create application directory
log "Setting up application directory..."
mkdir -p "$APP_DIR"
chown "$ADMIN_USER:$ADMIN_USER" "$APP_DIR"

# Clone GitHub repository (handle private repo with token)
log "Cloning GitHub repository..."
cd /home/"$ADMIN_USER"
if [ -n "$GITHUB_TOKEN" ]; then
    REPO_URL_WITH_TOKEN=$(echo "$GITHUB_REPO_URL" | sed "s|https://|https://$GITHUB_TOKEN@|")
    sudo -u "$ADMIN_USER" git clone "$REPO_URL_WITH_TOKEN" "$APP_NAME"
else
    sudo -u "$ADMIN_USER" git clone "$GITHUB_REPO_URL" "$APP_NAME"
fi

# Verify clone success
if [ ! -d "$APP_DIR" ]; then
    log "ERROR: Repository clone failed!"
    exit 1
fi

log "Repository cloned successfully"

# Setup Python virtual environment
log "Setting up Python virtual environment..."
cd "$APP_DIR"
sudo -u "$ADMIN_USER" python3 -m venv venv
sudo -u "$ADMIN_USER" "$APP_DIR/venv/bin/pip" install --upgrade pip

# Install dependencies
if [ -f "requirements.txt" ]; then
    sudo -u "$ADMIN_USER" "$APP_DIR/venv/bin/pip" install -r requirements.txt
else
    sudo -u "$ADMIN_USER" "$APP_DIR/venv/bin/pip" install flask gunicorn psutil
fi

# Create Supervisor config
log "Creating Supervisor configuration..."
cat > /etc/supervisor/conf.d/"$SERVICE_NAME".conf << EOF
[program:$SERVICE_NAME]
command=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 2 app:app
directory=$APP_DIR
user=$ADMIN_USER
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/$SERVICE_NAME.log
EOF

# Create Nginx config
log "Creating Nginx configuration..."
cat > /etc/nginx/sites-available/"$SERVICE_NAME" << EOF
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
}
EOF

ln -sf /etc/nginx/sites-available/"$SERVICE_NAME" /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Enable and start services
log "Starting supervisor and nginx services..."
systemctl enable supervisor
systemctl restart supervisor

systemctl enable nginx
systemctl restart nginx

# Reload Supervisor to apply changes
supervisorctl reread
supervisorctl update
supervisorctl start "$SERVICE_NAME"

log "Setup completed! Application should be running at http://$(curl -s ifconfig.me)/"

exit 0
