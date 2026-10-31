import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/discount_provider.dart';
import '../models/discount_model.dart';

class DiscountManagementScreen extends ConsumerStatefulWidget {
  const DiscountManagementScreen({super.key});

  @override
  ConsumerState<DiscountManagementScreen> createState() =>
      _DiscountManagementScreenState();
}

class _DiscountManagementScreenState
    extends ConsumerState<DiscountManagementScreen> {
  // Test Bench Validator
  final TextEditingController _testCodeCtrl =
      TextEditingController(text: 'WELCOME10');
  final TextEditingController _testSubtotalCtrl =
      TextEditingController(text: '1500');
  final TextEditingController _testQtyCtrl = TextEditingController(text: '1');
  DiscountValidationResult? _testResult;

  @override
  void dispose() {
    _testCodeCtrl.dispose();
    _testSubtotalCtrl.dispose();
    _testQtyCtrl.dispose();
    super.dispose();
  }

  Future<void> _runCouponTest() async {
    final code = _testCodeCtrl.text.trim();
    final subtotal = double.tryParse(_testSubtotalCtrl.text.trim()) ?? 0.0;
    final qty = int.tryParse(_testQtyCtrl.text.trim()) ?? 1;

    final notifier = ref.read(discountProvider.notifier);
    final res = await notifier.validateCoupon(
      code: code,
      subtotal: subtotal,
      totalQuantity: qty,
    );
    setState(() {
      _testResult = res;
    });
  }

  void _showCreateDiscountDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    final minPurchCtrl = TextEditingController(text: '500');
    final minQtyCtrl = TextEditingController(text: '1');
    final maxUsesCtrl = TextEditingController(text: '100');
    final startCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    final expiryCtrl = TextEditingController(
        text: DateTime.now()
            .add(const Duration(days: 60))
            .toIso8601String()
            .substring(0, 10));

    String discType = 'PERCENTAGE';
    String scope = 'SUBSCRIPTION';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.local_offer, color: Colors.orange),
                SizedBox(width: 8),
                Text('Create Discount Rule'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: codeCtrl,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                labelText: 'Coupon Code *',
                                hintText: 'e.g. FLASH25',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Code is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: discType,
                              decoration: const InputDecoration(
                                labelText: 'Discount Type *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'PERCENTAGE',
                                    child: Text('Percentage (%)')),
                                DropdownMenuItem(
                                    value: 'FIXED',
                                    child: Text('Fixed Amount (Rs.)')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => discType = val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Promotion Name *',
                                hintText: 'e.g. 25% Flash Discount',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Name is required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: valCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: discType == 'PERCENTAGE'
                                    ? 'Value (% Off) *'
                                    : 'Value (Rs. Off) *',
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              validator: (v) => v == null ||
                                      double.tryParse(v) == null
                                  ? 'Enter valid number'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: scope,
                              decoration: const InputDecoration(
                                labelText: 'Scope *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'SUBSCRIPTION',
                                    child: Text('Subscription-Wide')),
                                DropdownMenuItem(
                                    value: 'PRODUCT',
                                    child: Text('Product-Specific')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => scope = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: maxUsesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Uses (0 = unlimited)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: minPurchCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min Purchase (Rs.)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: minQtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min Quantity',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: startCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Start Date (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: expiryCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Expiry Date (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final code = codeCtrl.text.trim().toUpperCase();
                    final name = nameCtrl.text.trim();
                    final val = double.parse(valCtrl.text.trim());
                    final minP =
                        double.tryParse(minPurchCtrl.text.trim()) ?? 0.0;
                    final minQ = int.tryParse(minQtyCtrl.text.trim()) ?? 1;
                    final maxU = int.tryParse(maxUsesCtrl.text.trim()) ?? 0;

                    final success =
                        await ref.read(discountProvider.notifier).createDiscount(
                              code: code,
                              name: name,
                              discountType: discType,
                              value: val,
                              scope: scope,
                              minPurchaseAmount: minP,
                              minQuantity: minQ,
                              maxUses: maxU,
                              startDate: startCtrl.text.trim().isNotEmpty
                                  ? '${startCtrl.text.trim()}T00:00:00'
                                  : null,
                              expiryDate: expiryCtrl.text.trim().isNotEmpty
                                  ? '${expiryCtrl.text.trim()}T23:59:59'
                                  : null,
                            );
                    if (ctx.mounted) {
                      if (success) {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Discount $code created!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text('Save Discount'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discState = ref.watch(discountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Management'),
        actions: [
          IconButton(
            tooltip: 'Create Discount',
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDiscountDialog(context),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(discountProvider.notifier).fetchDiscounts(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discount Rules Validation Simulator
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Discount Eligibility Test Bench',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.verified_outlined,
                            color: Colors.orange),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _testCodeCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Coupon Code',
                              hintText: 'e.g. WELCOME10',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _testSubtotalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Order Subtotal (Rs.)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _testQtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _runCouponTest,
                          child: const Text('Test'),
                        ),
                      ],
                    ),
                    if (_testResult != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _testResult!.isValid
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _testResult!.isValid
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _testResult!.isValid
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: _testResult!.isValid
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _testResult!.isValid
                                        ? 'ELIGIBLE: ${_testResult!.discountName ?? _testResult!.discountCode}'
                                        : 'INELIGIBLE: ${_testResult!.discountCode}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _testResult!.isValid
                                          ? Colors.green.shade900
                                          : Colors.red.shade900,
                                    ),
                                  ),
                                  Text(
                                    _testResult!.message,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _testResult!.isValid
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_testResult!.isValid)
                              Text(
                                '- Rs. ${_testResult!.discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Existing Discounts List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configured Discounts & Offers (${discState.discounts.length})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _showCreateDiscountDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('New Discount'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (discState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: discState.discounts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final d = discState.discounts[idx];
                  return _buildDiscountCard(d, theme);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountCard(Discount d, ThemeData theme) {
    Color badgeBg;
    Color badgeFg;

    switch (d.statusLabel.toLowerCase()) {
      case 'active':
        badgeBg = Colors.green.shade50;
        badgeFg = Colors.green.shade800;
        break;
      case 'expired':
        badgeBg = Colors.red.shade50;
        badgeFg = Colors.red.shade800;
        break;
      case 'exhausted':
        badgeBg = Colors.purple.shade50;
        badgeFg = Colors.purple.shade800;
        break;
      default:
        badgeBg = Colors.grey.shade100;
        badgeFg = Colors.grey.shade700;
        break;
    }

    final isPercent = d.discountType == 'PERCENTAGE';
    final valStr =
        isPercent ? '${d.value.toStringAsFixed(0)}%' : 'Rs. ${d.value.toStringAsFixed(0)}';

    return Card(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        d.code,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$valStr OFF',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    d.statusLabel.toUpperCase(),
                    style: TextStyle(
                      color: badgeFg,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              d.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Scope: ${d.scope} | Min Purchase: Rs. ${d.minPurchaseAmount.toStringAsFixed(0)} | Min Qty: ${d.minQuantity}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Usage: ${d.usedCount} / ${d.maxUses == 0 ? "Unlimited" : d.maxUses}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
                if (d.expiryDate != null)
                  Text(
                    'Expires: ${d.expiryDate!.substring(0, 10)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
