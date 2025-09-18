#!/bin/bash

# Diagnostic Script for 502 Bad Gateway Issue
# Run this script on your VM to diagnose why Flask app isn't working

echo "=== FLASK APP DIAGNOSTICS ==="
echo "Time: $(date)"
echo

# Check if required directories exist
echo "1. CHECKING DIRECTORIES:"
ls -la /home/azureuser/
echo

if [ -d "/home/azureuser/python-flask-app" ]; then
    echo "✅ App directory exists"
    cd /home/azureuser/python-flask-app
    echo "App directory contents:"
    ls -la
    echo
else
    echo "❌ App directory missing"
    exit 1
fi

# Check if virtual environment exists
echo "2. CHECKING VIRTUAL ENVIRONMENT:"
if [ -d "venv" ]; then
    echo "✅ Virtual environment exists"
    echo "Python version:"
    ./venv/bin/python --version
    echo "Installed packages:"
    ./venv/bin/pip list
else
    echo "❌ Virtual environment missing"
fi
echo

# Check if app.py exists and is valid
echo "3. CHECKING FLASK APPLICATION:"
if [ -f "app.py" ]; then
    echo "✅ app.py exists"
    echo "Testing Python syntax:"
    ./venv/bin/python -m py_compile app.py && echo "✅ Syntax OK" || echo "❌ Syntax Error"
else
    echo "❌ app.py missing"
fi
echo

# Check if requirements are installed
echo "4. CHECKING DEPENDENCIES:"
if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt exists"
    cat requirements.txt
    echo
    echo "Checking if all packages are installed:"
    ./venv/bin/pip check
else
    echo "❌ requirements.txt missing"
fi
echo

# Check services status
echo "5. CHECKING SERVICES:"
echo "Supervisor status:"
sudo supervisorctl status

echo
echo "Nginx status:"
sudo systemctl status nginx --no-pager -l

echo
echo "Systemd service status:"
sudo systemctl status python-flask-app --no-pager -l
echo

# Check logs
echo "6. CHECKING LOGS:"
echo "Application logs:"
if [ -f "/var/log/python-flask-app.log" ]; then
    echo "Last 20 lines of application log:"
    tail -20 /var/log/python-flask-app.log
else
    echo "❌ Application log not found"
fi

echo
echo "Nginx error logs:"
if [ -f "/var/log/nginx/error.log" ]; then
    echo "Last 10 lines of nginx error log:"
    tail -10 /var/log/nginx/error.log
else
    echo "❌ Nginx error log not found"
fi

echo
echo "Setup log:"
if [ -f "/var/log/app-setup.log" ]; then
    echo "Last 20 lines of setup log:"
    tail -20 /var/log/app-setup.log
else
    echo "❌ Setup log not found"
fi

# Test application manually
echo
echo "7. TESTING APPLICATION MANUALLY:"
echo "Testing if Flask app can start:"
cd /home/azureuser/python-flask-app
timeout 10s ./venv/bin/python app.py &
APP_PID=$!
sleep 3

# Test if app responds
echo "Testing if app responds on port 5000:"
curl -s -f http://localhost:5000/ > /dev/null && echo "✅ App responds on port 5000" || echo "❌ App not responding on port 5000"

# Kill test app
kill $APP_PID 2>/dev/null || true

echo
echo "8. NETWORK CHECKS:"
echo "Checking if port 5000 is listening:"
sudo netstat -tlnp | grep :5000

echo
echo "Checking nginx configuration:"
sudo nginx -t

echo
echo "=== DIAGNOSTIC COMPLETE ==="
echo "If you see errors above, those need to be fixed."
echo "Common fixes:"
echo "1. Restart supervisor: sudo supervisorctl restart python-flask-app"
echo "2. Restart nginx: sudo systemctl restart nginx"
echo "3. Check app directory permissions: sudo chown -R azureuser:azureuser /home/azureuser/python-flask-app"
echo "4. Manually test app: cd /home/azureuser/python-flask-app && ./venv/bin/python app.py"