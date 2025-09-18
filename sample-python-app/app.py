from flask import Flask, render_template, jsonify, request
import os
import datetime
import platform
import psutil

app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'your-secret-key-here')

@app.route('/')
def home():
    """Home page with application information"""
    return render_template('index.html')

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'version': '1.0.0'
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
    return jsonify({
        'message': f'Hello, {name}!',
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/about')
def about():
    """About page"""
    return render_template('about.html')

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