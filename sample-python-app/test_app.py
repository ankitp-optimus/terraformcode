#!/usr/bin/env python3
"""
Simple test script to validate the updated Flask application
Run this after deployment to test the new features
"""

import requests
import json
import sys

def test_endpoint(base_url, endpoint, description):
    """Test a specific endpoint and return the result"""
    url = f"{base_url}{endpoint}"
    try:
        response = requests.get(url, timeout=10)
        print(f"✅ {description}: {response.status_code}")
        if response.status_code == 200:
            try:
                data = response.json()
                print(f"   Data: {json.dumps(data, indent=2)}")
            except:
                print(f"   Content: {response.text[:100]}...")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ {description}: Error - {str(e)}")
        return False

def main():
    if len(sys.argv) != 2:
        print("Usage: python test_app.py <base_url>")
        print("Example: python test_app.py http://20.25.123.45")
        sys.exit(1)
    
    base_url = sys.argv[1].rstrip('/')
    
    print(f"🚀 Testing Flask Application v2.0.0")
    print(f"🌐 Base URL: {base_url}")
    print("=" * 50)
    
    # Test all endpoints
    tests = [
        ("/", "Home Page"),
        ("/health", "Health Check API"),
        ("/about", "About Page"),
        ("/status", "Status Page"),
        ("/api/deployment", "Deployment Info API"),
        ("/api/test", "Test API"),
        ("/api/hello?name=DevOps", "Hello API"),
        ("/api/echo?test=deployment", "Echo API"),
        ("/api/info", "System Info API")
    ]
    
    passed = 0
    total = len(tests)
    
    for endpoint, description in tests:
        if test_endpoint(base_url, endpoint, description):
            passed += 1
        print()
    
    print("=" * 50)
    print(f"📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Deployment successful!")
        sys.exit(0)
    else:
        print("⚠️  Some tests failed. Check the application deployment.")
        sys.exit(1)

if __name__ == "__main__":
    main()