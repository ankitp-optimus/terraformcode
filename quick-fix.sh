#!/bin/bash

# Quick Fix Script for 502 Bad Gateway
# Run this on your VM to fix common issues

echo "🔧 FIXING 502 BAD GATEWAY ISSUES..."
echo "Time: $(date)"
echo

# Set variables
APP_DIR="/home/azureuser/python-flask-app"
SERVICE_NAME="python-flask-app"
ADMIN_USER="azureuser"

# Fix 1: Ensure app directory exists and has correct permissions
echo "1. Fixing directory permissions..."
if [ -d "$APP_DIR" ]; then
    sudo chown -R $ADMIN_USER:$ADMIN_USER $APP_DIR
    chmod -R 755 $APP_DIR
    echo "✅ Fixed permissions for $APP_DIR"
else
    echo "❌ App directory $APP_DIR not found!"
    echo "The app may not have been cloned properly."
fi

# Fix 2: Ensure virtual environment exists
echo
echo "2. Checking/fixing virtual environment..."
cd $APP_DIR
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    sudo -u $ADMIN_USER python3 -m venv venv
fi

# Fix 3: Install/reinstall dependencies
echo
echo "3. Installing/updating dependencies..."
sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install --upgrade pip
if [ -f "requirements.txt" ]; then
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install -r requirements.txt
else
    echo "❌ requirements.txt not found, installing basic packages..."
    sudo -u $ADMIN_USER $APP_DIR/venv/bin/pip install flask gunicorn psutil
fi

# Fix 4: Test if app can run
echo
echo "4. Testing Flask application..."
cd $APP_DIR
sudo -u $ADMIN_USER $APP_DIR/venv/bin/python -c "import app; print('✅ App imports successfully')" || echo "❌ App import failed"

# Fix 5: Restart supervisor service
echo
echo "5. Restarting supervisor service..."
sudo supervisorctl stop $SERVICE_NAME
sleep 2
sudo supervisorctl start $SERVICE_NAME
sudo supervisorctl status $SERVICE_NAME

# Fix 6: Check if app is listening on port 5000
echo
echo "6. Checking if app is listening on port 5000..."
sleep 5  # Give app time to start
PORT_CHECK=$(sudo netstat -tlnp | grep :5000)
if [ -n "$PORT_CHECK" ]; then
    echo "✅ App is listening on port 5000"
    echo "$PORT_CHECK"
else
    echo "❌ App is NOT listening on port 5000"
    echo "Checking application logs..."
    if [ -f "/var/log/$SERVICE_NAME.log" ]; then
        echo "Last 10 lines of app log:"
        tail -10 /var/log/$SERVICE_NAME.log
    fi
fi

# Fix 7: Test nginx configuration and restart
echo
echo "7. Testing and restarting nginx..."
sudo nginx -t
if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration is valid"
    sudo systemctl restart nginx
    echo "✅ Nginx restarted"
else
    echo "❌ Nginx configuration has errors"
fi

# Fix 8: Test the application
echo
echo "8. Testing application endpoints..."
sleep 3  # Give services time to fully start

# Test health endpoint
if curl -s -f http://localhost:5000/health > /dev/null; then
    echo "✅ Flask app responds directly on port 5000"
else
    echo "❌ Flask app not responding on port 5000"
fi

# Test through nginx
if curl -s -f http://localhost/health > /dev/null; then
    echo "✅ App responds through nginx on port 80"
else
    echo "❌ App not responding through nginx on port 80"
fi

# Fix 9: Show current status
echo
echo "9. Current service status:"
echo "Supervisor:"
sudo supervisorctl status

echo
echo "Nginx:"
sudo systemctl status nginx --no-pager -l | head -10

echo
echo "🎯 QUICK FIXES COMPLETE!"
echo
echo "If the issue persists, run the diagnostic script:"
echo "curl -s https://raw.githubusercontent.com/your-repo/diagnose.sh | bash"
echo
echo "Or check logs manually:"
echo "sudo tail -f /var/log/$SERVICE_NAME.log"
echo "sudo tail -f /var/log/nginx/error.log"