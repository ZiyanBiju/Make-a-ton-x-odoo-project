"""
Models Module for Subscription Management System.
Defines Member 3 domain models for Invoices, Taxes, and Discounts.
"""

from dataclasses import dataclass
from typing import Optional, List

@dataclass
class TaxRateModel:
    id: str
    name: str
    rate: float
    description: Optional[str]
    is_active: bool
    created_at: str

@dataclass
class DiscountModel:
    id: str
    code: str
    name: str
    discount_type: str  # 'PERCENTAGE' or 'FIXED'
    value: float
    scope: str  # 'SUBSCRIPTION' or 'PRODUCT'
    product_id: Optional[str]
    min_purchase_amount: float
    min_quantity: int
    start_date: Optional[str]
    expiry_date: Optional[str]
    max_uses: int
    used_count: int
    is_active: bool
    created_at: str

@dataclass
class InvoiceItemModel:
    id: str
    invoice_id: str
    product_id: str
    product_name: str
    quantity: int
    unit_price: float
    discount_amount: float
    taxable_amount: float
    tax_rate: float
    tax_amount: float
    total_amount: float

@dataclass
class InvoiceModel:
    id: str
    invoice_number: str
    subscription_id: Optional[str]
    billing_cycle_start: Optional[str]
    billing_cycle_end: Optional[str]
    customer_id: str
    customer_name: str
    customer_email: Optional[str]
    customer_state: str
    customer_gstin: Optional[str]
    customer_address: Optional[str]
    company_state: str
    subtotal: float
    discount_code: Optional[str]
    discount_amount: float
    taxable_amount: float
    tax_rate: float
    is_inter_state: bool
    cgst_rate: float
    cgst_amount: float
    sgst_rate: float
    sgst_amount: float
    igst_rate: float
    igst_amount: float
    total_tax: float
    total_amount: float
    status: str  # 'Draft', 'Posted', 'Cancelled', 'Paid'
    issue_date: str
    due_date: str
    notes: Optional[str]
    created_at: str
    items: Optional[List[InvoiceItemModel]] = None
