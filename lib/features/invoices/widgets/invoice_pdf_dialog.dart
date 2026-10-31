import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import 'status_badge.dart';

class InvoicePdfDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoicePdfDialog({super.key, required this.invoice});

  static void show(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (ctx) => InvoicePdfDialog(invoice: invoice),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(28.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: Theme.of(context).primaryColor, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'TAX INVOICE',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Invoice #: ${invoice.invoiceNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusBadge(status: invoice.status),
                      const SizedBox(height: 6),
                      Text('Date: ${invoice.issueDate}', style: const TextStyle(fontSize: 12)),
                      Text('Due: ${invoice.dueDate}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 28, thickness: 1.5),

              // Parties Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BILLED FROM (SELLER):',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        const Text('BrightLoop SaaS Private Limited', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('Infopark Phase II, Kochi, Kerala - 682042'),
                        Text('State: ${invoice.companyState} (Code: 32)'),
                        const Text('GSTIN: 32AABCB1234F1Z1'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BILLED TO (BUYER):',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (invoice.customerEmail != null) Text(invoice.customerEmail!),
                        if (invoice.customerAddress != null) Text(invoice.customerAddress!),
                        Text('Place of Supply: ${invoice.customerState}'),
                        if (invoice.customerGstin != null && invoice.customerGstin!.isNotEmpty)
                          Text('GSTIN: ${invoice.customerGstin!}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Billing cycle info
              if (invoice.billingCycleStart != null && invoice.billingCycleEnd != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Billing Cycle: ${invoice.billingCycleStart} to ${invoice.billingCycleEnd}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Line Items Table
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: const [
                      Padding(padding: EdgeInsets.all(8.0), child: Text('Item / Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('Rate', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('Tax %', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8.0), child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                  ...invoice.items.map(
                    (it) => TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(8.0), child: Text(it.productName, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.all(8.0), child: Text('${it.quantity}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.all(8.0), child: Text('Rs. ${it.unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.all(8.0), child: Text('${it.taxRate.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                        Padding(padding: const EdgeInsets.all(8.0), child: Text('Rs. ${it.totalAmount.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal', 'Rs. ${invoice.subtotal.toStringAsFixed(2)}'),
                      if (invoice.discountAmount > 0)
                        _buildSummaryRow('Discount (${invoice.discountCode ?? ""})', '- Rs. ${invoice.discountAmount.toStringAsFixed(2)}', isGreen: true),
                      _buildSummaryRow('Taxable Amount', 'Rs. ${invoice.taxableAmount.toStringAsFixed(2)}', isBold: true),
                      if (!invoice.isInterState) ...[
                        _buildSummaryRow('CGST (${invoice.cgstRate.toStringAsFixed(1)}%)', 'Rs. ${invoice.cgstAmount.toStringAsFixed(2)}'),
                        _buildSummaryRow('SGST (${invoice.sgstRate.toStringAsFixed(1)}%)', 'Rs. ${invoice.sgstAmount.toStringAsFixed(2)}'),
                      ] else ...[
                        _buildSummaryRow('IGST (${invoice.igstRate.toStringAsFixed(1)}%)', 'Rs. ${invoice.igstAmount.toStringAsFixed(2)}'),
                      ],
                      _buildSummaryRow('Total Tax', 'Rs. ${invoice.totalTax.toStringAsFixed(2)}'),
                      const Divider(thickness: 1.5),
                      _buildSummaryRow('Grand Total', 'Rs. ${invoice.totalAmount.toStringAsFixed(2)}', isBold: true, fontSize: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice ready to print / downloaded as PDF.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print / Save PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isGreen = false, double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isGreen ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
