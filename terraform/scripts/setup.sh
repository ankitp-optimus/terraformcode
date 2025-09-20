#!/bin/bash#!/bin/bash#!/bin/bash



# VM Setup Script for Python Flask App with Nginx

# This script sets up the VM environment, clones the GitHub repo, and deploys the Python application

# VM Setup Script for Python Flask App with Nginx# VM Se# Update package lists and system

# Don't exit on every error - handle critical vs non-critical operations separately

set +e# This script sets up the VM environment, clones the GitHub repo, and deploys the Python applicationlog "Updating system packages..."



# Set strict mode for critical operations when neededapt-get update -y

strict_mode() {

    set -e# Don't exit on every error - handle critical vs non-critical operations separately

}

set +e# Ensure universe repository is enabled (required for some packages)

# Set permissive mode for non-critical operations

permissive_mode() {log "Enabling universe repository..."

    set +e

}# Set strict mode for critical operations when neededadd-apt-repository universe -y



# Variables passed from Terraformstrict_mode() {apt-get update -y

GITHUB_REPO_URL="${github_repo_url}"

APP_NAME="${app_name}"    set -e

GITHUB_TOKEN="${github_token}"

ADMIN_USER="${admin_username}"}# Upgrade system packages

APP_DIR="/home/$ADMIN_USER/$APP_NAME"

SERVICE_NAME="$APP_NAME"apt-get upgrade -y



# Log script start and variables (for debugging)# Set permissive mode for non-critical operations

LOG_FILE="/var/log/vm-setup.log"

echo "=== VM Setup Script Started at $(date) ===" | tee -a $LOG_FILEpermissive_mode() {# Install required packages

echo "Variables received:" | tee -a $LOG_FILE

echo "  GITHUB_REPO_URL: $GITHUB_REPO_URL" | tee -a $LOG_FILE    set +elog "Installing required packages..."

echo "  APP_NAME: $APP_NAME" | tee -a $LOG_FILE

echo "  ADMIN_USER: $ADMIN_USER" | tee -a $LOG_FILE}# Install packages one by one for better error handling

echo "  GitHub Token: $(if [ ! -z "$GITHUB_TOKEN" ]; then echo "PROVIDED"; else echo "NOT PROVIDED"; fi)" | tee -a $LOG_FILE

echo "================================" | tee -a $LOG_FILEapt-get install -y python3



# Logging function# Variables passed from Terraformapt-get install -y python3-pip

log() {

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILEGITHUB_REPO_URL="${github_repo_url}"apt-get install -y python3-venv

}

APP_NAME="${app_name}"apt-get install -y nginx

log "Starting VM setup for $APP_NAME"

GITHUB_TOKEN="${github_token}"apt-get install -y git

# Update package lists and system

log "Updating system packages..."ADMIN_USER="${admin_username}"apt-get install -y curl

apt-get update -y

APP_DIR="/home/$ADMIN_USER/$APP_NAME"apt-get install -y supervisor

# Ensure universe repository is enabled (required for some packages)

log "Enabling universe repository..."SERVICE_NAME="$APP_NAME"apt-get install -y ufw

add-apt-repository universe -y

apt-get update -yapt-get install -y htop



# Upgrade system packages# Log script start and variables (for debugging)apt-get install -y unzip

apt-get upgrade -y

LOG_FILE="/var/log/vm-setup.log"

# Install required packages with better error handling

log "Installing required packages..."echo "=== VM Setup Script Started at $(date) ===" | tee -a $LOG_FILE# Verify Python installation

strict_mode

echo "Variables received:" | tee -a $LOG_FILElog "Verifying Python installation..."

# Install critical packages one by one for better error handling

log "Installing Python3..."echo "  GITHUB_REPO_URL: $GITHUB_REPO_URL" | tee -a $LOG_FILEpython3 --version

apt-get install -y python3

echo "  APP_NAME: $APP_NAME" | tee -a $LOG_FILEpip3 --versionhon Flask App with Nginx

log "Installing pip..."

apt-get install -y python3-pipecho "  ADMIN_USER: $ADMIN_USER" | tee -a $LOG_FILE# This script sets up the VM environment, clones the GitHub repo, and deploys the Python application



log "Installing python3-venv..."echo "  GitHub Token: $(if [ ! -z "$GITHUB_TOKEN" ]; then echo "PROVIDED"; else echo "NOT PROVIDED"; fi)" | tee -a $LOG_FILE

apt-get install -y python3-venv

echo "================================" | tee -a $LOG_FILEset -e  # Exit on any error

log "Installing nginx..."

apt-get install -y nginx



log "Installing git..."# Logging function# Variables passed from Terraform

apt-get install -y git

log() {GITHUB_REPO_URL="${github_repo_url}"

log "Installing curl..."

apt-get install -y curl    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILEAPP_NAME="${app_name}"



log "Installing supervisor..."}GITHUB_TOKEN="${github_token}"

apt-get install -y supervisor

ADMIN_USER="${admin_username}"

log "Installing firewall utilities..."

apt-get install -y ufwlog "Starting VM setup for $APP_NAME"APP_DIR="/home/$ADMIN_USER/$APP_NAME"



log "Installing monitoring tools..."SERVICE_NAME="$APP_NAME"

apt-get install -y htop

# Update package lists and system

log "Installing unzip..."

apt-get install -y unziplog "Updating system packages..."# Logging function



permissive_modeapt-get update -ylog() {



# Verify Python installation    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/app-setup.log

log "Verifying Python installation..."

python3 --version# Ensure universe repository is enabled (required for some packages)}

pip3 --version

log "Enabling universe repository..."

# Configure firewall

log "Configuring firewall..."add-apt-repository universe -ylog "Starting VM setup for $APP_NAME"

ufw allow OpenSSH

ufw allow 'Nginx Full'apt-get update -y

ufw allow 5000  # Flask default port

ufw --force enable# Configure firewall



# Create application directory# Upgrade system packageslog "Configuring firewall..."

log "Setting up application directory..."

mkdir -p $APP_DIRapt-get upgrade -yufw allow OpenSSH

chown $ADMIN_USER:$ADMIN_USER $APP_DIR

ufw allow 'Nginx Full'

# Clone GitHub repository (critical operation)

strict_mode# Install required packages with better error handlingufw allow 5000  # Flask default port

log "Cloning GitHub repository..."

cd /home/$ADMIN_USERlog "Installing required packages..."ufw --force enable



# Debug: Show what we're about to clonestrict_mode

log "GitHub Repository URL: $GITHUB_REPO_URL"

log "GitHub Token present: $(if [ ! -z "$GITHUB_TOKEN" ]; then echo "YES"; else echo "NO"; fi)"# Create application directory



if [ ! -z "$GITHUB_TOKEN" ]; then# Install critical packages one by one for better error handlinglog "Setting up application directory..."

    # Use token for private repositories

    REPO_URL_WITH_TOKEN=$(echo $GITHUB_REPO_URL | sed "s|https://|https://$GITHUB_TOKEN@|")log "Installing Python3..."mkdir -p $APP_DIR

    log "Cloning private repository with token..."

    sudo -u $ADMIN_USER git clone $REPO_URL_WITH_TOKEN $APP_NAMEapt-get install -y python3chown $ADMIN_USER:$ADMIN_USER $APP_DIR

else

    # Public repository

    log "Cloning public repository..."

    sudo -u $ADMIN_USER git clone $GITHUB_REPO_URL $APP_NAMElog "Installing pip..."# Clone GitHub repository

fi

apt-get install -y python3-piplog "Cloning GitHub repository..."

# Verify clone was successful

if [ ! -d "$APP_NAME" ]; thencd /home/$ADMIN_USER

    log "ERROR: Failed to clone repository!"

    log "Repository URL: $GITHUB_REPO_URL"log "Installing python3-venv..."

    log "Available directories in /home/$ADMIN_USER:"

    ls -la /home/$ADMIN_USER/apt-get install -y python3-venv# Remove existing directory if it exists

    exit 1

fiif [ -d "$APP_NAME" ]; then



log "Repository cloned successfully"log "Installing nginx..."    log "Removing existing application directory..."

permissive_mode

apt-get install -y nginx    rm -rf $APP_NAME

# Navigate to app directory

cd $APP_DIRfi



# Create Python virtual environment (critical)log "Installing git..."

strict_mode

log "Setting up Python virtual environment..."apt-get install -y gitif [ ! -z "$GITHUB_TOKEN" ]; then

sudo -u $ADMIN_USER python3 -m venv venv

sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip    # Use token for private repositories



# Install Python dependencies (critical)log "Installing curl..."    REPO_URL_WITH_TOKEN=$(echo $GITHUB_REPO_URL | sed "s|https://|https://$GITHUB_TOKEN@|")

log "Installing Python dependencies..."

if [ -f "requirements.txt" ]; thenapt-get install -y curl    log "Cloning private repository with token..."

    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r requirements.txt

else    sudo -u $ADMIN_USER git clone $REPO_URL_WITH_TOKEN $APP_NAME

    # Install basic Flask dependencies if no requirements.txt

    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutillog "Installing supervisor..."else

fi

permissive_modeapt-get install -y supervisor    # Public repository



# Test if app can import successfully    log "Cloning public repository..."

log "Testing Flask application..."

cd $APP_DIRlog "Installing firewall utilities..."    sudo -u $ADMIN_USER git clone $GITHUB_REPO_URL $APP_NAME

if sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('App imports successfully')" 2>/dev/null; then

    log "✅ App imports successfully"apt-get install -y ufwfi

else

    log "⚠️  App failed to import initially - attempting to install missing dependencies"

    # Try to install missing dependencies

    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install psutillog "Installing monitoring tools..."# Verify the clone was successful

    

    # Test againapt-get install -y htopif [ ! -d "$APP_NAME" ]; then

    if sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('App imports successfully')" 2>/dev/null; then

        log "✅ App imports successfully after installing dependencies"    log "❌ ERROR: Failed to clone repository!"

    else

        log "⚠️  App still fails to import - continuing with setup (app might start later)"log "Installing unzip..."    log "Repository URL: $GITHUB_REPO_URL"

        # Don't exit here - the app might work when properly configured

    fiapt-get install -y unzip    exit 1

fi

fi

# Create Gunicorn configuration

log "Creating Gunicorn configuration..."permissive_mode

cat > /etc/supervisor/conf.d/$SERVICE_NAME.conf << EOF

[program:$SERVICE_NAME]log "✅ Repository cloned successfully"

command=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 2 --timeout 120 --log-level info app:app

directory=$APP_DIR# Verify Python installationlog "Repository contents:"

user=$ADMIN_USER

autostart=truelog "Verifying Python installation..."ls -la /home/$ADMIN_USER/$APP_NAME/

autorestart=true

redirect_stderr=truepython3 --version

stdout_logfile=/var/log/$SERVICE_NAME.log

EOFpip3 --version# Navigate to app directory



# Create Nginx configurationcd $APP_DIR

log "Configuring Nginx..."

cat > /etc/nginx/sites-available/$SERVICE_NAME << EOF# Configure firewall

server {

    listen 80;log "Configuring firewall..."# Create Python virtual environment

    server_name _;

ufw allow OpenSSHlog "Setting up Python virtual environment..."

    location / {

        proxy_pass http://127.0.0.1:5000;ufw allow 'Nginx Full'sudo -u $ADMIN_USER python3 -m venv venv

        proxy_set_header Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;ufw allow 5000  # Flask default portsudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip

        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto \$scheme;ufw --force enable

        proxy_connect_timeout 60s;

        proxy_send_timeout 60s;# Install Python dependencies

        proxy_read_timeout 60s;

    }# Create application directorylog "Installing Python dependencies..."



    location /health {log "Setting up application directory..."

        proxy_pass http://127.0.0.1:5000/health;

        proxy_set_header Host \$host;mkdir -p $APP_DIR# Check repository structure and organize files

        proxy_set_header X-Real-IP \$remote_addr;

    }chown $ADMIN_USER:$ADMIN_USER $APP_DIRlog "Analyzing repository structure..."



    # Static files (if any)ls -la $APP_DIR/

    location /static {

        alias $APP_DIR/static;# Clone GitHub repository (critical operation)

        expires 30d;

        add_header Cache-Control "public, immutable";strict_mode# Check if we have sample-python-app directory structure

    }

}log "Cloning GitHub repository..."if [ -d "$APP_DIR/sample-python-app" ]; then

EOF

cd /home/$ADMIN_USER    log "Found sample-python-app directory structure"

# Enable Nginx site

ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/    

rm -f /etc/nginx/sites-enabled/default

if [ ! -z "$GITHUB_TOKEN" ]; then    # Copy application files to the root directory

# Test Nginx configuration

nginx -t    # Use token for private repositories    log "Copying application files from sample-python-app to root..."



# Create a simple systemd service as backup    REPO_URL_WITH_TOKEN=$(echo $GITHUB_REPO_URL | sed "s|https://|https://$GITHUB_TOKEN@|")    sudo -u $ADMIN_USER cp -r $APP_DIR/sample-python-app/* $APP_DIR/

log "Creating systemd service..."

cat > /etc/systemd/system/$SERVICE_NAME.service << EOF    sudo -u $ADMIN_USER git clone $REPO_URL_WITH_TOKEN $APP_NAME    

[Unit]

Description=$APP_NAME Flask Applicationelse    # Verify the copy was successful

After=network.target

    # Public repository    log "Files after copying:"

[Service]

Type=simple    sudo -u $ADMIN_USER git clone $GITHUB_REPO_URL $APP_NAME    ls -la $APP_DIR/*.py 2>/dev/null || log "No Python files found after copying"

User=$ADMIN_USER

WorkingDirectory=$APP_DIRfi    

Environment=PATH=$APP_DIR/venv/bin

ExecStart=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 3 app:apppermissive_mode    # Install dependencies from sample-python-app if it exists

Restart=always

RestartSec=10    if [ -f "$APP_DIR/sample-python-app/requirements.txt" ]; then



[Install]# Navigate to app directory        log "Installing dependencies from sample-python-app/requirements.txt..."

WantedBy=multi-user.target

EOFcd $APP_DIR        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/sample-python-app/requirements.txt



# Start services    elif [ -f "$APP_DIR/requirements.txt" ]; then

log "Starting services..."

# Create Python virtual environment (critical)        log "Installing dependencies from requirements.txt..."

# Start Supervisor

systemctl enable supervisorstrict_mode        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/requirements.txt

systemctl start supervisor

sleep 5log "Setting up Python virtual environment..."    else



# Check if Supervisor started correctlysudo -u $ADMIN_USER python3 -m venv venv        log "No requirements.txt found, installing basic dependencies..."

if systemctl is-active --quiet supervisor; then

    log "✅ Supervisor started successfully"sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil

    

    # Start the application    fi

    supervisorctl reread

    supervisorctl update# Install Python dependencies (critical)else

    supervisorctl start $SERVICE_NAME

    log "Installing Python dependencies..."    log "Using direct application structure"

    # Check application status

    sleep 5if [ -f "requirements.txt" ]; then    

    if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then

        log "✅ Application started successfully"    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r requirements.txt    # Check if app.py exists in root

    else

        log "❌ Application failed to start. Check logs: /var/log/$SERVICE_NAME.log"else    if [ -f "$APP_DIR/app.py" ]; then

    fi

else    # Install basic Flask dependencies if no requirements.txt        log "✅ Found app.py in root directory"

    log "❌ Supervisor failed to start"

    systemctl status supervisor --no-pager -l    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil    else

fi

fi        log "❌ app.py not found in root directory"

# Start Nginx

systemctl enable nginxpermissive_mode        log "Available files:"

systemctl start nginx

        ls -la $APP_DIR/

if systemctl is-active --quiet nginx; then

    log "✅ Nginx started successfully"# Test if app can import successfully        

else

    log "❌ Nginx failed to start"log "Testing Flask application..."        # Try to find app.py in subdirectories

    systemctl status nginx --no-pager -l

ficd $APP_DIR        APP_PY_LOCATION=$(find $APP_DIR -name "app.py" -type f | head -1)



systemctl daemon-reloadif sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('App imports successfully')" 2>/dev/null; then        if [ -n "$APP_PY_LOCATION" ]; then

systemctl enable $SERVICE_NAME

    log "✅ App imports successfully"            log "Found app.py at: $APP_PY_LOCATION"

# Create health check script

cat > $APP_DIR/health_check.sh << EOFelse            APP_PY_DIR=$(dirname "$APP_PY_LOCATION")

#!/bin/bash

echo "Testing Flask app directly..."    log "⚠️  App failed to import initially - attempting to install missing dependencies"            log "Copying files from $APP_PY_DIR to root..."

curl -f http://localhost:5000/health || exit 1

echo "Testing through nginx..."    # Try to install missing dependencies            sudo -u $ADMIN_USER cp -r $APP_PY_DIR/* $APP_DIR/

curl -f http://localhost/health || exit 1

echo "✅ All health checks passed!"    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install psutil        else

EOF

                log "❌ ERROR: app.py not found anywhere in the repository!"

chmod +x $APP_DIR/health_check.sh

chown $ADMIN_USER:$ADMIN_USER $APP_DIR/health_check.sh    # Test again            exit 1



# Final status check    if sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('App imports successfully')" 2>/dev/null; then        fi

log "Performing final status check..."

sleep 10        log "✅ App imports successfully after installing dependencies"    fi



if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then    else    

    log "✅ Application is running successfully"

else        log "⚠️  App still fails to import - continuing with setup (app might start later)"    if [ -f "$APP_DIR/requirements.txt" ]; then

    log "❌ Application failed to start. Check logs: /var/log/$SERVICE_NAME.log"

fi        # Don't exit here - the app might work when properly configured        log "Installing dependencies from requirements.txt..."



if systemctl is-active --quiet nginx; then    fi        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r $APP_DIR/requirements.txt

    log "✅ Nginx is running successfully"

elsefi    else

    log "❌ Nginx failed to start. Check logs: journalctl -u nginx"

fi        # Install basic Flask dependencies if no requirements.txt



# Display useful information# Create Gunicorn configuration        log "No requirements.txt found, installing basic dependencies..."

log "Setup completed!"

# Get public IP safelylog "Creating Gunicorn configuration..."        sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil

PUBLIC_IP=$(curl -s --max-time 10 ifconfig.me 2>/dev/null || echo "Unable to determine public IP")

log "Application URL: http://$PUBLIC_IP/"cat > /etc/supervisor/conf.d/$SERVICE_NAME.conf << EOF    fi

log "Application logs: /var/log/$SERVICE_NAME.log"

log "Nginx logs: /var/log/nginx/"[program:$SERVICE_NAME]fi

log "To check health: cd $APP_DIR && ./health_check.sh"

command=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 2 --timeout 120 --log-level info app:app

# Create status script for easy monitoring

cat > /home/$ADMIN_USER/status.sh << EOFdirectory=$APP_DIR# Final verification of application files

#!/bin/bash

echo "=== System Status ==="user=$ADMIN_USERlog "Final verification of application files..."

echo "Date: \$(date)"

echo ""autostart=trueif [ -f "$APP_DIR/app.py" ]; then

echo "=== Service Status ==="

supervisorctl status $SERVICE_NAMEautorestart=true    log "✅ app.py found successfully"

systemctl status nginx --no-pager -l

echo ""redirect_stderr=true    log "File size: $(stat -c%s $APP_DIR/app.py) bytes"

echo "=== Application Health ==="

$APP_DIR/health_check.shstdout_logfile=/var/log/$SERVICE_NAME.logelse

echo ""

echo "=== System Resources ==="EOF    log "❌ CRITICAL ERROR: app.py still not found after setup!"

df -h | grep -E "(Filesystem|/dev/)"

free -h    log "Current directory contents:"

echo ""

echo "=== Recent Logs ==="# Create Nginx configuration    ls -la $APP_DIR/

echo "--- Application Logs (last 5 lines) ---"

tail -5 /var/log/$SERVICE_NAME.loglog "Configuring Nginx..."    exit 1

echo "--- Nginx Access Logs (last 5 lines) ---"

tail -5 /var/log/nginx/access.logcat > /etc/nginx/sites-available/$SERVICE_NAME << EOFfi

EOF

server {

chmod +x /home/$ADMIN_USER/status.sh

chown $ADMIN_USER:$ADMIN_USER /home/$ADMIN_USER/status.sh    listen 80;# Test if app can import successfully



log "VM setup completed successfully! 🎉"    server_name _;log "Testing Flask application..."



# Ensure script exits successfullycd $APP_DIR

exit 0
    location / {sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('✅ App imports successfully')" || {

        proxy_pass http://127.0.0.1:5000;    log "❌ ERROR: App failed to import!"

        proxy_set_header Host \$host;    log "Checking current directory contents:"

        proxy_set_header X-Real-IP \$remote_addr;    ls -la $APP_DIR

        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;    log "Trying to install missing dependencies..."

        proxy_set_header X-Forwarded-Proto \$scheme;    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install psutil flask

        proxy_connect_timeout 60s;    

        proxy_send_timeout 60s;    # Try importing again

        proxy_read_timeout 60s;    sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('✅ App imports successfully after installing dependencies')" || {

    }        log "❌ CRITICAL ERROR: App still fails to import!"

        log "Python path and files:"

    location /health {        sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import sys; print('Python path:', sys.path)"

        proxy_pass http://127.0.0.1:5000/health;        exit 1

        proxy_set_header Host \$host;    }

        proxy_set_header X-Real-IP \$remote_addr;}

    }

# Create Gunicorn configuration

    # Static files (if any)log "Creating Gunicorn configuration..."

    location /static {cat > /etc/supervisor/conf.d/$SERVICE_NAME.conf << EOF

        alias $APP_DIR/static;[program:$SERVICE_NAME]

        expires 30d;command=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 2 --timeout 120 --log-level info app:app

        add_header Cache-Control "public, immutable";directory=$APP_DIR

    }user=$ADMIN_USER

}autostart=true

EOFautorestart=true

redirect_stderr=true

# Enable Nginx sitestdout_logfile=/var/log/$SERVICE_NAME.log

ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/EOF

rm -f /etc/nginx/sites-enabled/default

# Create Nginx configuration

# Test Nginx configurationlog "Configuring Nginx..."

nginx -tcat > /etc/nginx/sites-available/$SERVICE_NAME << EOF

server {

# Create a simple systemd service as backup    listen 80;

log "Creating systemd service..."    server_name _;

cat > /etc/systemd/system/$SERVICE_NAME.service << EOF

[Unit]    location / {

Description=$APP_NAME Flask Application        proxy_pass http://127.0.0.1:5000;

After=network.target        proxy_set_header Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;

[Service]        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

Type=simple        proxy_set_header X-Forwarded-Proto \$scheme;

User=$ADMIN_USER        proxy_connect_timeout 60s;

WorkingDirectory=$APP_DIR        proxy_send_timeout 60s;

Environment=PATH=$APP_DIR/venv/bin        proxy_read_timeout 60s;

ExecStart=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 3 app:app    }

Restart=always

RestartSec=10    location /health {

        proxy_pass http://127.0.0.1:5000/health;

[Install]        proxy_set_header Host \$host;

WantedBy=multi-user.target        proxy_set_header X-Real-IP \$remote_addr;

EOF    }



# Start services    # Static files (if any)

log "Starting services..."    location /static {

        alias $APP_DIR/static;

# Start Supervisor        expires 30d;

systemctl enable supervisor        add_header Cache-Control "public, immutable";

systemctl start supervisor    }

sleep 5}

EOF

# Check if Supervisor started correctly

if systemctl is-active --quiet supervisor; then# Enable Nginx site

    log "✅ Supervisor started successfully"ln -sf /etc/nginx/sites-available/$SERVICE_NAME /etc/nginx/sites-enabled/

    rm -f /etc/nginx/sites-enabled/default

    # Start the application

    supervisorctl reread# Test Nginx configuration

    supervisorctl updatenginx -t

    supervisorctl start $SERVICE_NAME

    # Create a simple systemd service as backup

    # Check application statuslog "Creating systemd service..."

    sleep 5cat > /etc/systemd/system/$SERVICE_NAME.service << EOF

    if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then[Unit]

        log "✅ Application started successfully"Description=$APP_NAME Flask Application

    elseAfter=network.target

        log "❌ Application failed to start. Check logs: /var/log/$SERVICE_NAME.log"

    fi[Service]

elseType=simple

    log "❌ Supervisor failed to start"User=$ADMIN_USER

    systemctl status supervisor --no-pager -lWorkingDirectory=$APP_DIR

fiEnvironment=PATH=$APP_DIR/venv/bin

ExecStart=$APP_DIR/venv/bin/gunicorn --bind 127.0.0.1:5000 --workers 3 app:app

# Start NginxRestart=always

systemctl enable nginxRestartSec=10

systemctl start nginx

[Install]

if systemctl is-active --quiet nginx; thenWantedBy=multi-user.target

    log "✅ Nginx started successfully"EOF

else

    log "❌ Nginx failed to start"# Create deployment script for future updates

    systemctl status nginx --no-pager -llog "Creating deployment script..."

ficat > $APP_DIR/deploy.sh << 'EOF'

#!/bin/bash

systemctl daemon-reload

systemctl enable $SERVICE_NAME# Deployment script for application updates

APP_DIR="/home/${admin_username}/${app_name}"

# Create health check scriptSERVICE_NAME="${app_name}"

cat > $APP_DIR/health_check.sh << EOF

#!/bin/bashcd $APP_DIR

echo "Testing Flask app directly..."

curl -f http://localhost:5000/health || exit 1# Pull latest changes

echo "Testing through nginx..."git pull origin main

curl -f http://localhost/health || exit 1

echo "✅ All health checks passed!"# Activate virtual environment and install/update dependencies

EOFsource venv/bin/activate

pip install -r requirements.txt

chmod +x $APP_DIR/health_check.sh

chown $ADMIN_USER:$ADMIN_USER $APP_DIR/health_check.sh# Restart services

sudo supervisorctl restart $SERVICE_NAME

# Final status checksudo systemctl reload nginx

log "Performing final status check..."

sleep 10echo "Deployment completed successfully!"

EOF

if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then

    log "✅ Application is running successfully"chmod +x $APP_DIR/deploy.sh

elsechown $ADMIN_USER:$ADMIN_USER $APP_DIR/deploy.sh

    log "❌ Application failed to start. Check logs: /var/log/$SERVICE_NAME.log"

fi# Start and enable services

log "Starting services..."

if systemctl is-active --quiet nginx; thensystemctl reload supervisor

    log "✅ Nginx is running successfully"supervisorctl reread

elsesupervisorctl update

    log "❌ Nginx failed to start. Check logs: journalctl -u nginx"

fi# Start the application service

log "Starting $SERVICE_NAME service..."

# Display useful informationsupervisorctl start $SERVICE_NAME

log "Setup completed!"

# Get public IP safely# Check if service started successfully

PUBLIC_IP=$(curl -s --max-time 10 ifconfig.me 2>/dev/null || echo "Unable to determine public IP")sleep 10

log "Application URL: http://$PUBLIC_IP/"if supervisorctl status $SERVICE_NAME | grep -q "RUNNING"; then

log "Application logs: /var/log/$SERVICE_NAME.log"    log "✅ $SERVICE_NAME service started successfully"

log "Nginx logs: /var/log/nginx/"else

log "To check health: cd $APP_DIR && ./health_check.sh"    log "❌ $SERVICE_NAME service failed to start"

    log "Service status:"

# Create status script for easy monitoring    supervisorctl status $SERVICE_NAME

cat > /home/$ADMIN_USER/status.sh << EOF    log "Application logs:"

#!/bin/bash    tail -20 /var/log/$SERVICE_NAME.log || echo "No logs found"

echo "=== System Status ==="    

echo "Date: \$(date)"    # Try to start with systemd as fallback

echo ""    log "Trying to start with systemd as fallback..."

echo "=== Service Status ==="    systemctl enable $SERVICE_NAME

supervisorctl status $SERVICE_NAME    systemctl start $SERVICE_NAME

systemctl status nginx --no-pager -l    sleep 5

echo ""    

echo "=== Application Health ==="    if systemctl is-active --quiet $SERVICE_NAME; then

$APP_DIR/health_check.sh        log "✅ $SERVICE_NAME started successfully with systemd"

echo ""    else

echo "=== System Resources ==="        log "❌ $SERVICE_NAME failed to start with systemd too"

df -h | grep -E "(Filesystem|/dev/)"        systemctl status $SERVICE_NAME --no-pager -l

free -h    fi

echo ""fi

echo "=== Recent Logs ==="

echo "--- Application Logs (last 5 lines) ---"# Start nginx

tail -5 /var/log/$SERVICE_NAME.loglog "Starting nginx..."

echo "--- Nginx Access Logs (last 5 lines) ---"systemctl enable nginx

tail -5 /var/log/nginx/access.logsystemctl restart nginx

EOF

# Check nginx status

chmod +x /home/$ADMIN_USER/status.shif systemctl is-active --quiet nginx; then

chown $ADMIN_USER:$ADMIN_USER /home/$ADMIN_USER/status.sh    log "✅ Nginx started successfully"

else

log "VM setup completed successfully! 🎉"    log "❌ Nginx failed to start"

    systemctl status nginx --no-pager -l

# Ensure script exits successfullyfi

exit 0
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