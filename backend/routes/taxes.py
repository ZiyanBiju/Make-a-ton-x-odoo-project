"""
Tax Management Router (Member 3)
Endpoints for configuring GST rates and tax calculation breakdown.
"""

from fastapi import APIRouter, HTTPException
import uuid
import datetime
from database import get_connection
from invoice_schemas import (
    TaxRateCreate,
    TaxRateUpdate,
    TaxRateOut,
    TaxCalculateRequest,
    TaxCalculateResponse
)
from services.tax_service import TaxService

router = APIRouter(prefix="/api/taxes", tags=["Tax Management"])

@router.get("", response_model=list[TaxRateOut])
def get_tax_rates(active_only: bool = False):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        query = "SELECT * FROM tax_rates"
        if active_only:
            query += " WHERE is_active = 1"
        query += " ORDER BY rate ASC"
        cursor.execute(query)
        rows = cursor.fetchall()
        return [
            TaxRateOut(
                id=r["id"],
                name=r["name"],
                rate=r["rate"],
                description=r["description"],
                is_active=bool(r["is_active"]),
                created_at=r["created_at"]
            )
            for r in rows
        ]
    finally:
        conn.close()

@router.post("", response_model=TaxRateOut, status_code=201)
def create_tax_rate(payload: TaxRateCreate):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        tax_id = str(uuid.uuid4())
        now = datetime.datetime.now().isoformat()
        cursor.execute("""
        INSERT INTO tax_rates (id, name, rate, description, is_active, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
        """, (tax_id, payload.name, payload.rate, payload.description, 1 if payload.is_active else 0, now))
        conn.commit()
        return TaxRateOut(
            id=tax_id,
            name=payload.name,
            rate=payload.rate,
            description=payload.description,
            is_active=payload.is_active,
            created_at=now
        )
    finally:
        conn.close()

@router.put("/{tax_id}", response_model=TaxRateOut)
def update_tax_rate(tax_id: str, payload: TaxRateUpdate):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM tax_rates WHERE id = ?", (tax_id,))
        existing = cursor.fetchone()
        if not existing:
            raise HTTPException(status_code=404, detail="Tax rate not found.")

        name = payload.name if payload.name is not None else existing["name"]
        rate = payload.rate if payload.rate is not None else existing["rate"]
        desc = payload.description if payload.description is not None else existing["description"]
        active = (1 if payload.is_active else 0) if payload.is_active is not None else existing["is_active"]

        cursor.execute("""
        UPDATE tax_rates SET name = ?, rate = ?, description = ?, is_active = ? WHERE id = ?
        """, (name, rate, desc, active, tax_id))
        conn.commit()

        return TaxRateOut(
            id=tax_id,
            name=name,
            rate=rate,
            description=desc,
            is_active=bool(active),
            created_at=existing["created_at"]
        )
    finally:
        conn.close()

@router.delete("/{tax_id}")
def delete_tax_rate(tax_id: str):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM tax_rates WHERE id = ?", (tax_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Tax rate not found.")
        cursor.execute("UPDATE tax_rates SET is_active = 0 WHERE id = ?", (tax_id,))
        conn.commit()
        return {"message": "Tax rate deactivated successfully."}
    finally:
        conn.close()

@router.post("/calculate", response_model=TaxCalculateResponse)
def calculate_tax(payload: TaxCalculateRequest):
    """
    Live GST tax calculation simulator:
    - Intra-state (Customer State == Seller State): CGST + SGST
    - Inter-state (Customer State != Seller State): IGST
    """
    res = TaxService.calculate_tax(
        taxable_amount=payload.taxable_amount,
        tax_rate=payload.tax_rate,
        customer_state=payload.customer_state,
        company_state=payload.company_state
    )
    return TaxCalculateResponse(**res)
