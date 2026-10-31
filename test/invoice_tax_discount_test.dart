import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/invoices/models/tax_model.dart';
import 'package:frontend/features/invoices/models/discount_model.dart';
import 'package:frontend/features/invoices/models/invoice_model.dart';

void main() {
  group('Member 3 Models & GST Calculation Tests', () {
    test('TaxCalculationResult parses intra-state (CGST + SGST) correctly', () {
      final intraJson = {
        'taxable_amount': 1000.0,
        'tax_rate': 18.0,
        'is_inter_state': false,
        'customer_state': 'Kerala',
        'company_state': 'Kerala',
        'cgst_rate': 9.0,
        'cgst_amount': 90.0,
        'sgst_rate': 9.0,
        'sgst_amount': 90.0,
        'igst_rate': 0.0,
        'igst_amount': 0.0,
        'total_tax': 180.0,
        'final_amount': 1180.0,
      };

      final intra = TaxCalculationResult.fromJson(intraJson);
      expect(intra.isInterState, false);
      expect(intra.cgstAmount, 90.0);
      expect(intra.sgstAmount, 90.0);
      expect(intra.igstAmount, 0.0);
      expect(intra.totalTax, 180.0);
      expect(intra.finalAmount, 1180.0);
    });

    test('TaxCalculationResult parses inter-state (IGST) correctly', () {
      final interJson = {
        'taxable_amount': 2000.0,
        'tax_rate': 18.0,
        'is_inter_state': true,
        'customer_state': 'Karnataka',
        'company_state': 'Kerala',
        'cgst_rate': 0.0,
        'cgst_amount': 0.0,
        'sgst_rate': 0.0,
        'sgst_amount': 0.0,
        'igst_rate': 18.0,
        'igst_amount': 360.0,
        'total_tax': 360.0,
        'final_amount': 2360.0,
      };

      final inter = TaxCalculationResult.fromJson(interJson);
      expect(inter.isInterState, true);
      expect(inter.cgstAmount, 0.0);
      expect(inter.sgstAmount, 0.0);
      expect(inter.igstAmount, 360.0);
      expect(inter.totalTax, 360.0);
      expect(inter.finalAmount, 2360.0);
    });

    test('Discount model handles percentage and fixed discount serialization', () {
      final disc = Discount(
        id: 'disc-01',
        code: 'WELCOME10',
        name: '10% Welcome Offer',
        discountType: 'PERCENTAGE',
        value: 10.0,
        scope: 'SUBSCRIPTION',
        minPurchaseAmount: 500.0,
        minQuantity: 1,
        maxUses: 100,
        usedCount: 5,
        isActive: true,
        createdAt: '2026-10-31T00:00:00',
      );

      final json = disc.toJson();
      expect(json['code'], 'WELCOME10');
      expect(json['value'], 10.0);
      expect(json['scope'], 'SUBSCRIPTION');
      expect(json['min_purchase_amount'], 500.0);
      expect(json['max_uses'], 100);
    });

    test('Discount validation response deserialization', () {
      final validJson = {
        'is_valid': true,
        'discount_code': 'FLAT200',
        'discount_name': 'Flat Rs 200 Off',
        'discount_amount': 200.0,
        'discount_type': 'FIXED',
        'discount_value': 200.0,
        'message': 'Discount applied successfully',
      };

      final res = DiscountValidationResult.fromJson(validJson);
      expect(res.isValid, true);
      expect(res.discountAmount, 200.0);
      expect(res.discountCode, 'FLAT200');
    });

    test('Invoice model deserializes line items and duplicate billing cycle info', () {
      final invJson = {
        'id': 'inv-01',
        'invoice_number': 'INV-2026-0001',
        'subscription_id': 'sub-101',
        'billing_cycle_start': '2026-10-01',
        'billing_cycle_end': '2026-10-31',
        'customer_id': 'cust-01',
        'customer_name': 'Infosys Technologies',
        'customer_email': 'accounts@infosys.com',
        'customer_state': 'Karnataka',
        'company_state': 'Kerala',
        'subtotal': 15000.0,
        'discount_code': 'WELCOME10',
        'discount_amount': 1500.0,
        'taxable_amount': 13500.0,
        'tax_rate': 18.0,
        'is_inter_state': true,
        'cgst_rate': 0.0,
        'cgst_amount': 0.0,
        'sgst_rate': 0.0,
        'sgst_amount': 0.0,
        'igst_rate': 18.0,
        'igst_amount': 2430.0,
        'total_tax': 2430.0,
        'total_amount': 15930.0,
        'status': 'Posted',
        'issue_date': '2026-10-31',
        'due_date': '2026-11-15',
        'created_at': '2026-10-31T10:00:00',
        'items': [
          {
            'id': 'item-01',
            'invoice_id': 'inv-01',
            'product_id': 'prod-01',
            'product_name': 'Enterprise Cloud Suite',
            'quantity': 1,
            'unit_price': 15000.0,
            'discount_amount': 1500.0,
            'taxable_amount': 13500.0,
            'tax_rate': 18.0,
            'tax_amount': 2430.0,
            'total_amount': 15930.0,
          }
        ]
      };

      final inv = Invoice.fromJson(invJson);
      expect(inv.invoiceNumber, 'INV-2026-0001');
      expect(inv.subscriptionId, 'sub-101');
      expect(inv.billingCycleStart, '2026-10-01');
      expect(inv.billingCycleEnd, '2026-10-31');
      expect(inv.status, 'Posted');
      expect(inv.isInterState, true);
      expect(inv.totalAmount, 15930.0);
      expect(inv.items.length, 1);
      expect(inv.items.first.productName, 'Enterprise Cloud Suite');
    });

    test('AvailableSubscription parses Member 2 subscription format', () {
      final subJson = {
        'id': 'sub-102',
        'subscription_code': 'SUB-2026-002',
        'customer_id': 'cust-02',
        'customer_name': 'Kochi SmartTech',
        'customer_state': 'Kerala',
        'plan_name': 'Professional SaaS',
        'billing_cycle_start': '2026-10-01',
        'billing_cycle_end': '2026-10-31',
        'unit_price': 4500.0,
        'quantity': 2,
        'default_tax_rate': 18.0,
        'status': 'ACTIVE',
        'has_invoice': false,
      };

      final sub = AvailableSubscription.fromJson(subJson);
      expect(sub.subscriptionCode, 'SUB-2026-002');
      expect(sub.hasInvoice, false);
      expect(sub.unitPrice, 4500.0);
      expect(sub.quantity, 2);
    });

    test('InvoiceMetrics parses Member 4 reporting fields', () {
      final mJson = {
        'total_invoices': 5,
        'draft_count': 1,
        'posted_count': 2,
        'paid_count': 2,
        'cancelled_count': 0,
        'total_invoiced_amount': 50000.0,
        'total_paid_amount': 30000.0,
        'total_outstanding_amount': 20000.0,
        'total_tax_collected': 9000.0,
        'total_cgst': 2250.0,
        'total_sgst': 2250.0,
        'total_igst': 4500.0,
        'total_discounts_given': 5000.0,
      };

      final metrics = InvoiceMetrics.fromJson(mJson);
      expect(metrics.totalInvoices, 5);
      expect(metrics.paidCount, 2);
      expect(metrics.totalPaidAmount, 30000.0);
      expect(metrics.totalTaxCollected, 9000.0);
    });
  });
}
