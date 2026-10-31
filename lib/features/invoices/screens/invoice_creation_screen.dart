import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_provider.dart';
import '../providers/discount_provider.dart';
import '../providers/tax_provider.dart';
import '../models/invoice_model.dart';
import '../widgets/tax_breakdown_card.dart';

class InvoiceCreationScreen extends ConsumerStatefulWidget {
  const InvoiceCreationScreen({super.key});

  @override
  ConsumerState<InvoiceCreationScreen> createState() =>
      _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends ConsumerState<InvoiceCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Mode: From Subscription vs Manual
  bool _isFromSubscription = false;
  AvailableSubscription? _selectedSubscription;

  // Customer Details
  final TextEditingController _customerNameController =
      TextEditingController(text: 'Acme SaaS Enterprise');
  final TextEditingController _customerEmailController =
      TextEditingController(text: 'finance@acme.io');
  final TextEditingController _customerGstinController =
      TextEditingController(text: '32AABCA1234F1Z9');
  final TextEditingController _customerAddressController =
      TextEditingController(text: 'Cyber Towers, Infopark, Kochi');
  String _customerState = 'Kerala'; // Default Kerala (Intra-state)
  final String _companyState = 'Kerala';

  // Dates & Notes
  final TextEditingController _cycleStartController =
      TextEditingController(text: '2026-10-01');
  final TextEditingController _cycleEndController =
      TextEditingController(text: '2026-10-31');
  final TextEditingController _notesController = TextEditingController();
  bool _autoPost = false;

  // Discount
  final TextEditingController _discountCodeController =
      TextEditingController();
  String? _appliedDiscountCode;
  double _appliedDiscountAmount = 0.0;
  String? _discountValidationMessage;
  bool _isDiscountValid = false;

  // Line items
  final List<_EditableItem> _items = [
    _EditableItem(
      productName: 'Professional Cloud Subscription',
      quantity: 1,
      unitPrice: 5000.0,
      taxRate: 18.0,
    ),
  ];

  final List<String> _indianStates = [
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
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerGstinController.dispose();
    _customerAddressController.dispose();
    _cycleStartController.dispose();
    _cycleEndController.dispose();
    _notesController.dispose();
    _discountCodeController.dispose();
    super.dispose();
  }

  double get _subtotal {
    double sum = 0.0;
    for (var it in _items) {
      sum += (it.quantity * it.unitPrice);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  int get _totalQuantity {
    int sum = 0;
    for (var it in _items) {
      sum += it.quantity;
    }
    return sum;
  }

  bool get _isInterState {
    return _customerState.trim().toLowerCase() !=
        _companyState.trim().toLowerCase();
  }

  double get _taxableAmount {
    return (_subtotal - _appliedDiscountAmount).clamp(0.0, double.infinity);
  }

  double get _taxRate {
    if (_items.isEmpty) return 18.0;
    return _items.first.taxRate;
  }

  double get _cgstRate => _isInterState ? 0.0 : (_taxRate / 2.0);
  double get _sgstRate => _isInterState ? 0.0 : (_taxRate / 2.0);
  double get _igstRate => _isInterState ? _taxRate : 0.0;

  double get _cgstAmount =>
      double.parse((_taxableAmount * (_cgstRate / 100.0)).toStringAsFixed(2));
  double get _sgstAmount =>
      double.parse((_taxableAmount * (_sgstRate / 100.0)).toStringAsFixed(2));
  double get _igstAmount =>
      double.parse((_taxableAmount * (_igstRate / 100.0)).toStringAsFixed(2));

  double get _totalTax => _isInterState
      ? _igstAmount
      : double.parse((_cgstAmount + _sgstAmount).toStringAsFixed(2));

  double get _totalAmount =>
      double.parse((_taxableAmount + _totalTax).toStringAsFixed(2));

  void _onSubscriptionSelected(AvailableSubscription sub) {
    setState(() {
      _selectedSubscription = sub;
      _customerNameController.text = sub.customerName;
      _customerEmailController.text = sub.customerEmail ?? '';
      _customerState = sub.customerState;
      _customerGstinController.text = sub.customerGstin ?? '';
      _customerAddressController.text = sub.customerAddress ?? '';
      _cycleStartController.text = sub.billingCycleStart;
      _cycleEndController.text = sub.billingCycleEnd;

      _items.clear();
      _items.add(_EditableItem(
        productName: sub.planName,
        quantity: sub.quantity,
        unitPrice: sub.unitPrice,
        taxRate: sub.defaultTaxRate,
      ));

      _appliedDiscountCode = null;
      _appliedDiscountAmount = 0.0;
      _discountCodeController.clear();
      _discountValidationMessage = null;
    });
  }

  Future<void> _validateDiscount() async {
    final code = _discountCodeController.text.trim();
    if (code.isEmpty) return;

    final discNotifier = ref.read(discountProvider.notifier);
    final res = await discNotifier.validateCoupon(
      code: code,
      subtotal: _subtotal,
      totalQuantity: _totalQuantity,
    );

    setState(() {
      _isDiscountValid = res.isValid;
      _discountValidationMessage = res.message;
      if (res.isValid) {
        _appliedDiscountCode = res.discountCode;
        _appliedDiscountAmount = res.discountAmount;
      } else {
        _appliedDiscountCode = null;
        _appliedDiscountAmount = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);
    final notifier = ref.read(invoiceProvider.notifier);
    final taxState = ref.watch(taxProvider);
    final theme = Theme.of(context);

    final readySubs = invoiceState.availableSubscriptions
        .where((s) => !s.hasInvoice)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Invoice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode Switcher: Manual vs Generate from Member 2 Subscription
              Card(
                elevation: 0,
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.handshake, color: Colors.blue.shade800),
                          const SizedBox(width: 8),
                          Text(
                            'Invoice Source Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Manual Invoice'),
                            icon: Icon(Icons.edit_note),
                          ),
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('From Subscription (Member 2)'),
                            icon: Icon(Icons.sync_alt),
                          ),
                        ],
                        selected: {_isFromSubscription},
                        onSelectionChanged: (val) {
                          setState(() {
                            _isFromSubscription = val.first;
                          });
                        },
                      ),
                      if (_isFromSubscription) ...[
                        const SizedBox(height: 12),
                        const Text(
                          'Select Active Subscription from Member 2:',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        if (readySubs.isEmpty)
                          const Text(
                            'No pending subscriptions. All have invoices generated!',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        else
                          DropdownButtonFormField<AvailableSubscription>(
                            value: _selectedSubscription,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              isDense: true,
                            ),
                            items: readySubs.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  '${s.subscriptionCode} - ${s.customerName} (Rs. ${s.unitPrice.toStringAsFixed(0)})',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: (sub) {
                              if (sub != null) _onSubscriptionSelected(sub);
                            },
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Customer Details Card
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
                      Text('Customer Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                      const Divider(height: 20),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer / Company Name *',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Customer name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customerEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _customerState,
                              decoration: const InputDecoration(
                                labelText: 'Place of Supply (State) *',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: _indianStates.map((st) {
                                return DropdownMenuItem(
                                    value: st, child: Text(st));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _customerState = val;
                                  });
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
                              controller: _customerGstinController,
                              decoration: const InputDecoration(
                                labelText: 'GSTIN (Optional)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _customerAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Billing Address',
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

              const SizedBox(height: 16),

              // Billing Cycle & Dates Card
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
                          Text('Billing Cycle & Dates',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shield,
                                    size: 13, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Duplicate Cycle Protected',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cycleStartController,
                              decoration: const InputDecoration(
                                labelText: 'Cycle Start (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cycleEndController,
                              decoration: const InputDecoration(
                                labelText: 'Cycle End (YYYY-MM-DD)',
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

              const SizedBox(height: 16),

              // Line Items Card
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
                          Text('Invoice Line Items',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _items.add(_EditableItem(
                                  productName: 'Additional Service / Add-on',
                                  quantity: 1,
                                  unitPrice: 1000.0,
                                  taxRate: 18.0,
                                ));
                              });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (context, index) => const Divider(height: 20),
                        itemBuilder: (context, idx) {
                          final item = _items[idx];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: item.productName,
                                  decoration: const InputDecoration(
                                    labelText: 'Product / Plan Name',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (val) => item.productName = val,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  initialValue: '${item.quantity}',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Qty',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      item.quantity =
                                          int.tryParse(val) ?? item.quantity;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: '${item.unitPrice}',
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Unit Price',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      item.unitPrice =
                                          double.tryParse(val) ?? item.unitPrice;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<double>(
                                  value: item.taxRate,
                                  decoration: const InputDecoration(
                                    labelText: 'Tax %',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: taxState.rates.map((tr) {
                                    return DropdownMenuItem(
                                      value: tr.rate,
                                      child: Text('${tr.rate.toStringAsFixed(0)}%'),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        item.taxRate = val;
                                      });
                                    }
                                  },
                                ),
                              ),
                              if (_items.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _items.removeAt(idx);
                                    });
                                  },
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

              // Discount Code Application Card
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
                        children: [
                          Icon(Icons.local_offer, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          Text('Apply Discount Coupon',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _discountCodeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'e.g. WELCOME10, FLAT200',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.tonal(
                            onPressed: _validateDiscount,
                            child: const Text('Validate & Apply'),
                          ),
                        ],
                      ),
                      if (_discountValidationMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _discountValidationMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isDiscountValid
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Live Real-Time Tax & Calculations Breakdown
              TaxBreakdownCard(
                subtotal: _subtotal,
                discountAmount: _appliedDiscountAmount,
                discountCode: _appliedDiscountCode,
                taxableAmount: _taxableAmount,
                isInterState: _isInterState,
                cgstRate: _cgstRate,
                cgstAmount: _cgstAmount,
                sgstRate: _sgstRate,
                sgstAmount: _sgstAmount,
                igstRate: _igstRate,
                igstAmount: _igstAmount,
                totalTax: _totalTax,
                totalAmount: _totalAmount,
                customerState: _customerState,
                companyState: _companyState,
              ),

              const SizedBox(height: 16),

              // Additional Options
              CheckboxListTile(
                value: _autoPost,
                onChanged: (val) => setState(() => _autoPost = val ?? false),
                title: const Text('Post Invoice Immediately (Active Status)'),
                subtitle: const Text(
                    'If unchecked, invoice will be saved as Draft for review.'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 20),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => _submitInvoice(context, notifier),
                  icon: const Icon(Icons.check),
                  label: Text(
                    _autoPost ? 'Create & Post Invoice' : 'Save Invoice as Draft',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitInvoice(
      BuildContext context, InvoiceNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add at least one line item.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final rawItems = _items
        .map((it) => {
              'product_id': 'prod-${DateTime.now().millisecondsSinceEpoch}',
              'product_name': it.productName,
              'quantity': it.quantity,
              'unit_price': it.unitPrice,
              'tax_rate': it.taxRate,
            })
        .toList();

    final inv = await notifier.createInvoice(
      subscriptionId: _isFromSubscription ? _selectedSubscription?.id : null,
      billingCycleStart: _cycleStartController.text.trim(),
      billingCycleEnd: _cycleEndController.text.trim(),
      customerId: _selectedSubscription?.customerId ??
          'cust-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _customerNameController.text.trim(),
      customerEmail: _customerEmailController.text.trim(),
      customerState: _customerState,
      customerGstin: _customerGstinController.text.trim(),
      customerAddress: _customerAddressController.text.trim(),
      companyState: _companyState,
      discountCode: _appliedDiscountCode,
      items: rawItems,
      autoPost: _autoPost,
      notes: _notesController.text.trim(),
    );

    if (context.mounted) {
      if (inv != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Invoice ${inv.invoiceNumber} created successfully (${inv.status})!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create invoice. Check duplicate cycle error or inputs.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _EditableItem {
  String productName;
  int quantity;
  double unitPrice;
  double taxRate;

  _EditableItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
  });
}
