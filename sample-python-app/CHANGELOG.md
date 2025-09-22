# Changelog

## Version 2.0.0 (2025-09-22)

### 🚀 New Features
- **Deployment Tracking**: Added deployment information display on home and about pages
- **Version Management**: Application now shows version, build number, and commit hash
- **New API Endpoints**:
  - `/api/deployment` - Get deployment information
  - `/api/test` - Test endpoint for deployment validation  
  - `/api/echo` - Echo API supporting GET/POST methods
- **Enhanced UI**: Added API testing section on home page
- **Test Script**: Added automated testing script (`test_app.py`)

### 🔧 Improvements
- **Enhanced Health Check**: Now includes build and deployment information
- **Better Error Handling**: Improved error handling for deployment info retrieval
- **Updated Documentation**: Reflects Azure DevOps pipeline deployment
- **Monitoring**: Better deployment tracking and validation

### 📊 API Endpoints
- `GET /` - Home page with deployment info
- `GET /health` - Health check with version info
- `GET /about` - About page with deployment details
- `GET /status` - System status and metrics
- `GET /api/deployment` - Deployment information
- `GET /api/test` - Test endpoint
- `GET /api/hello?name=<name>` - Hello API
- `GET/POST /api/echo` - Echo API
- `GET /api/info` - System information

### 🧪 Testing
- Added comprehensive test script for deployment validation
- Tests all endpoints and validates responses
- Can be run after deployment: `python test_app.py http://vm-ip`

---

## Version 1.0.0 (Previous)

### Features
- Basic Flask application
- Health check endpoint
- System status monitoring
- GitHub Actions deployment