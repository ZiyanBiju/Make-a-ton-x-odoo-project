# -*- coding: utf-8 -*-
from odoo import models, fields, api
from odoo.exceptions import ValidationError
from datetime import datetime

class SubscriptionDiscount(models.Model):
    _name = 'subscription.discount'
    _description = 'Subscription Promotional Discount'

    code = fields.Char(string='Discount Code', required=True, copy=False)
    name = fields.Char(string='Discount Name', required=True)
    discount_type = fields.Selection([
        ('PERCENTAGE', 'Percentage (%)'),
        ('FIXED', 'Fixed Amount (Rs.)')
    ], string='Discount Type', required=True, default='PERCENTAGE')
    value = fields.Float(string='Discount Value', required=True)
    scope = fields.Selection([
        ('SUBSCRIPTION', 'Subscription-Wide'),
        ('PRODUCT', 'Product-Specific')
    ], string='Scope', default='SUBSCRIPTION', required=True)
    product_id = fields.Char(string='Product ID')
    min_purchase_amount = fields.Float(string='Minimum Purchase Amount', default=0.0)
    min_quantity = fields.Integer(string='Minimum Quantity', default=1)
    start_date = fields.Datetime(string='Start Date')
    expiry_date = fields.Datetime(string='Expiry Date')
    max_uses = fields.Integer(string='Max Uses (0 = unlimited)', default=0)
    used_count = fields.Integer(string='Used Count', default=0)
    is_active = fields.Boolean(string='Active', default=True)

    _sql_constraints = [
        ('code_unique', 'unique(code)', 'Discount code must be unique!')
    ]

    @api.model
    def validate_and_calculate(self, code, subtotal, quantity=1, product_id=None):
        discount = self.search([('code', '=ilike', code.strip()), ('is_active', '=', True)], limit=1)
        if not discount:
            return {'is_valid': False, 'message': f"Coupon '{code}' does not exist or is inactive.", 'discount_amount': 0.0}

        now = fields.Datetime.now()
        if discount.start_date and now < discount.start_date:
            return {'is_valid': False, 'message': f"Coupon '{code}' is not active yet.", 'discount_amount': 0.0}
        if discount.expiry_date and now > discount.expiry_date:
            return {'is_valid': False, 'message': f"Coupon '{code}' has expired.", 'discount_amount': 0.0}
        if discount.max_uses > 0 and discount.used_count >= discount.max_uses:
            return {'is_valid': False, 'message': f"Coupon '{code}' usage limit reached.", 'discount_amount': 0.0}
        if subtotal < discount.min_purchase_amount:
            return {'is_valid': False, 'message': f"Minimum purchase of Rs. {discount.min_purchase_amount} required.", 'discount_amount': 0.0}
        if quantity < discount.min_quantity:
            return {'is_valid': False, 'message': f"Minimum quantity of {discount.min_quantity} required.", 'discount_amount': 0.0}

        if discount.discount_type == 'PERCENTAGE':
            disc_amount = min(round(subtotal * (discount.value / 100.0), 2), subtotal)
        else:
            disc_amount = min(discount.value, subtotal)

        return {
            'is_valid': True,
            'discount_code': discount.code,
            'discount_name': discount.name,
            'discount_amount': disc_amount,
            'message': f"Discount '{discount.name}' applied (-Rs. {disc_amount})."
        }
