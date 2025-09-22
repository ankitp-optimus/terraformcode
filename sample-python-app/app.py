from flask import Flask, render_template, jsonify, request
import os
import datetime
import platform
import psutil
import json

app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-here')

# Application version and deployment info
APP_VERSION = "2.0.0"
DEPLOYMENT_DATE = datetime.datetime.now().isoformat()

def get_deployment_info():
    """Get deployment information from files created during pipeline"""
    info = {
        'version': APP_VERSION,
        'deployment_date': DEPLOYMENT_DATE,
        'build_number': 'unknown',
        'commit_hash': 'unknown',
        'deployment_time': 'unknown'
    }
    
    try:
        # Read version info if available
        if os.path.exists('version.txt'):
            with open('version.txt', 'r') as f:
                info['build_number'] = f.read().strip()
        
        if os.path.exists('commit.txt'):
            with open('commit.txt', 'r') as f:
                info['commit_hash'] = f.read().strip()[:8]  # Short commit hash
                
        if os.path.exists('deployment-info.txt'):
            with open('deployment-info.txt', 'r') as f:
                info['deployment_time'] = f.read().strip()
    except Exception:
        pass
    
    return info

@app.route('/')
def home():
    """Home page with application information"""
    deployment_info = get_deployment_info()
    return render_template('index.html', deployment_info=deployment_info)

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    deployment_info = get_deployment_info()
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'version': deployment_info['version'],
        'build_number': deployment_info['build_number'],
        'deployment_date': deployment_info['deployment_time']
    })

@app.route('/api/info')
def system_info():
    """System information endpoint"""
    try:
        system_info = {
            'hostname': platform.node(),
            'platform': platform.platform(),
            'python_version': platform.python_version(),
            'cpu_count': psutil.cpu_count(),
            'memory_total': round(psutil.virtual_memory().total / (1024**3), 2),  # GB
            'memory_available': round(psutil.virtual_memory().available / (1024**3), 2),  # GB
            'disk_usage': {
                'total': round(psutil.disk_usage('/').total / (1024**3), 2),  # GB
                'free': round(psutil.disk_usage('/').free / (1024**3), 2),   # GB
            },
            'uptime': datetime.datetime.now().isoformat(),
            'timestamp': datetime.datetime.now().isoformat()
        }
        return jsonify(system_info)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/hello')
def hello_api():
    """Simple API endpoint"""
    name = request.args.get('name', 'World')
    deployment_info = get_deployment_info()
    return jsonify({
        'message': f'Hello, {name}!',
        'timestamp': datetime.datetime.now().isoformat(),
        'version': deployment_info['version'],
        'build': deployment_info['build_number']
    })

@app.route('/api/deployment')
def deployment_api():
    """Deployment information API endpoint"""
    return jsonify(get_deployment_info())

@app.route('/api/test')
def test_api():
    """Test endpoint for deployment validation"""
    return jsonify({
        'status': 'success',
        'message': 'Test endpoint is working!',
        'timestamp': datetime.datetime.now().isoformat(),
        'test_data': {
            'environment': os.environ.get('ENVIRONMENT', 'unknown'),
            'hostname': platform.node(),
            'python_version': platform.python_version()
        }
    })

@app.route('/api/echo', methods=['GET', 'POST'])
def echo_api():
    """Echo API for testing different HTTP methods"""
    if request.method == 'POST':
        data = request.get_json() or {}
        return jsonify({
            'method': 'POST',
            'received_data': data,
            'timestamp': datetime.datetime.now().isoformat()
        })
    else:
        return jsonify({
            'method': 'GET',
            'query_params': dict(request.args),
            'timestamp': datetime.datetime.now().isoformat()
        })

@app.route('/about')
def about():
    """About page"""
    deployment_info = get_deployment_info()
    return render_template('about.html', deployment_info=deployment_info)

@app.route('/status')
def status():
    """Status page showing system metrics"""
    try:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        status_data = {
            'cpu_usage': cpu_percent,
            'memory_usage': memory.percent,
            'disk_usage': (disk.used / disk.total) * 100,
            'memory_total': round(memory.total / (1024**3), 2),
            'memory_available': round(memory.available / (1024**3), 2),
            'disk_total': round(disk.total / (1024**3), 2),
            'disk_free': round(disk.free / (1024**3), 2),
            'uptime': datetime.datetime.now().isoformat()
        }
        return render_template('status.html', status=status_data)
    except Exception as e:
        return render_template('error.html', error=str(e))

@app.errorhandler(404)
def not_found(error):
    """Custom 404 page"""
    return render_template('404.html'), 404

@app.errorhandler(500)
def internal_error(error):
    """Custom 500 page"""
    return render_template('error.html', error="Internal Server Error"), 500

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=5000, debug=False)