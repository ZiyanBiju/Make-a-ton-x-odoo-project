{
    'name': 'Member 1 - User and Product Management',
    'version': '1.0.0',
    'category': 'Administration',
    'summary': 'User management and product management for Subscription Management System',
    'description': """
        Member 1 module for Subscription Management System.

        Features:
        - Customer user management
        - User roles
        - Customer profiles
        - Product management
        - Product variants
    """,
    'depends': ['base', 'product', 'sale'],
    'data': [
        'views/res_partner_views.xml',
    ],
    'installable': True,
    'application': True,
    'license': 'LGPL-3',
}