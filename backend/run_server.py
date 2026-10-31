"""
Standalone Backend Server Launcher for Member 3 Module.
Automatically handles package path resolution and starts the FastAPI server.
"""

import sys
import os

# Add local site-packages so uvicorn, fastapi, pydantic are found immediately
site_packages = os.path.join(os.path.dirname(__file__), "venv", "Lib", "site-packages")
if os.path.exists(site_packages) and site_packages not in sys.path:
    sys.path.insert(0, site_packages)

import uvicorn
from main import app

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    print(f"Starting Subscription Management API server on http://127.0.0.1:{port}")
    print(f"Swagger API Documentation: http://127.0.0.1:{port}/docs")
    uvicorn.run("main:app", host="127.0.0.1", port=port, reload=True)
