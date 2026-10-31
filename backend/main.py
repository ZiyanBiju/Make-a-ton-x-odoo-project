
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, Literal
from datetime import date
from uuid import uuid4

app = FastAPI(
    title="Brightloop - Subscription Management",
    description="Payment Management, Dashboard and Reports API",
    version="1.0.0"
)

# Flutter frontend connection
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Temporary storage for hackathon demonstration
payments = []


# -----------------------------
# REQUEST MODELS
# -----------------------------

class PaymentCreate(BaseModel):
    subscription_id: str
    invoice_id: str
    amount: float = Field(gt=0)
    payment_method: str
    payment_date: date
    status: Literal["paid", "pending", "overdue"] = "paid"
    notes: Optional[str] = None


class PaymentUpdate(BaseModel):
    amount: Optional[float] = Field(default=None, gt=0)
    payment_method: Optional[str] = None
    status: Optional[Literal["paid", "pending", "overdue"]] = None
    notes: Optional[str] = None


# -----------------------------
# HOME AND HEALTH
# -----------------------------

@app.get("/")
def home():
    return {
        "message": "Welcome to Brightloop API",
        "module": "Payment, Dashboard and Reports",
        "status": "Running"
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


# -----------------------------
# PAYMENT MANAGEMENT
# -----------------------------

@app.post("/payments/", tags=["Payments"])
def create_payment(payment: PaymentCreate):

    new_payment = {
        "id": str(uuid4()),
        **payment.model_dump()
    }

    payments.append(new_payment)

    return {
        "message": "Payment recorded successfully",
        "payment": new_payment
    }


@app.get("/payments/", tags=["Payments"])
def get_payments():

    return {
        "total": len(payments),
        "payments": payments
    }


@app.get("/payments/{payment_id}", tags=["Payments"])
def get_payment(payment_id: str):

    for payment in payments:
        if payment["id"] == payment_id:
            return payment

    raise HTTPException(404, "Payment not found")


@app.put("/payments/{payment_id}", tags=["Payments"])
def update_payment(payment_id: str, update: PaymentUpdate):

    for payment in payments:
        if payment["id"] == payment_id:

            changes = update.model_dump(exclude_unset=True)
            payment.update(changes)

            return {
                "message": "Payment updated successfully",
                "payment": payment
            }

    raise HTTPException(404, "Payment not found")


@app.delete("/payments/{payment_id}", tags=["Payments"])
def delete_payment(payment_id: str):

    for payment in payments:
        if payment["id"] == payment_id:
            payments.remove(payment)

            return {"message": "Payment deleted successfully"}

    raise HTTPException(404, "Payment not found")


# -----------------------------
# DASHBOARD
# -----------------------------

@app.get("/dashboard/", tags=["Dashboard"])
def get_dashboard():

    total_payments = len(payments)

    paid = [
        p for p in payments
        if p["status"] == "paid"
    ]

    pending = [
        p for p in payments
        if p["status"] == "pending"
    ]

    overdue = [
        p for p in payments
        if p["status"] == "overdue"
    ]

    total_revenue = sum(p["amount"] for p in paid)

    pending_amount = sum(p["amount"] for p in pending)

    overdue_amount = sum(p["amount"] for p in overdue)

    return {
        "total_payments": total_payments,
        "total_revenue": round(total_revenue, 2),
        "pending_payments": len(pending),
        "pending_amount": round(pending_amount, 2),
        "overdue_payments": len(overdue),
        "overdue_amount": round(overdue_amount, 2),
        "successful_payments": len(paid)
    }


# -----------------------------
# REPORTS
# -----------------------------

@app.get("/reports/", tags=["Reports"])
def get_reports(
    start_date: Optional[date] = None,
    end_date: Optional[date] = None
):

    filtered = payments.copy()

    if start_date:
        filtered = [
            p for p in filtered
            if p["payment_date"] >= start_date
        ]

    if end_date:
        filtered = [
            p for p in filtered
            if p["payment_date"] <= end_date
        ]

    if start_date and end_date and start_date > end_date:
        raise HTTPException(
            400,
            "Start date cannot be after end date"
        )

    revenue = sum(
        p["amount"] for p in filtered
        if p["status"] == "paid"
    )

    pending = sum(
        p["amount"] for p in filtered
        if p["status"] == "pending"
    )

    overdue = sum(
        p["amount"] for p in filtered
        if p["status"] == "overdue"
    )

    return {
        "report_period": {
            "start_date": start_date,
            "end_date": end_date
        },
        "total_records": len(filtered),
        "total_revenue": round(revenue, 2),
        "pending_amount": round(pending, 2),
        "overdue_amount": round(overdue, 2),
        "payments": filtered
    }


# -----------------------------
# PAYMENT METHOD SUMMARY
# -----------------------------

@app.get("/reports/payment-methods", tags=["Reports"])
def payment_method_report():

    summary = {}

    for payment in payments:
        method = payment["payment_method"]

        if method not in summary:
            summary[method] = {
                "count": 0,
                "amount": 0
            }

        summary[method]["count"] += 1
        summary[method]["amount"] += payment["amount"]

    return {
        "payment_methods": summary
    }


# -----------------------------
# PAYMENT STATUS SUMMARY
# -----------------------------

@app.get("/reports/payment-status", tags=["Reports"])
def payment_status_report():

    return {
        "paid": sum(
            1 for p in payments if p["status"] == "paid"
        ),
        "pending": sum(
            1 for p in payments if p["status"] == "pending"
        ),
        "overdue": sum(
            1 for p in payments if p["status"] == "overdue"
        )
    }
