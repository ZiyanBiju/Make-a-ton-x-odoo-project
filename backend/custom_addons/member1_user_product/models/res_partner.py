from odoo import models, fields


class ResPartner(models.Model):
    _inherit = 'res.partner'

    customer_code = fields.Char(
        string='Customer Code',
        copy=False,
        readonly=True
    )

    customer_category = fields.Selection(
        [
            ('individual', 'Individual'),
            ('business', 'Business'),
        ],
        string='Customer Category',
        default='individual'
    )

    is_subscription_customer = fields.Boolean(
        string='Subscription Customer',
        default=False
    )


