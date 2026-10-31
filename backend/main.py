"""
Main FastAPI Application Entrypoint
Subscription Management System (Make-a-ton x Odoo)
"""

import sys
import os

# Ensure bundled site-packages from venv are discoverable across all Python environments
_site_packages = os.path.join(os.path.dirname(__file__), "venv", "Lib", "site-packages")
if os.path.exists(_site_packages) and _site_packages not in sys.path:
    sys.path.insert(0, _site_packages)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import init_db
from routes.taxes import router as taxes_router
from routes.discounts import router as discounts_router
from routes.invoices import router as invoices_router

# Initialize Database Tables & Default Seed Data
init_db()

app = FastAPI(
    title="Subscription Management System API",
    description="Backend API for Subscription, Invoicing, Tax, and Discount Management (Member 3 Module)",
    version="1.0.0"
)

# Enable CORS for Flutter Web / Desktop / Mobile clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# Member 3: Invoicing, Tax & Discount Routers
# ==========================================
app.include_router(invoices_router)
app.include_router(taxes_router)
app.include_router(discounts_router)

# ==========================================
# Future Teammate Router Mount Points
# ==========================================
# Member 1: app.include_router(customer_product_router)
# Member 2: app.include_router(subscription_router)
# Member 4: app.include_router(payment_reports_router)

@app.get("/")
def root():
    return {
        "project": "Subscription Management System",
        "module": "Member 3: Invoices, Taxes & Discounts",
        "status": "online",
        "docs_url": "/docs"
    }

@app.get("/api/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
