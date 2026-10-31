"""
Pydantic schemas for Member 3: Invoices, Taxes, and Discounts.
"""

from typing import List, Optional
from pydantic import BaseModel, Field

# --- Tax Schemas ---
class TaxRateCreate(BaseModel):
    name: str = Field(..., example="GST 18%")
    rate: float = Field(..., ge=0.0, le=100.0, example=18.0)
    description: Optional[str] = None
    is_active: bool = True

class TaxRateUpdate(BaseModel):
    name: Optional[str] = None
    rate: Optional[float] = Field(None, ge=0.0, le=100.0)
    description: Optional[str] = None
    is_active: Optional[bool] = None

class TaxRateOut(BaseModel):
    id: str
    name: str
    rate: float
    description: Optional[str] = None
    is_active: bool
    created_at: str

class TaxCalculateRequest(BaseModel):
    taxable_amount: float
    tax_rate: float
    customer_state: str
    company_state: str = "Kerala"

class TaxCalculateResponse(BaseModel):
    taxable_amount: float
    tax_rate: float
    is_inter_state: bool
    customer_state: str
    company_state: str
    cgst_rate: float
    cgst_amount: float
    sgst_rate: float
    sgst_amount: float
    igst_rate: float
    igst_amount: float
    total_tax: float
    final_amount: float


# --- Discount Schemas ---
class DiscountCreate(BaseModel):
    code: str = Field(..., example="FESTIVE15")
    name: str = Field(..., example="15% Festive Sale")
    discount_type: str = Field(..., example="PERCENTAGE") # 'PERCENTAGE' or 'FIXED'
    value: float = Field(..., gt=0.0, example=15.0)
    scope: str = Field("SUBSCRIPTION", example="SUBSCRIPTION") # 'SUBSCRIPTION' or 'PRODUCT'
    product_id: Optional[str] = None
    min_purchase_amount: float = Field(0.0, ge=0.0)
    min_quantity: int = Field(1, ge=1)
    start_date: Optional[str] = None
    expiry_date: Optional[str] = None
    max_uses: int = Field(0, ge=0) # 0 = unlimited

class DiscountUpdate(BaseModel):
    name: Optional[str] = None
    value: Optional[float] = None
    min_purchase_amount: Optional[float] = None
    min_quantity: Optional[int] = None
    start_date: Optional[str] = None
    expiry_date: Optional[str] = None
    max_uses: Optional[int] = None
    is_active: Optional[bool] = None

class DiscountOut(BaseModel):
    id: str
    code: str
    name: str
    discount_type: str
    value: float
    scope: str
    product_id: Optional[str] = None
    min_purchase_amount: float
    min_quantity: int
    start_date: Optional[str] = None
    expiry_date: Optional[str] = None
    max_uses: int
    used_count: int
    is_active: bool
    created_at: str
    is_valid_now: bool = True
    status_label: str = "Active"

class DiscountValidateRequest(BaseModel):
    code: str
    subtotal: float
    total_quantity: int = 1
    product_id: Optional[str] = None

class DiscountValidateResponse(BaseModel):
    is_valid: bool
    discount_code: str
    discount_name: Optional[str] = None
    discount_amount: float = 0.0
    discount_type: Optional[str] = None
    discount_value: Optional[float] = None
    message: str


# --- Invoice Schemas ---
class InvoiceItemInput(BaseModel):
    product_id: str
    product_name: str
    quantity: int = Field(..., ge=1)
    unit_price: float = Field(..., ge=0.0)
    tax_rate: float = Field(18.0, ge=0.0)

class InvoiceItemOut(BaseModel):
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

class InvoiceCreateRequest(BaseModel):
    subscription_id: Optional[str] = None
    billing_cycle_start: Optional[str] = None
    billing_cycle_end: Optional[str] = None
    customer_id: str
    customer_name: str
    customer_email: Optional[str] = None
    customer_state: str
    customer_gstin: Optional[str] = None
    customer_address: Optional[str] = None
    company_state: str = "Kerala"
    discount_code: Optional[str] = None
    items: List[InvoiceItemInput]
    issue_date: Optional[str] = None
    due_date: Optional[str] = None
    notes: Optional[str] = None
    auto_post: bool = False

class InvoiceStatusUpdateRequest(BaseModel):
    status: str = Field(..., example="Posted") # Draft, Posted, Cancelled, Paid

class InvoiceOut(BaseModel):
    id: str
    invoice_number: str
    subscription_id: Optional[str] = None
    billing_cycle_start: Optional[str] = None
    billing_cycle_end: Optional[str] = None
    customer_id: str
    customer_name: str
    customer_email: Optional[str] = None
    customer_state: str
    customer_gstin: Optional[str] = None
    customer_address: Optional[str] = None
    company_state: str
    subtotal: float
    discount_code: Optional[str] = None
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
    status: str
    issue_date: str
    due_date: str
    notes: Optional[str] = None
    created_at: str
    items: List[InvoiceItemOut] = []

class InvoiceSummaryResponse(BaseModel):
    total_invoices: int
    draft_count: int
    posted_count: int
    paid_count: int
    cancelled_count: int
    total_invoiced_amount: float
    total_paid_amount: float
    total_outstanding_amount: float
    total_tax_collected: float
    total_cgst: float
    total_sgst: float
    total_igst: float
    total_discounts_given: float

class AvailableSubscriptionOut(BaseModel):
    id: str
    subscription_code: str
    customer_id: str
    customer_name: str
    customer_email: Optional[str] = None
    customer_state: str
    customer_gstin: Optional[str] = None
    customer_address: Optional[str] = None
    plan_name: str
    billing_cycle_start: str
    billing_cycle_end: str
    unit_price: float
    quantity: int
    default_tax_rate: float
    status: str
    has_invoice: bool = False
