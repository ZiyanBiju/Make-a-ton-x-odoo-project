"""
Invoice Service for Member 3: Invoice Management.
Handles:
- Unique invoice numbering (INV-YYYY-XXXX)
- Line items calculation
- Duplicate billing cycle prevention
- Status lifecycles (Draft -> Posted -> Paid / Cancelled)
- Integration with Subscriptions (Member 2)
- Exposure of invoice details for Member 4
"""

import datetime
import uuid
import sqlite3
from typing import Dict, Any, List, Optional
from database import get_connection
from services.tax_service import TaxService
from services.discount_service import DiscountService

class InvoiceService:
    @staticmethod
    def generate_invoice_number(conn: sqlite3.Connection) -> str:
        """Generates sequential, unique invoice number like INV-2026-0001"""
        year = datetime.datetime.now().year
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) as count FROM invoices")
        count = cursor.fetchone()["count"] + 1
        
        while True:
            candidate = f"INV-{year}-{count:04d}"
            cursor.execute("SELECT id FROM invoices WHERE invoice_number = ?", (candidate,))
            if not cursor.fetchone():
                return candidate
            count += 1

    @classmethod
    def check_duplicate_billing_cycle(
        cls,
        conn: sqlite3.Connection,
        subscription_id: str,
        cycle_start: str,
        cycle_end: str,
        exclude_invoice_id: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Check if an active invoice already exists for this subscription cycle.
        Returns the existing invoice if duplicate, None otherwise.
        """
        if not subscription_id or not cycle_start or not cycle_end:
            return None
        cursor = conn.cursor()
        query = """
        SELECT id, invoice_number, status, billing_cycle_start, billing_cycle_end
        FROM invoices
        WHERE subscription_id = ?
          AND billing_cycle_start = ?
          AND billing_cycle_end = ?
          AND status != 'Cancelled'
        """
        params = [subscription_id, cycle_start, cycle_end]
        if exclude_invoice_id:
            query += " AND id != ?"
            params.append(exclude_invoice_id)
        
        cursor.execute(query, params)
        row = cursor.fetchone()
        return dict(row) if row else None

    @classmethod
    def create_invoice(cls, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Calculates line items, discount, taxes, and saves the new invoice.
        Enforces duplicate billing cycle prevention.
        """
        conn = get_connection()
        try:
            cursor = conn.cursor()

            subscription_id = data.get("subscription_id")
            cycle_start = data.get("billing_cycle_start")
            cycle_end = data.get("billing_cycle_end")

            # 1. Enforce Duplicate Billing Cycle Prevention
            if subscription_id and cycle_start and cycle_end:
                dup = cls.check_duplicate_billing_cycle(conn, subscription_id, cycle_start, cycle_end)
                if dup:
                    raise ValueError(
                        f"Duplicate Invoice Error: Invoice '{dup['invoice_number']}' already exists "
                        f"for this subscription cycle ({cycle_start} to {cycle_end}) with status '{dup['status']}'."
                    )

            # 2. Calculate Line Items & Subtotal
            raw_items = data.get("items", [])
            if not raw_items:
                raise ValueError("An invoice must contain at least one line item.")

            subtotal = 0.0
            total_quantity = 0
            for item in raw_items:
                qty = item.get("quantity", 1)
                unit_p = item.get("unit_price", 0.0)
                subtotal += (qty * unit_p)
                total_quantity += qty
            subtotal = round(subtotal, 2)

            # 3. Discount Management Validation
            discount_code = data.get("discount_code")
            discount_amount = 0.0
            if discount_code:
                cursor.execute("SELECT * FROM discounts WHERE code = ?", (discount_code.strip().upper(),))
                disc_row = cursor.fetchone()
                if disc_row:
                    disc_dict = dict(disc_row)
                    val_res = DiscountService.validate_and_calculate(
                        disc_dict,
                        subtotal=subtotal,
                        total_quantity=total_quantity
                    )
                    if not val_res["is_valid"]:
                        raise ValueError(f"Invalid Discount: {val_res['message']}")
                    discount_amount = val_res["discount_amount"]
                    # Increment discount usage
                    cursor.execute("UPDATE discounts SET used_count = used_count + 1 WHERE id = ?", (disc_dict["id"],))
                else:
                    raise ValueError(f"Discount code '{discount_code}' not found.")

            taxable_amount = max(0.0, round(subtotal - discount_amount, 2))

            # 4. Tax Management (GST - CGST + SGST vs IGST)
            customer_state = data.get("customer_state", "Kerala")
            company_state = data.get("company_state", "Kerala")
            
            # Use average or default line tax rate
            primary_tax_rate = raw_items[0].get("tax_rate", 18.0)
            tax_res = TaxService.calculate_tax(
                taxable_amount=taxable_amount,
                tax_rate=primary_tax_rate,
                customer_state=customer_state,
                company_state=company_state
            )

            total_amount = tax_res["final_amount"]
            invoice_id = str(uuid.uuid4())
            inv_number = cls.generate_invoice_number(conn)
            now_iso = datetime.datetime.now().isoformat()
            
            issue_date = data.get("issue_date") or datetime.date.today().isoformat()
            due_date = data.get("due_date") or (datetime.date.today() + datetime.timedelta(days=15)).isoformat()
            initial_status = "Posted" if data.get("auto_post") else "Draft"

            # 5. Insert Invoice
            cursor.execute("""
            INSERT INTO invoices (
                id, invoice_number, subscription_id, billing_cycle_start, billing_cycle_end,
                customer_id, customer_name, customer_email, customer_state, customer_gstin, customer_address,
                company_state, subtotal, discount_code, discount_amount, taxable_amount,
                tax_rate, is_inter_state, cgst_rate, cgst_amount, sgst_rate, sgst_amount,
                igst_rate, igst_amount, total_tax, total_amount, status, issue_date, due_date, notes, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                invoice_id, inv_number, subscription_id, cycle_start, cycle_end,
                data.get("customer_id"), data.get("customer_name"), data.get("customer_email"),
                customer_state, data.get("customer_gstin"), data.get("customer_address"),
                company_state, subtotal, discount_code, discount_amount, taxable_amount,
                tax_res["tax_rate"], 1 if tax_res["is_inter_state"] else 0,
                tax_res["cgst_rate"], tax_res["cgst_amount"],
                tax_res["sgst_rate"], tax_res["sgst_amount"],
                tax_res["igst_rate"], tax_res["igst_amount"],
                tax_res["total_tax"], total_amount, initial_status,
                issue_date, due_date, data.get("notes"), now_iso
            ))

            # 6. Insert Line Items
            item_records = []
            for item in raw_items:
                item_id = str(uuid.uuid4())
                qty = item.get("quantity", 1)
                unit_p = item.get("unit_price", 0.0)
                line_subtotal = round(qty * unit_p, 2)
                # Pro-rate discount per line
                line_disc = round((line_subtotal / subtotal) * discount_amount, 2) if subtotal > 0 else 0.0
                line_taxable = max(0.0, round(line_subtotal - line_disc, 2))
                l_tax_rate = item.get("tax_rate", primary_tax_rate)
                l_tax_amt = round(line_taxable * (l_tax_rate / 100.0), 2)
                l_total = round(line_taxable + l_tax_amt, 2)

                cursor.execute("""
                INSERT INTO invoice_items (
                    id, invoice_id, product_id, product_name, quantity, unit_price,
                    discount_amount, taxable_amount, tax_rate, tax_amount, total_amount
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    item_id, invoice_id, item.get("product_id"), item.get("product_name"),
                    qty, unit_p, line_disc, line_taxable, l_tax_rate, l_tax_amt, l_total
                ))
                item_records.append({
                    "id": item_id,
                    "invoice_id": invoice_id,
                    "product_id": item.get("product_id"),
                    "product_name": item.get("product_name"),
                    "quantity": qty,
                    "unit_price": unit_p,
                    "discount_amount": line_disc,
                    "taxable_amount": line_taxable,
                    "tax_rate": l_tax_rate,
                    "tax_amount": l_tax_amt,
                    "total_amount": l_total
                })

            conn.commit()
            return cls.get_invoice_by_id(invoice_id, conn=conn)

        finally:
            conn.close()

    @classmethod
    def get_invoice_by_id(cls, invoice_id: str, conn: Optional[sqlite3.Connection] = None) -> Optional[Dict[str, Any]]:
        should_close = False
        if conn is None:
            conn = get_connection()
            should_close = True
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM invoices WHERE id = ?", (invoice_id,))
            inv = cursor.fetchone()
            if not inv:
                return None
            res = dict(inv)
            res["is_inter_state"] = bool(res.get("is_inter_state", 0))

            cursor.execute("SELECT * FROM invoice_items WHERE invoice_id = ?", (invoice_id,))
            res["items"] = [dict(row) for row in cursor.fetchall()]
            return res
        finally:
            if should_close:
                conn.close()

    @classmethod
    def list_invoices(
        cls,
        status: Optional[str] = None,
        search: Optional[str] = None,
        subscription_id: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        conn = get_connection()
        try:
            cursor = conn.cursor()
            query = "SELECT * FROM invoices WHERE 1=1"
            params = []

            if status and status.lower() != "all":
                query += " AND status = ?"
                params.append(status)

            if subscription_id:
                query += " AND subscription_id = ?"
                params.append(subscription_id)

            if search:
                query += " AND (invoice_number LIKE ? OR customer_name LIKE ? OR customer_email LIKE ?)"
                term = f"%{search}%"
                params.extend([term, term, term])

            query += " ORDER BY created_at DESC"
            cursor.execute(query, params)
            invoices = []
            for row in cursor.fetchall():
                inv = dict(row)
                inv["is_inter_state"] = bool(inv.get("is_inter_state", 0))
                # Attach line item summary
                cursor.execute("SELECT COUNT(*) as count FROM invoice_items WHERE invoice_id = ?", (inv["id"],))
                invoices.append(inv)
            return invoices
        finally:
            conn.close()

    @classmethod
    def update_status(cls, invoice_id: str, new_status: str) -> Dict[str, Any]:
        valid_statuses = ["Draft", "Posted", "Cancelled", "Paid"]
        if new_status not in valid_statuses:
            raise ValueError(f"Invalid status '{new_status}'. Allowed: {', '.join(valid_statuses)}")

        conn = get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM invoices WHERE id = ?", (invoice_id,))
            inv = cursor.fetchone()
            if not inv:
                raise ValueError("Invoice not found.")

            curr_status = inv["status"]
            # Validation rules for transitions
            if curr_status == "Cancelled" and new_status != "Cancelled":
                raise ValueError("Cannot modify a Cancelled invoice.")
            if curr_status == "Paid" and new_status == "Draft":
                raise ValueError("Cannot revert a Paid invoice to Draft.")

            cursor.execute("UPDATE invoices SET status = ? WHERE id = ?", (new_status, invoice_id))
            conn.commit()
            return cls.get_invoice_by_id(invoice_id, conn=conn)
        finally:
            conn.close()

    @classmethod
    def generate_from_subscription(cls, subscription_id: str, discount_code: Optional[str] = None) -> Dict[str, Any]:
        """
        Integrates with Member 2's subscription data.
        Fetches subscription cycle and automatically builds and validates invoice.
        """
        conn = get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM mock_subscriptions WHERE id = ?", (subscription_id,))
            sub = cursor.fetchone()
            if not sub:
                raise ValueError(f"Subscription with ID '{subscription_id}' not found.")
            sub_dict = dict(sub)

            # Build invoice payload
            payload = {
                "subscription_id": sub_dict["id"],
                "billing_cycle_start": sub_dict["billing_cycle_start"],
                "billing_cycle_end": sub_dict["billing_cycle_end"],
                "customer_id": sub_dict["customer_id"],
                "customer_name": sub_dict["customer_name"],
                "customer_email": sub_dict.get("customer_email"),
                "customer_state": sub_dict["customer_state"],
                "customer_gstin": sub_dict.get("customer_gstin"),
                "customer_address": sub_dict.get("customer_address"),
                "company_state": "Kerala",
                "discount_code": discount_code,
                "notes": f"Generated automatically for Subscription {sub_dict['subscription_code']} (Cycle: {sub_dict['billing_cycle_start']} to {sub_dict['billing_cycle_end']})",
                "auto_post": True,
                "items": [
                    {
                        "product_id": f"prod-{sub_dict['id']}",
                        "product_name": sub_dict["plan_name"],
                        "quantity": sub_dict.get("quantity", 1),
                        "unit_price": sub_dict.get("unit_price", 0.0),
                        "tax_rate": sub_dict.get("default_tax_rate", 18.0)
                    }
                ]
            }
            return cls.create_invoice(payload)
        finally:
            conn.close()

    @classmethod
    def get_summary_metrics(cls) -> Dict[str, Any]:
        """Exposes invoice metrics for Member 4: payment tracking and reports."""
        conn = get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("""
            SELECT 
                COUNT(*) as total_invoices,
                SUM(CASE WHEN status = 'Draft' THEN 1 ELSE 0 END) as draft_count,
                SUM(CASE WHEN status = 'Posted' THEN 1 ELSE 0 END) as posted_count,
                SUM(CASE WHEN status = 'Paid' THEN 1 ELSE 0 END) as paid_count,
                SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) as cancelled_count,
                SUM(total_amount) as total_invoiced,
                SUM(CASE WHEN status = 'Paid' THEN total_amount ELSE 0 END) as total_paid,
                SUM(CASE WHEN status = 'Posted' THEN total_amount ELSE 0 END) as total_outstanding,
                SUM(total_tax) as total_tax,
                SUM(cgst_amount) as total_cgst,
                SUM(sgst_amount) as total_sgst,
                SUM(igst_amount) as total_igst,
                SUM(discount_amount) as total_discounts
            FROM invoices
            """)
            row = cursor.fetchone()
            return {
                "total_invoices": row["total_invoices"] or 0,
                "draft_count": row["draft_count"] or 0,
                "posted_count": row["posted_count"] or 0,
                "paid_count": row["paid_count"] or 0,
                "cancelled_count": row["cancelled_count"] or 0,
                "total_invoiced_amount": round(row["total_invoiced"] or 0.0, 2),
                "total_paid_amount": round(row["total_paid"] or 0.0, 2),
                "total_outstanding_amount": round(row["total_outstanding"] or 0.0, 2),
                "total_tax_collected": round(row["total_tax"] or 0.0, 2),
                "total_cgst": round(row["total_cgst"] or 0.0, 2),
                "total_sgst": round(row["total_sgst"] or 0.0, 2),
                "total_igst": round(row["total_igst"] or 0.0, 2),
                "total_discounts_given": round(row["total_discounts"] or 0.0, 2)
            }
        finally:
            conn.close()
