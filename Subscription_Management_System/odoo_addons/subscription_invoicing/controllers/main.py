# -*- coding: utf-8 -*-
from odoo import http
from odoo.http import request, Response
import json

class SubscriptionInvoiceController(http.Controller):

    @http.route('/api/invoices', type='http', auth='public', methods=['GET'], csrf=False)
    def list_invoices(self, **kwargs):
        domain = []
        if kwargs.get('status') and kwargs.get('status') != 'All':
            domain.append(('status', '=', kwargs.get('status')))
        invoices = request.env['subscription.invoice'].sudo().search(domain)
        result = []
        for inv in invoices:
            result.append({
                'id': str(inv.id),
                'invoice_number': inv.name,
                'customer_name': inv.partner_name,
                'customer_email': inv.partner_email,
                'customer_state': inv.customer_state,
                'company_state': inv.company_state,
                'subtotal': inv.subtotal,
                'discount_code': inv.discount_code,
                'discount_amount': inv.discount_amount,
                'taxable_amount': inv.taxable_amount,
                'is_inter_state': inv.is_inter_state,
                'cgst_rate': inv.cgst_rate,
                'cgst_amount': inv.cgst_amount,
                'sgst_rate': inv.sgst_rate,
                'sgst_amount': inv.sgst_amount,
                'igst_rate': inv.igst_rate,
                'igst_amount': inv.igst_amount,
                'total_tax': inv.total_tax,
                'total_amount': inv.total_amount,
                'status': inv.status,
                'issue_date': str(inv.issue_date),
                'due_date': str(inv.due_date),
            })
        return Response(json.dumps(result), content_type='application/json')

    @http.route('/api/taxes', type='http', auth='public', methods=['GET'], csrf=False)
    def list_taxes(self, **kwargs):
        taxes = request.env['subscription.tax.rate'].sudo().search([])
        result = [{
            'id': str(t.id),
            'name': t.name,
            'rate': t.rate,
            'description': t.description,
            'is_active': t.is_active,
        } for t in taxes]
        return Response(json.dumps(result), content_type='application/json')

    @http.route('/api/discounts', type='http', auth='public', methods=['GET'], csrf=False)
    def list_discounts(self, **kwargs):
        discounts = request.env['subscription.discount'].sudo().search([])
        result = [{
            'id': str(d.id),
            'code': d.code,
            'name': d.name,
            'discount_type': d.discount_type,
            'value': d.value,
            'scope': d.scope,
            'min_purchase_amount': d.min_purchase_amount,
            'min_quantity': d.min_quantity,
            'is_active': d.is_active,
        } for d in discounts]
        return Response(json.dumps(result), content_type='application/json')
