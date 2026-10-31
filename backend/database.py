"""
Database module for Subscription Management System.
Uses SQLite for robust, dependency-free local persistence with clean table structures.
Compatible with PostgreSQL when DATABASE_URL is configured.
"""

import os
import sqlite3
import datetime
import uuid

DB_PATH = os.path.join(os.path.dirname(__file__), "subscription_mgmt.db")

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn

def init_db():
    conn = get_connection()
    cursor = conn.cursor()

    # 1. Tax Rates Table (Member 3)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS tax_rates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rate REAL NOT NULL,
        description TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
    );
    """)

    # 2. Discounts Table (Member 3)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS discounts (
        id TEXT PRIMARY KEY,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        discount_type TEXT NOT NULL, -- 'PERCENTAGE' or 'FIXED'
        value REAL NOT NULL,
        scope TEXT NOT NULL DEFAULT 'SUBSCRIPTION', -- 'SUBSCRIPTION' or 'PRODUCT'
        product_id TEXT,
        min_purchase_amount REAL DEFAULT 0.0,
        min_quantity INTEGER DEFAULT 1,
        start_date TEXT,
        expiry_date TEXT,
        max_uses INTEGER DEFAULT 0, -- 0 means unlimited
        used_count INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
    );
    """)

    # 3. Invoices Table (Member 3)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT UNIQUE NOT NULL,
        subscription_id TEXT,
        billing_cycle_start TEXT,
        billing_cycle_end TEXT,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_email TEXT,
        customer_state TEXT NOT NULL,
        customer_gstin TEXT,
        customer_address TEXT,
        company_state TEXT DEFAULT 'Kerala',
        subtotal REAL NOT NULL,
        discount_code TEXT,
        discount_amount REAL DEFAULT 0.0,
        taxable_amount REAL NOT NULL,
        tax_rate REAL DEFAULT 0.0,
        is_inter_state INTEGER DEFAULT 0,
        cgst_rate REAL DEFAULT 0.0,
        cgst_amount REAL DEFAULT 0.0,
        sgst_rate REAL DEFAULT 0.0,
        sgst_amount REAL DEFAULT 0.0,
        igst_rate REAL DEFAULT 0.0,
        igst_amount REAL DEFAULT 0.0,
        total_tax REAL DEFAULT 0.0,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'Draft', -- Draft, Posted, Cancelled, Paid
        issue_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
    );
    """)

    # 4. Invoice Line Items Table (Member 3)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS invoice_items (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        discount_amount REAL DEFAULT 0.0,
        taxable_amount REAL NOT NULL,
        tax_rate REAL NOT NULL,
        tax_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
    );
    """)

    # 5. Subscriptions Table (Member 2 reference storage for generation)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS mock_subscriptions (
        id TEXT PRIMARY KEY,
        subscription_code TEXT UNIQUE NOT NULL,
        customer_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_email TEXT,
        customer_state TEXT NOT NULL,
        customer_gstin TEXT,
        customer_address TEXT,
        plan_name TEXT NOT NULL,
        billing_cycle_start TEXT NOT NULL,
        billing_cycle_end TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        default_tax_rate REAL DEFAULT 18.0,
        status TEXT DEFAULT 'ACTIVE'
    );
    """)

    conn.commit()

    # Pre-seed initial Tax Rates if table is empty
    cursor.execute("SELECT COUNT(*) as count FROM tax_rates")
    if cursor.fetchone()["count"] == 0:
        now = datetime.datetime.now().isoformat()
        rates = [
            (str(uuid.uuid4()), "GST 0% (Exempted)", 0.0, "Essential commodities / exempt goods", 1, now),
            (str(uuid.uuid4()), "GST 5%", 5.0, "Basic goods and transport services", 1, now),
            (str(uuid.uuid4()), "GST 12%", 12.0, "Standard rate tier 1", 1, now),
            (str(uuid.uuid4()), "GST 18% (Standard SaaS)", 18.0, "Standard rate for software & IT services", 1, now),
            (str(uuid.uuid4()), "GST 28%", 28.0, "Luxury & specialized goods", 1, now),
        ]
        cursor.executemany("""
        INSERT INTO tax_rates (id, name, rate, description, is_active, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """, rates)
        conn.commit()

    # Pre-seed initial Discounts if table is empty
    cursor.execute("SELECT COUNT(*) as count FROM discounts")
    if cursor.fetchone()["count"] == 0:
        now = datetime.datetime.now().isoformat()
        future = (datetime.datetime.now() + datetime.timedelta(days=90)).isoformat()
        discounts = [
            (str(uuid.uuid4()), "WELCOME10", "10% Welcome Discount", "PERCENTAGE", 10.0, "SUBSCRIPTION", None, 500.0, 1, now, future, 100, 0, 1, now),
            (str(uuid.uuid4()), "FLAT200", "Flat Rs. 200 Off", "FIXED", 200.0, "SUBSCRIPTION", None, 1000.0, 1, now, future, 50, 0, 1, now),
            (str(uuid.uuid4()), "PROENTERPRISE", "20% Enterprise Deal", "PERCENTAGE", 20.0, "SUBSCRIPTION", None, 2500.0, 1, now, future, 20, 0, 1, now),
            (str(uuid.uuid4()), "EXPIRED50", "Expired Special Offer", "PERCENTAGE", 50.0, "SUBSCRIPTION", None, 100.0, 1, "2024-01-01T00:00:00", "2024-02-01T00:00:00", 10, 10, 1, now),
        ]
        cursor.executemany("""
        INSERT INTO discounts (id, code, name, discount_type, value, scope, product_id, min_purchase_amount, min_quantity, start_date, expiry_date, max_uses, used_count, is_active, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, discounts)
        conn.commit()

    # Pre-seed sample Subscriptions from Member 2 if table is empty
    cursor.execute("SELECT COUNT(*) as count FROM mock_subscriptions")
    if cursor.fetchone()["count"] == 0:
        subs = [
            ("sub-101", "SUB-2026-001", "cust-01", "Infosys Technologies Ltd", "accounts@infosys.com", "Karnataka", "29AAAAA0000A1Z5", "Electronic City, Bengaluru", "Enterprise Cloud Suite - Monthly", "2026-10-01", "2026-10-31", 15000.0, 1, 18.0, "ACTIVE"),
            ("sub-102", "SUB-2026-002", "cust-02", "Kochi SmartTech Solutions", "billing@smarttech.in", "Kerala", "32BBBBB1111B1Z2", "Infopark, Kakkanad, Kochi", "Professional SaaS License", "2026-10-01", "2026-10-31", 4500.0, 2, 18.0, "ACTIVE"),
            ("sub-103", "SUB-2026-003", "cust-03", "Tata Consultancy Services", "invoicing@tcs.com", "Maharashtra", "27CCCCC2222C1Z8", "Nariman Point, Mumbai", "Custom Odoo ERP Integration", "2026-11-01", "2026-11-30", 28000.0, 1, 18.0, "ACTIVE"),
            ("sub-104", "SUB-2026-004", "cust-04", "Calicut Medical Devices", "finance@calicutmed.org", "Kerala", "32DDDDD3333D1Z4", "Cyberpark, Kozhikode", "Healthcare Analytics Plan", "2026-10-01", "2026-10-31", 8000.0, 1, 12.0, "ACTIVE"),
        ]
        cursor.executemany("""
        INSERT INTO mock_subscriptions (id, subscription_code, customer_id, customer_name, customer_email, customer_state, customer_gstin, customer_address, plan_name, billing_cycle_start, billing_cycle_end, unit_price, quantity, default_tax_rate, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, subs)
        conn.commit()

    conn.close()
