import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tax_provider.dart';
import '../models/tax_model.dart';

class TaxDetailsScreen extends ConsumerStatefulWidget {
  const TaxDetailsScreen({super.key});

  @override
  ConsumerState<TaxDetailsScreen> createState() => _TaxDetailsScreenState();
}

class _TaxDetailsScreenState extends ConsumerState<TaxDetailsScreen> {
  // Live Calculator State
  final TextEditingController _calcAmountController =
      TextEditingController(text: '10000');
  double _calcRate = 18.0;
  String _buyerState = 'Karnataka';
  final String _sellerState = 'Kerala';
  TaxCalculationResult? _calcResult;

  final List<String> _states = [
    'Kerala',
    'Karnataka',
    'Tamil Nadu',
    'Maharashtra',
    'Delhi',
    'Telangana',
    'Gujarat',
    'Uttar Pradesh',
    'West Bengal',
    'Andhra Pradesh',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _runCalculation());
  }

  @override
  void dispose() {
    _calcAmountController.dispose();
    super.dispose();
  }

  Future<void> _runCalculation() async {
    final amount = double.tryParse(_calcAmountController.text) ?? 0.0;
    final repo = ref.read(taxRepositoryProvider);
    try {
      final res = await repo.calculateTax(
        taxableAmount: amount,
        taxRate: _calcRate,
        customerState: _buyerState,
        companyState: _sellerState,
      );
      setState(() {
        _calcResult = res;
      });
    } catch (e) {
      // Fallback local calculation
      final isInter = _buyerState.toLowerCase() != _sellerState.toLowerCase();
      final cgstR = isInter ? 0.0 : _calcRate / 2.0;
      final sgstR = isInter ? 0.0 : _calcRate / 2.0;
      final igstR = isInter ? _calcRate : 0.0;
      final cgstA = amount * (cgstR / 100.0);
      final sgstA = amount * (sgstR / 100.0);
      final igstA = amount * (igstR / 100.0);
      final totTax = isInter ? igstA : (cgstA + sgstA);

      setState(() {
        _calcResult = TaxCalculationResult(
          taxableAmount: amount,
          taxRate: _calcRate,
          isInterState: isInter,
          customerState: _buyerState,
          companyState: _sellerState,
          cgstRate: cgstR,
          cgstAmount: cgstA,
          sgstRate: sgstR,
          sgstAmount: sgstA,
          igstRate: igstR,
          igstAmount: igstA,
          totalTax: totTax,
          finalAmount: amount + totTax,
        );
      });
    }
  }

  void _showAddTaxDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final rateCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New GST Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tax Rate Name *',
                hintText: 'e.g. GST 15% (Special)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rate Percentage (%) *',
                hintText: 'e.g. 15.0',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final rate = double.tryParse(rateCtrl.text.trim());
              if (name.isNotEmpty && rate != null) {
                await ref.read(taxProvider.notifier).addRate(
                      name: name,
                      rate: rate,
                      description: descCtrl.text.trim(),
                    );
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taxState = ref.watch(taxProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Management (GST)'),
        actions: [
          IconButton(
            tooltip: 'Add GST Rate',
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaxDialog(context),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(taxProvider.notifier).fetchRates(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GST Law Explanation Banner
            Card(
              elevation: 0,
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.teal.shade200),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.gavel, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Indian GST Calculation Architecture',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Intra-State (Seller & Buyer in same state e.g. Kerala): Split equally into CGST (50%) + SGST (50%).\n'
                      '• Inter-State (Seller in Kerala & Buyer in Karnataka): Levied completely as IGST (100%).',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Live Interactive GST Simulator
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
                          'Live GST Breakdown Simulator',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.calculate_outlined, color: Colors.teal),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _calcAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Taxable Amount (Rs.)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (_) => _runCalculation(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<double>(
                            value: _calcRate,
                            decoration: const InputDecoration(
                              labelText: 'GST Rate',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: taxState.rates.map((r) {
                              return DropdownMenuItem(
                                value: r.rate,
                                child: Text('${r.rate.toStringAsFixed(0)}%'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _calcRate = val);
                                _runCalculation();
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
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Seller State (Origin)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            child: Text(_sellerState,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _buyerState,
                            decoration: const InputDecoration(
                              labelText: 'Buyer State (Destination)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _states.map((st) {
                              return DropdownMenuItem(
                                  value: st, child: Text(st));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _buyerState = val);
                                _runCalculation();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_calcResult != null) _buildCalcResultDisplay(_calcResult!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Configured GST Rates List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configured GST Rates (${taxState.rates.length})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _showAddTaxDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Rate'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (taxState.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taxState.rates.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final rate = taxState.rates[idx];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          '${rate.rate.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      title: Text(
                        rate.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        rate.description ?? 'Standard rate tier',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: rate.isActive
                          ? const Chip(
                              label: Text('ACTIVE'),
                              backgroundColor: Color(0xFFE8F5E9),
                              labelStyle: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            )
                          : const Chip(
                              label: Text('DISABLED'),
                              backgroundColor: Color(0xFFFFEBEE),
                              labelStyle: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcResultDisplay(TaxCalculationResult res) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: res.isInterState ? Colors.indigo.shade50 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: res.isInterState
              ? Colors.indigo.shade200
              : Colors.teal.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                res.isInterState
                    ? 'Inter-State Transaction (IGST Applicable)'
                    : 'Intra-State Transaction (CGST + SGST Applicable)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: res.isInterState
                      ? Colors.indigo.shade900
                      : Colors.teal.shade900,
                ),
              ),
              Text(
                'Total: Rs. ${res.finalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          if (!res.isInterState) ...[
            _buildCalcRow('CGST (${res.cgstRate.toStringAsFixed(1)}%)',
                'Rs. ${res.cgstAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            _buildCalcRow('SGST (${res.sgstRate.toStringAsFixed(1)}%)',
                'Rs. ${res.sgstAmount.toStringAsFixed(2)}'),
          ] else ...[
            _buildCalcRow('IGST (${res.igstRate.toStringAsFixed(1)}%)',
                'Rs. ${res.igstAmount.toStringAsFixed(2)}'),
          ],
          const Divider(height: 16),
          _buildCalcRow(
            'Total Tax Amount',
            'Rs. ${res.totalTax.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}
