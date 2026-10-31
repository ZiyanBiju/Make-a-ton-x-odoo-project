import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/tax_breakdown_card.dart';
import '../widgets/invoice_pdf_dialog.dart';

class InvoiceDetailsScreen extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends ConsumerState<InvoiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(invoiceProvider.notifier).fetchInvoiceDetails(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);
    final invoice = invoiceState.currentInvoice;
    final theme = Theme.of(context);

    if (invoiceState.isLoading && invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Invoice not found or failed to load.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => notifier.fetchInvoiceDetails(widget.invoiceId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          IconButton(
            tooltip: 'Print / Save PDF Invoice',
            icon: const Icon(Icons.print),
            onPressed: () => InvoicePdfDialog.show(context, invoice),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.fetchInvoiceDetails(widget.invoiceId),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Action Header
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STATUS',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            StatusBadge(status: invoice.status),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TOTAL AMOUNT',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              'Rs. ${invoice.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Lifecycle Status Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (invoice.status == 'Draft') ...[
                          OutlinedButton.icon(
                            onPressed: () => _handleStatusChange(context, notifier, 'Cancelled'),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text('Cancel Invoice', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: () => _handleStatusChange(context, notifier, 'Posted'),
                            icon: const Icon(Icons.send),
                            label: const Text('Post Invoice'),
                          ),
                        ] else if (invoice.status == 'Posted') ...[
                          OutlinedButton.icon(
                            onPressed: () => _handleStatusChange(context, notifier, 'Cancelled'),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _handleStatusChange(context, notifier, 'Paid'),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Mark as Paid (Member 4)'),
                          ),
                        ] else if (invoice.status == 'Paid') ...[
                          const Chip(
                            avatar: Icon(Icons.verified, color: Colors.green, size: 18),
                            label: Text('Payment Completed & Reconciled'),
                            backgroundColor: Color(0xFFE8F5E9),
                          ),
                        ] else if (invoice.status == 'Cancelled') ...[
                          const Chip(
                            avatar: Icon(Icons.block, color: Colors.red, size: 18),
                            label: Text('Invoice Cancelled'),
                            backgroundColor: Color(0xFFFFEBEE),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer & Billing Information
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer & Billing Details',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow('Customer Name', invoice.customerName),
                    if (invoice.customerEmail != null)
                      _buildInfoRow('Email', invoice.customerEmail!),
                    _buildInfoRow('Place of Supply (State)', invoice.customerState),
                    if (invoice.customerGstin != null && invoice.customerGstin!.isNotEmpty)
                      _buildInfoRow('GSTIN', invoice.customerGstin!),
                    if (invoice.customerAddress != null && invoice.customerAddress!.isNotEmpty)
                      _buildInfoRow('Billing Address', invoice.customerAddress!),
                    _buildInfoRow('Issue Date', invoice.issueDate),
                    _buildInfoRow('Due Date', invoice.dueDate),
                    if (invoice.billingCycleStart != null && invoice.billingCycleEnd != null)
                      _buildInfoRow(
                        'Subscription Cycle',
                        '${invoice.billingCycleStart} to ${invoice.billingCycleEnd}',
                        highlight: true,
                      ),
                    if (invoice.notes != null && invoice.notes!.isNotEmpty)
                      _buildInfoRow('Notes', invoice.notes!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Line Items Table
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Line Items (${invoice.items.length})',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoice.items.length,
                      separatorBuilder: (context, index) => const Divider(height: 16),
                      itemBuilder: (context, idx) {
                        final item = invoice.items[idx];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.layers, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty: ${item.quantity} x Rs. ${item.unitPrice.toStringAsFixed(2)} | GST: ${item.taxRate.toStringAsFixed(1)}%',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  if (item.discountAmount > 0)
                                    Text(
                                      'Discount applied: -Rs. ${item.discountAmount.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 11, color: Colors.green.shade700),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${item.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  'Tax: Rs. ${item.taxAmount.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tax & Calculations Breakdown Card
            TaxBreakdownCard(
              subtotal: invoice.subtotal,
              discountAmount: invoice.discountAmount,
              discountCode: invoice.discountCode,
              taxableAmount: invoice.taxableAmount,
              isInterState: invoice.isInterState,
              cgstRate: invoice.cgstRate,
              cgstAmount: invoice.cgstAmount,
              sgstRate: invoice.sgstRate,
              sgstAmount: invoice.sgstAmount,
              igstRate: invoice.igstRate,
              igstAmount: invoice.igstAmount,
              totalTax: invoice.totalTax,
              totalAmount: invoice.totalAmount,
              customerState: invoice.customerState,
              companyState: invoice.companyState,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: highlight ? Colors.indigo : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStatusChange(
    BuildContext context,
    InvoiceNotifier notifier,
    String newStatus,
  ) async {
    final success = await notifier.updateInvoiceStatus(widget.invoiceId, newStatus);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice updated to $newStatus successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update invoice status.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
