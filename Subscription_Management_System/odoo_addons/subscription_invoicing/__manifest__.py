# -*- coding: utf-8 -*-
{
    'name': 'Subscription Invoicing, Tax & Discount Management',
    'version': '19.0.1.0.0',
    'category': 'Accounting/Invoicing',
    'summary': 'Member 3 Module: Subscription Invoices, GST Breakdown, and Promotional Discounts',
    'description': """
Subscription Management System - Member 3
=========================================
- Generates invoices from subscriptions (Member 2).
- Unique sequential numbering with duplicate billing cycle prevention.
- GST Engine: Intra-State (CGST + SGST) vs Inter-State (IGST).
- Promotional Discounts: Fixed/Percent, thresholds, validity, and usage limits.
- REST JSON API controllers for Flutter mobile and Member 4 payment reconciliation.
    """,
    'author': 'Member 3 (BrightLoop)',
    'depends': ['base', 'account'],
    'data': [
        'views/invoice_views.xml',
        'views/discount_views.xml',
        'views/tax_views.xml',
    ],
    'installable': True,
    'application': True,
    'license': 'LGPL-3',
}
