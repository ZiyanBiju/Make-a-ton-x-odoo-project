# -*- coding: utf-8 -*-
from odoo import models, fields, api
from odoo.exceptions import ValidationError

class SubscriptionInvoice(models.Model):
    _name = 'subscription.invoice'
    _description = 'Subscription Invoice (Member 3)'
    _order = 'create_date desc'

    name = fields.Char(string='Invoice Number', required=True, copy=False, readonly=True, default='New')
    subscription_id = fields.Char(string='Subscription Reference')
    billing_cycle_start = fields.Date(string='Billing Cycle Start')
    billing_cycle_end = fields.Date(string='Billing Cycle End')

    partner_name = fields.Char(string='Customer Name', required=True)
    partner_email = fields.Char(string='Customer Email')
    customer_state = fields.Char(string='Customer State (Place of Supply)', required=True, default='Kerala')
    company_state = fields.Char(string='Company State', default='Kerala', required=True)
    customer_gstin = fields.Char(string='Customer GSTIN')
    customer_address = fields.Text(string='Billing Address')

    status = fields.Selection([
        ('Draft', 'Draft'),
        ('Posted', 'Posted'),
        ('Paid', 'Paid'),
        ('Cancelled', 'Cancelled')
    ], string='Status', default='Draft', required=True)

    issue_date = fields.Date(string='Issue Date', default=fields.Date.context_today, required=True)
    due_date = fields.Date(string='Due Date', required=True)

    discount_code = fields.Char(string='Discount Code Applied')
    discount_amount = fields.Float(string='Discount Amount', default=0.0)

    subtotal = fields.Float(string='Subtotal', compute='_compute_totals', store=True)
    taxable_amount = fields.Float(string='Taxable Amount', compute='_compute_totals', store=True)
    is_inter_state = fields.Boolean(string='Inter-State', compute='_compute_totals', store=True)
    cgst_rate = fields.Float(string='CGST Rate (%)', compute='_compute_totals', store=True)
    cgst_amount = fields.Float(string='CGST Amount', compute='_compute_totals', store=True)
    sgst_rate = fields.Float(string='SGST Rate (%)', compute='_compute_totals', store=True)
    sgst_amount = fields.Float(string='SGST Amount', compute='_compute_totals', store=True)
    igst_rate = fields.Float(string='IGST Rate (%)', compute='_compute_totals', store=True)
    igst_amount = fields.Float(string='IGST Amount', compute='_compute_totals', store=True)
    total_tax = fields.Float(string='Total Tax', compute='_compute_totals', store=True)
    total_amount = fields.Float(string='Grand Total', compute='_compute_totals', store=True)

    line_ids = fields.One2many('subscription.invoice.line', 'invoice_id', string='Invoice Lines')
    notes = fields.Text(string='Notes / Terms')

    @api.constrains('subscription_id', 'billing_cycle_start', 'billing_cycle_end', 'status')
    def _check_duplicate_cycle(self):
        """Enforces duplicate invoice prevention for same subscription billing cycle"""
        for record in self:
            if record.subscription_id and record.billing_cycle_start and record.billing_cycle_end and record.status != 'Cancelled':
                duplicates = self.search([
                    ('id', '!=', record.id),
                    ('subscription_id', '=', record.subscription_id),
                    ('billing_cycle_start', '=', record.billing_cycle_start),
                    ('billing_cycle_end', '=', record.billing_cycle_end),
                    ('status', '!=', 'Cancelled')
                ])
                if duplicates:
                    raise ValidationError(
                        f"Duplicate Invoice Error: Invoice '{duplicates[0].name}' already exists "
                        f"for cycle ({record.billing_cycle_start} to {record.billing_cycle_end})."
                    )

    @api.model
    def create(self, vals):
        if vals.get('name', 'New') == 'New':
            year = fields.Date.today().year
            seq = self.search_count([]) + 1
            vals['name'] = f"INV-{year}-{seq:04d}"
        return super(SubscriptionInvoice, self).create(vals)

    @api.depends('line_ids.price_subtotal', 'discount_amount', 'customer_state', 'company_state')
    def _compute_totals(self):
        for rec in self:
            sub = sum(rec.line_ids.mapped('price_subtotal'))
            rec.subtotal = round(sub, 2)
            taxable = max(0.0, round(sub - (rec.discount_amount or 0.0), 2))
            rec.taxable_amount = taxable

            tax_rate = rec.line_ids[0].tax_rate if rec.line_ids else 18.0
            gst = self.env['subscription.tax.rate'].compute_gst(
                taxable, tax_rate, rec.customer_state, rec.company_state
            )
            rec.is_inter_state = gst['is_inter_state']
            rec.cgst_rate = gst['cgst_rate']
            rec.cgst_amount = gst['cgst_amount']
            rec.sgst_rate = gst['sgst_rate']
            rec.sgst_amount = gst['sgst_amount']
            rec.igst_rate = gst['igst_rate']
            rec.igst_amount = gst['igst_amount']
            rec.total_tax = gst['total_tax']
            rec.total_amount = round(taxable + gst['total_tax'], 2)

    def action_post(self):
        for rec in self:
            rec.status = 'Posted'

    def action_paid(self):
        for rec in self:
            rec.status = 'Paid'

    def action_cancel(self):
        for rec in self:
            rec.status = 'Cancelled'


class SubscriptionInvoiceLine(models.Model):
    _name = 'subscription.invoice.line'
    _description = 'Subscription Invoice Line'

    invoice_id = fields.Many2one('subscription.invoice', string='Invoice', ondelete='cascade')
    product_name = fields.Char(string='Product / Plan', required=True)
    quantity = fields.Integer(string='Quantity', default=1, required=True)
    unit_price = fields.Float(string='Unit Price', required=True)
    tax_rate = fields.Float(string='Tax Rate (%)', default=18.0)
    price_subtotal = fields.Float(string='Line Total', compute='_compute_subtotal', store=True)

    @api.depends('quantity', 'unit_price')
    def _compute_subtotal(self):
        for line in self:
            line.price_subtotal = round(line.quantity * line.unit_price, 2)
