# -*- coding: utf-8 -*-
from odoo import models, fields, api

class SubscriptionTaxRate(models.Model):
    _name = 'subscription.tax.rate'
    _description = 'GST Tax Rate Configuration'

    name = fields.Char(string='Tax Name', required=True)
    rate = fields.Float(string='GST Rate (%)', required=True)
    description = fields.Text(string='Description')
    is_active = fields.Boolean(string='Active', default=True)

    @api.model
    def compute_gst(self, taxable_amount, tax_rate, customer_state, company_state='Kerala'):
        """Computes CGST+SGST for intra-state or IGST for inter-state"""
        is_inter = (customer_state or '').strip().lower() != (company_state or '').strip().lower()
        if is_inter:
            return {
                'is_inter_state': True,
                'cgst_rate': 0.0,
                'cgst_amount': 0.0,
                'sgst_rate': 0.0,
                'sgst_amount': 0.0,
                'igst_rate': tax_rate,
                'igst_amount': round(taxable_amount * (tax_rate / 100.0), 2),
                'total_tax': round(taxable_amount * (tax_rate / 100.0), 2),
            }
        else:
            half_rate = tax_rate / 2.0
            half_amt = round(taxable_amount * (half_rate / 100.0), 2)
            return {
                'is_inter_state': False,
                'cgst_rate': half_rate,
                'cgst_amount': half_amt,
                'sgst_rate': half_rate,
                'sgst_amount': half_amt,
                'igst_rate': 0.0,
                'igst_amount': 0.0,
                'total_tax': round(half_amt * 2, 2),
            }
