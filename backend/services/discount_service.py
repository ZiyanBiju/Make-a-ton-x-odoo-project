"""
Discount Service for Member 3: Discount Management.
Handles validation and calculation for:
- Fixed amount discounts
- Percentage discounts
- Minimum purchase amounts
- Minimum quantities
- Start & Expiry dates
- Usage limits (max_uses)
- Product-specific vs Subscription-wide scope
"""

import datetime
from typing import Dict, Any, Optional

class DiscountService:
    @staticmethod
    def validate_and_calculate(
        discount: Dict[str, Any],
        subtotal: float,
        total_quantity: int = 1,
        product_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Validates discount rules and calculates the deduction amount.
        Returns a dict with is_valid, discount_amount, message.
        """
        code = discount.get("code", "")
        name = discount.get("name", "")

        # 1. Active status check
        if not discount.get("is_active", 1):
            return {
                "is_valid": False,
                "discount_code": code,
                "discount_name": name,
                "discount_amount": 0.0,
                "message": f"Discount code '{code}' is disabled."
            }

        now = datetime.datetime.now()

        # 2. Start date check
        start_date_str = discount.get("start_date")
        if start_date_str:
            try:
                start_dt = datetime.datetime.fromisoformat(start_date_str)
                if now < start_dt:
                    return {
                        "is_valid": False,
                        "discount_code": code,
                        "discount_name": name,
                        "discount_amount": 0.0,
                        "message": f"Discount code '{code}' is not active yet (starts on {start_dt.strftime('%Y-%m-%d')})."
                    }
            except Exception:
                pass

        # 3. Expiry date check
        expiry_date_str = discount.get("expiry_date")
        if expiry_date_str:
            try:
                expiry_dt = datetime.datetime.fromisoformat(expiry_date_str)
                if now > expiry_dt:
                    return {
                        "is_valid": False,
                        "discount_code": code,
                        "discount_name": name,
                        "discount_amount": 0.0,
                        "message": f"Discount code '{code}' has expired on {expiry_dt.strftime('%Y-%m-%d')}."
                    }
            except Exception:
                pass

        # 4. Usage limit check
        max_uses = discount.get("max_uses", 0)
        used_count = discount.get("used_count", 0)
        if max_uses > 0 and used_count >= max_uses:
            return {
                "is_valid": False,
                "discount_code": code,
                "discount_name": name,
                "discount_amount": 0.0,
                "message": f"Discount code '{code}' has reached its maximum usage limit ({max_uses}/{max_uses})."
            }

        # 5. Minimum purchase amount check
        min_purchase = discount.get("min_purchase_amount", 0.0)
        if subtotal < min_purchase:
            return {
                "is_valid": False,
                "discount_code": code,
                "discount_name": name,
                "discount_amount": 0.0,
                "message": f"Minimum purchase amount of Rs. {min_purchase:.2f} required to use code '{code}'. Current subtotal: Rs. {subtotal:.2f}."
            }

        # 6. Minimum quantity check
        min_qty = discount.get("min_quantity", 1)
        if total_quantity < min_qty:
            return {
                "is_valid": False,
                "discount_code": code,
                "discount_name": name,
                "discount_amount": 0.0,
                "message": f"Minimum quantity of {min_qty} required to use code '{code}'. Current quantity: {total_quantity}."
            }

        # 7. Product-specific check
        scope = discount.get("scope", "SUBSCRIPTION").upper()
        target_product_id = discount.get("product_id")
        if scope == "PRODUCT" and target_product_id:
            if not product_id or str(product_id) != str(target_product_id):
                return {
                    "is_valid": False,
                    "discount_code": code,
                    "discount_name": name,
                    "discount_amount": 0.0,
                    "message": f"Discount '{code}' is product-specific and does not apply to this selection."
                }

        # 8. Calculate Discount Value
        disc_type = discount.get("discount_type", "PERCENTAGE").upper()
        raw_val = float(discount.get("value", 0.0))

        if disc_type == "PERCENTAGE":
            calc_discount = round(subtotal * (raw_val / 100.0), 2)
            # Cannot exceed subtotal
            calc_discount = min(calc_discount, subtotal)
        else: # FIXED
            calc_discount = min(raw_val, subtotal)

        return {
            "is_valid": True,
            "discount_code": code,
            "discount_name": name,
            "discount_type": disc_type,
            "discount_value": raw_val,
            "discount_amount": round(calc_discount, 2),
            "message": f"Discount '{name}' applied successfully (-Rs. {calc_discount:.2f})."
        }
