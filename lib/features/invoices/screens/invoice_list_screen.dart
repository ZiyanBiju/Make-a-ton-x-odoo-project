import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_provider.dart';
import '../models/invoice_model.dart';
import '../widgets/status_badge.dart';
import 'invoice_details_screen.dart';
import 'invoice_creation_screen.dart';
import 'tax_details_screen.dart';
import 'discount_management_screen.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);
    final theme = Theme.of(context);

    final statuses = ['All', 'Draft', 'Posted', 'Paid', 'Cancelled'];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.receipt_long),
            SizedBox(width: 10),
            Text('Invoice Management'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Tax Configuration & GST Calculator',
            icon: const Icon(Icons.percent),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TaxDetailsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Discount Management & Coupons',
            icon: const Icon(Icons.local_offer_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DiscountManagementScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh Invoices',
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refreshAll(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refreshAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top KPI Summary Cards (Member 4 Integration)
              if (invoiceState.metrics != null) _buildMetricsSummary(invoiceState.metrics!, theme),

              const SizedBox(height: 16),

              // Search & Filter Bar
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by invoice #, customer name, email...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.setSearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => notifier.setSearch(val),
                      ),
                      const Divider(height: 16),
                      // Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: statuses.map((status) {
                            final isSelected = invoiceState.statusFilter == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    notifier.setFilter(status);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Error notification if any
              if (invoiceState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          invoiceState.errorMessage!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Available Subscriptions Alert Banner (Integration with Member 2)
              if (invoiceState.availableSubscriptions.any((s) => !s.hasInvoice))
                _buildAvailableSubscriptionBanner(invoiceState.availableSubscriptions, context, notifier),

              const SizedBox(height: 8),

              // Invoices Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Invoices (${invoiceState.invoices.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (invoiceState.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Invoices List
              if (invoiceState.invoices.isEmpty && !invoiceState.isLoading)
                _buildEmptyState(context)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoiceState.invoices.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final invoice = invoiceState.invoices[index];
                    return _buildInvoiceCard(context, invoice, theme);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const InvoiceCreationScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Invoice'),
      ),
    );
  }

  Widget _buildMetricsSummary(InvoiceMetrics metrics, ThemeData theme) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;
      return GridView.count(
        crossAxisCount: isWide ? 4 : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: isWide ? 2.2 : 2.0,
        children: [
          _buildMetricTile(
            title: 'Total Invoiced',
            value: 'Rs. ${metrics.totalInvoicedAmount.toStringAsFixed(0)}',
            subtitle: '${metrics.totalInvoices} Invoices',
            color: Colors.blue.shade700,
            icon: Icons.receipt,
          ),
          _buildMetricTile(
            title: 'Total Paid',
            value: 'Rs. ${metrics.totalPaidAmount.toStringAsFixed(0)}',
            subtitle: '${metrics.paidCount} Paid',
            color: Colors.green.shade700,
            icon: Icons.check_circle,
          ),
          _buildMetricTile(
            title: 'Outstanding (Posted)',
            value: 'Rs. ${metrics.totalOutstandingAmount.toStringAsFixed(0)}',
            subtitle: '${metrics.postedCount} Pending',
            color: Colors.orange.shade800,
            icon: Icons.hourglass_top,
          ),
          _buildMetricTile(
            title: 'Total GST Collected',
            value: 'Rs. ${metrics.totalTaxCollected.toStringAsFixed(0)}',
            subtitle: 'CGST+SGST / IGST',
            color: Colors.purple.shade700,
            icon: Icons.account_balance,
          ),
        ],
      );
    });
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSubscriptionBanner(
    List<AvailableSubscription> subs,
    BuildContext context,
    InvoiceNotifier notifier,
  ) {
    final readySubs = subs.where((s) => !s.hasInvoice).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_mode, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(
                'Member 2 Integration: ${readySubs.length} Active Subscription(s) Ready to Bill',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Select a subscription to automatically generate a unique GST invoice with duplicate cycle protection.',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: readySubs.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    avatar: const Icon(Icons.flash_on, size: 16, color: Colors.indigo),
                    label: Text('${s.subscriptionCode} - ${s.customerName}'),
                    onPressed: () async {
                      final inv = await notifier.generateFromSubscription(s.id);
                      if (context.mounted && inv != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Generated ${inv.invoiceNumber} successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InvoiceDetailsScreen(invoiceId: inv.id),
                          ),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InvoiceDetailsScreen(invoiceId: invoice.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.receipt_outlined, color: theme.colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Issued: ${invoice.issueDate}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  StatusBadge(status: invoice.status),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Place of Supply: ${invoice.customerState} (${invoice.isInterState ? "IGST" : "CGST+SGST"})',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        if (invoice.discountAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Discount: -Rs. ${invoice.discountAmount.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      Text(
                        'Rs. ${invoice.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No Invoices Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate an invoice from Member 2 subscriptions or create a new custom invoice.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InvoiceCreationScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create First Invoice'),
            ),
          ],
        ),
      ),
    );
  }
}
