"""
Comprehensive Automated Test Suite for Member 3
Tests Tax Calculation, Discount Rules, Invoice Generation, Duplicate Prevention, and Reporting.
"""

import sys
import os

# Add backend directory and venv site-packages to sys.path
backend_dir = os.path.dirname(__file__)
site_packages = os.path.join(backend_dir, "venv", "Lib", "site-packages")
sys.path.insert(0, backend_dir)
if os.path.exists(site_packages):
    sys.path.insert(0, site_packages)

from database import init_db, get_connection
from services.tax_service import TaxService
from services.discount_service import DiscountService
from services.invoice_service import InvoiceService

def run_tests():
    print("=== Running Member 3 Test Suite ===")
    init_db()

    # Clear previous test invoice for sub-101 to ensure idempotency
    conn = get_connection()
    conn.execute("DELETE FROM invoice_items WHERE invoice_id IN (SELECT id FROM invoices WHERE subscription_id = 'sub-101')")
    conn.execute("DELETE FROM invoices WHERE subscription_id = 'sub-101'")
    conn.commit()
    conn.close()

    # --- Test 1: Tax Management (GST) ---
    print("\n[Test 1] GST Tax Calculations...")
    # 1.1 Intra-state (Kerala to Kerala)
    intra = TaxService.calculate_tax(1000.0, 18.0, customer_state="Kerala", company_state="Kerala")
    assert not intra["is_inter_state"], "Should be intra-state"
    assert intra["cgst_rate"] == 9.0, f"Expected 9.0 CGST rate, got {intra['cgst_rate']}"
    assert intra["sgst_rate"] == 9.0, f"Expected 9.0 SGST rate, got {intra['sgst_rate']}"
    assert intra["cgst_amount"] == 90.0, f"Expected 90.0 CGST, got {intra['cgst_amount']}"
    assert intra["sgst_amount"] == 90.0, f"Expected 90.0 SGST, got {intra['sgst_amount']}"
    assert intra["igst_amount"] == 0.0, f"Expected 0.0 IGST, got {intra['igst_amount']}"
    assert intra["total_tax"] == 180.0, f"Expected 180.0 total tax, got {intra['total_tax']}"
    assert intra["final_amount"] == 1180.0, f"Expected 1180.0 final amount, got {intra['final_amount']}"
    print("  PASS: Intra-state (CGST 9% + SGST 9%) correctly split.")

    # 1.2 Inter-state (Karnataka to Kerala)
    inter = TaxService.calculate_tax(1000.0, 18.0, customer_state="Karnataka", company_state="Kerala")
    assert inter["is_inter_state"], "Should be inter-state"
    assert inter["igst_rate"] == 18.0, f"Expected 18.0 IGST rate, got {inter['igst_rate']}"
    assert inter["igst_amount"] == 180.0, f"Expected 180.0 IGST, got {inter['igst_amount']}"
    assert inter["cgst_amount"] == 0.0, f"Expected 0.0 CGST, got {inter['cgst_amount']}"
    assert inter["sgst_amount"] == 0.0, f"Expected 0.0 SGST, got {inter['sgst_amount']}"
    assert inter["final_amount"] == 1180.0
    print("  PASS: Inter-state (IGST 18%) correctly calculated.")

    # --- Test 2: Discount Management ---
    print("\n[Test 2] Discount Rules & Validation...")
    # 2.1 Percentage Discount
    disc_pct = {
        "code": "TESTPCT", "name": "10% Off", "discount_type": "PERCENTAGE",
        "value": 10.0, "scope": "SUBSCRIPTION", "min_purchase_amount": 500.0,
        "min_quantity": 1, "is_active": 1, "max_uses": 10, "used_count": 0
    }
    res_pct = DiscountService.validate_and_calculate(disc_pct, subtotal=1500.0, total_quantity=1)
    assert res_pct["is_valid"], "Discount should be valid"
    assert res_pct["discount_amount"] == 150.0, f"Expected 150.0, got {res_pct['discount_amount']}"
    print("  PASS: Percentage discount calculation valid.")

    # 2.2 Min Purchase Check
    res_min = DiscountService.validate_and_calculate(disc_pct, subtotal=300.0, total_quantity=1)
    assert not res_min["is_valid"], "Should be invalid due to min purchase"
    print("  PASS: Minimum purchase requirement enforced.")

    # 2.3 Expiry Check
    disc_exp = {
        "code": "EXP", "name": "Expired", "discount_type": "FIXED",
        "value": 50.0, "is_active": 1, "expiry_date": "2024-01-01T00:00:00"
    }
    res_exp = DiscountService.validate_and_calculate(disc_exp, subtotal=1000.0)
    assert not res_exp["is_valid"], "Should be invalid due to expiry"
    print("  PASS: Expiry date validation enforced.")

    # --- Test 3: Invoice Generation & Duplicate Prevention ---
    print("\n[Test 3] Invoice Generation & Duplicate Cycle Prevention...")
    # 3.1 Generate invoice from subscription sub-101
    inv1 = InvoiceService.generate_from_subscription("sub-101", discount_code="WELCOME10")
    assert inv1["invoice_number"].startswith("INV-"), f"Invalid invoice number {inv1['invoice_number']}"
    assert inv1["subscription_id"] == "sub-101"
    assert inv1["discount_amount"] > 0, "Discount should be applied"
    assert inv1["is_inter_state"], "Infosys (Karnataka) should be inter-state"
    assert inv1["igst_amount"] > 0, "Should have IGST"
    print(f"  PASS: Generated invoice {inv1['invoice_number']} for sub-101. Subtotal: {inv1['subtotal']}, Total: {inv1['total_amount']}.")

    # 3.2 Duplicate Prevention: Generating again for the same cycle should fail!
    try:
        InvoiceService.generate_from_subscription("sub-101")
        assert False, "Should have raised duplicate cycle error!"
    except ValueError as e:
        assert "Duplicate Invoice Error" in str(e), f"Unexpected error message: {e}"
        print(f"  PASS: Duplicate invoice correctly blocked: {e}")

    # --- Test 4: Status Lifecycle ---
    print("\n[Test 4] Status Lifecycle Transitions...")
    # Status transitions: Posted -> Paid
    paid_inv = InvoiceService.update_status(inv1["id"], "Paid")
    assert paid_inv["status"] == "Paid"
    print("  PASS: Status transition Posted -> Paid successful.")

    # --- Test 5: Member 4 Analytics & Payment Tracking ---
    print("\n[Test 5] Member 4 Metrics Exposure...")
    metrics = InvoiceService.get_summary_metrics()
    assert metrics["total_invoices"] >= 1
    assert metrics["paid_count"] >= 1
    assert metrics["total_tax_collected"] > 0
    print(f"  PASS: Metrics exposed for Member 4: {metrics}")

    print("\n ALL BACKEND TESTS PASSED SUCCESSFULLY!")

if __name__ == "__main__":
    run_tests()
