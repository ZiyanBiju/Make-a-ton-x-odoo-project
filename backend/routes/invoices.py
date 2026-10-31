"""
Invoice Management Router (Member 3)
Endpoints for invoice creation, generation from subscriptions, status lifecycles, and Member 4 reporting.
"""

from fastapi import APIRouter, HTTPException, Query
from typing import Optional, List
from database import get_connection
from invoice_schemas import (
    InvoiceCreateRequest,
    InvoiceStatusUpdateRequest,
    InvoiceOut,
    InvoiceSummaryResponse,
    AvailableSubscriptionOut
)
from services.invoice_service import InvoiceService

router = APIRouter(prefix="/api/invoices", tags=["Invoice Management"])

@router.get("", response_model=List[InvoiceOut])
def list_invoices(
    status: Optional[str] = Query(None, description="Filter by status: Draft, Posted, Paid, Cancelled"),
    search: Optional[str] = Query(None, description="Search by invoice number, customer name, email"),
    subscription_id: Optional[str] = Query(None, description="Filter by subscription ID")
):
    """Retrieve all invoices with optional filtering."""
    return InvoiceService.list_invoices(status=status, search=search, subscription_id=subscription_id)

@router.get("/summary/metrics", response_model=InvoiceSummaryResponse)
def get_invoice_metrics():
    """
    Exposes invoice summary metrics for Member 4 (Payment Tracking & Reports):
    Total invoiced, total paid, outstanding draft amounts, and tax totals.
    """
    return InvoiceService.get_summary_metrics()

@router.get("/subscriptions/available", response_model=List[AvailableSubscriptionOut])
def get_available_subscriptions():
    """
    Integrates with Member 2's subscription data.
    Lists subscriptions and checks if an active invoice already exists for the current cycle.
    """
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM mock_subscriptions ORDER BY subscription_code ASC")
        rows = cursor.fetchall()
        result = []
        for r in rows:
            sub = dict(r)
            # Check if active invoice exists for this cycle
            cursor.execute("""
            SELECT id FROM invoices 
            WHERE subscription_id = ? 
              AND billing_cycle_start = ? 
              AND billing_cycle_end = ? 
              AND status != 'Cancelled'
            """, (sub["id"], sub["billing_cycle_start"], sub["billing_cycle_end"]))
            has_inv = cursor.fetchone() is not None
            sub["has_invoice"] = has_inv
            result.append(AvailableSubscriptionOut(**sub))
        return result
    finally:
        conn.close()

@router.post("", response_model=InvoiceOut, status_code=201)
def create_invoice(payload: InvoiceCreateRequest):
    """
    Creates a new invoice with automatic tax, discount calculation,
    and duplicate billing cycle prevention.
    """
    try:
        return InvoiceService.create_invoice(payload.dict())
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

@router.post("/generate-from-subscription/{subscription_id}", response_model=InvoiceOut, status_code=201)
def generate_invoice_from_subscription(
    subscription_id: str,
    discount_code: Optional[str] = Query(None, description="Optional coupon code to apply")
):
    """
    Generates an invoice directly from Member 2's subscription details.
    Prevents duplicate generation for the same billing cycle.
    """
    try:
        return InvoiceService.generate_from_subscription(subscription_id, discount_code=discount_code)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")

@router.get("/{invoice_id}", response_model=InvoiceOut)
def get_invoice(invoice_id: str):
    """Retrieve full details of a single invoice including line items and tax breakdown."""
    inv = InvoiceService.get_invoice_by_id(invoice_id)
    if not inv:
        raise HTTPException(status_code=404, detail="Invoice not found.")
    return inv

@router.patch("/{invoice_id}/status", response_model=InvoiceOut)
def update_invoice_status(invoice_id: str, payload: InvoiceStatusUpdateRequest):
    """
    Update invoice status (Draft -> Posted -> Paid / Cancelled).
    Exposed for Member 4 payment reconciliation.
    """
    try:
        return InvoiceService.update_status(invoice_id, payload.status)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal error: {str(e)}")
