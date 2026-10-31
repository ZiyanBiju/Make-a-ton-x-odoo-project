"""
Tax Service for Member 3: Tax Management.
Calculates CGST + SGST for intra-state transactions.
Calculates IGST for inter-state transactions.
"""

from typing import Dict, Any

class TaxService:
    @staticmethod
    def calculate_tax(
        taxable_amount: float,
        tax_rate: float,
        customer_state: str,
        company_state: str = "Kerala"
    ) -> Dict[str, Any]:
        """
        Calculate GST components based on destination principle.
        If customer_state == company_state -> Intra-state (CGST + SGST)
        If customer_state != company_state -> Inter-state (IGST)
        """
        cust_norm = customer_state.strip().lower() if customer_state else ""
        comp_norm = company_state.strip().lower() if company_state else ""

        is_inter_state = (cust_norm != comp_norm)
        taxable_amount = max(0.0, round(taxable_amount, 2))

        if is_inter_state:
            igst_rate = float(tax_rate)
            igst_amount = round(taxable_amount * (igst_rate / 100.0), 2)
            cgst_rate = 0.0
            cgst_amount = 0.0
            sgst_rate = 0.0
            sgst_amount = 0.0
            total_tax = igst_amount
        else:
            igst_rate = 0.0
            igst_amount = 0.0
            cgst_rate = round(float(tax_rate) / 2.0, 2)
            sgst_rate = round(float(tax_rate) / 2.0, 2)
            cgst_amount = round(taxable_amount * (cgst_rate / 100.0), 2)
            sgst_amount = round(taxable_amount * (sgst_rate / 100.0), 2)
            total_tax = round(cgst_amount + sgst_amount, 2)

        return {
            "taxable_amount": taxable_amount,
            "tax_rate": float(tax_rate),
            "is_inter_state": is_inter_state,
            "customer_state": customer_state,
            "company_state": company_state,
            "cgst_rate": cgst_rate,
            "cgst_amount": cgst_amount,
            "sgst_rate": sgst_rate,
            "sgst_amount": sgst_amount,
            "igst_rate": igst_rate,
            "igst_amount": igst_amount,
            "total_tax": total_tax,
            "final_amount": round(taxable_amount + total_tax, 2)
        }
