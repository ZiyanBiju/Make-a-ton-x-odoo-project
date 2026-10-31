"""
Discount Management Router (Member 3)
Endpoints for creating, managing, and validating promotional discounts.
"""

from fastapi import APIRouter, HTTPException
import uuid
import datetime
from database import get_connection
from invoice_schemas import (
    DiscountCreate,
    DiscountUpdate,
    DiscountOut,
    DiscountValidateRequest,
    DiscountValidateResponse
)
from services.discount_service import DiscountService

router = APIRouter(prefix="/api/discounts", tags=["Discount Management"])

def _format_discount(r) -> DiscountOut:
    now = datetime.datetime.now()
    is_valid = bool(r["is_active"])
    status_label = "Active" if is_valid else "Disabled"

    # Start date check
    if is_valid and r["start_date"]:
        try:
            if now < datetime.datetime.fromisoformat(r["start_date"]):
                is_valid = False
                status_label = "Scheduled"
        except Exception:
            pass

    # Expiry date check
    if is_valid and r["expiry_date"]:
        try:
            if now > datetime.datetime.fromisoformat(r["expiry_date"]):
                is_valid = False
                status_label = "Expired"
        except Exception:
            pass

    # Usage limit check
    if is_valid and r["max_uses"] > 0 and r["used_count"] >= r["max_uses"]:
        is_valid = False
        status_label = "Exhausted"

    return DiscountOut(
        id=r["id"],
        code=r["code"],
        name=r["name"],
        discount_type=r["discount_type"],
        value=r["value"],
        scope=r["scope"],
        product_id=r["product_id"],
        min_purchase_amount=r["min_purchase_amount"],
        min_quantity=r["min_quantity"],
        start_date=r["start_date"],
        expiry_date=r["expiry_date"],
        max_uses=r["max_uses"],
        used_count=r["used_count"],
        is_active=bool(r["is_active"]),
        created_at=r["created_at"],
        is_valid_now=is_valid,
        status_label=status_label
    )

@router.get("", response_model=list[DiscountOut])
def get_discounts():
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM discounts ORDER BY created_at DESC")
        rows = cursor.fetchall()
        return [_format_discount(r) for r in rows]
    finally:
        conn.close()

@router.post("", response_model=DiscountOut, status_code=201)
def create_discount(payload: DiscountCreate):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        # Ensure code uniqueness
        cursor.execute("SELECT id FROM discounts WHERE code = ?", (payload.code.strip().upper(),))
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail=f"Discount code '{payload.code}' already exists.")

        disc_id = str(uuid.uuid4())
        now = datetime.datetime.now().isoformat()
        cursor.execute("""
        INSERT INTO discounts (
            id, code, name, discount_type, value, scope, product_id,
            min_purchase_amount, min_quantity, start_date, expiry_date, max_uses, used_count, is_active, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 1, ?)
        """, (
            disc_id, payload.code.strip().upper(), payload.name, payload.discount_type.upper(),
            payload.value, payload.scope.upper(), payload.product_id,
            payload.min_purchase_amount, payload.min_quantity,
            payload.start_date, payload.expiry_date, payload.max_uses, now
        ))
        conn.commit()

        cursor.execute("SELECT * FROM discounts WHERE id = ?", (disc_id,))
        return _format_discount(cursor.fetchone())
    finally:
        conn.close()

@router.put("/{disc_id}", response_model=DiscountOut)
def update_discount(disc_id: str, payload: DiscountUpdate):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM discounts WHERE id = ?", (disc_id,))
        existing = cursor.fetchone()
        if not existing:
            raise HTTPException(status_code=404, detail="Discount not found.")

        name = payload.name if payload.name is not None else existing["name"]
        val = payload.value if payload.value is not None else existing["value"]
        min_p = payload.min_purchase_amount if payload.min_purchase_amount is not None else existing["min_purchase_amount"]
        min_q = payload.min_quantity if payload.min_quantity is not None else existing["min_quantity"]
        s_date = payload.start_date if payload.start_date is not None else existing["start_date"]
        e_date = payload.expiry_date if payload.expiry_date is not None else existing["expiry_date"]
        m_uses = payload.max_uses if payload.max_uses is not None else existing["max_uses"]
        active = (1 if payload.is_active else 0) if payload.is_active is not None else existing["is_active"]

        cursor.execute("""
        UPDATE discounts SET 
            name = ?, value = ?, min_purchase_amount = ?, min_quantity = ?,
            start_date = ?, expiry_date = ?, max_uses = ?, is_active = ?
        WHERE id = ?
        """, (name, val, min_p, min_q, s_date, e_date, m_uses, active, disc_id))
        conn.commit()

        cursor.execute("SELECT * FROM discounts WHERE id = ?", (disc_id,))
        return _format_discount(cursor.fetchone())
    finally:
        conn.close()

@router.delete("/{disc_id}")
def delete_discount(disc_id: str):
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM discounts WHERE id = ?", (disc_id,))
        if not cursor.fetchone():
            raise HTTPException(status_code=404, detail="Discount not found.")
        cursor.execute("UPDATE discounts SET is_active = 0 WHERE id = ?", (disc_id,))
        conn.commit()
        return {"message": "Discount deactivated successfully."}
    finally:
        conn.close()

@router.post("/validate", response_model=DiscountValidateResponse)
def validate_discount(payload: DiscountValidateRequest):
    """
    Validates discount eligibility against an order/subtotal:
    Checks active status, start/expiry dates, usage limits, minimum purchase, and min quantity.
    """
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM discounts WHERE code = ?", (payload.code.strip().upper(),))
        row = cursor.fetchone()
        if not row:
            return DiscountValidateResponse(
                is_valid=False,
                discount_code=payload.code,
                discount_amount=0.0,
                message=f"Discount coupon '{payload.code}' does not exist."
            )

        res = DiscountService.validate_and_calculate(
            dict(row),
            subtotal=payload.subtotal,
            total_quantity=payload.total_quantity,
            product_id=payload.product_id
        )
        return DiscountValidateResponse(**res)
    finally:
        conn.close()
