class InvoiceItem {
  final String id;
  final String invoiceId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxableAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.taxableAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
    };
  }
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String? subscriptionId;
  final String? billingCycleStart;
  final String? billingCycleEnd;
  final String customerId;
  final String customerName;
  final String? customerEmail;
  final String customerState;
  final String? customerGstin;
  final String? customerAddress;
  final String companyState;
  final double subtotal;
  final String? discountCode;
  final double discountAmount;
  final double taxableAmount;
  final double taxRate;
  final bool isInterState;
  final double cgstRate;
  final double cgstAmount;
  final double sgstRate;
  final double sgstAmount;
  final double igstRate;
  final double igstAmount;
  final double totalTax;
  final double totalAmount;
  final String status; // 'Draft', 'Posted', 'Cancelled', 'Paid'
  final String issueDate;
  final String dueDate;
  final String? notes;
  final String createdAt;
  final List<InvoiceItem> items;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    this.subscriptionId,
    this.billingCycleStart,
    this.billingCycleEnd,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    required this.customerState,
    this.customerGstin,
    this.customerAddress,
    required this.companyState,
    required this.subtotal,
    this.discountCode,
    required this.discountAmount,
    required this.taxableAmount,
    required this.taxRate,
    required this.isInterState,
    required this.cgstRate,
    required this.cgstAmount,
    required this.sgstRate,
    required this.sgstAmount,
    required this.igstRate,
    required this.igstAmount,
    required this.totalTax,
    required this.totalAmount,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      subscriptionId: json['subscription_id'],
      billingCycleStart: json['billing_cycle_start'],
      billingCycleEnd: json['billing_cycle_end'],
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'],
      customerState: json['customer_state'] ?? '',
      customerGstin: json['customer_gstin'],
      customerAddress: json['customer_address'],
      companyState: json['company_state'] ?? 'Kerala',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountCode: json['discount_code'],
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      isInterState: json['is_inter_state'] == true || json['is_inter_state'] == 1,
      cgstRate: (json['cgst_rate'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgst_amount'] as num?)?.toDouble() ?? 0.0,
      sgstRate: (json['sgst_rate'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgst_amount'] as num?)?.toDouble() ?? 0.0,
      igstRate: (json['igst_rate'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igst_amount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Draft',
      issueDate: json['issue_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class AvailableSubscription {
  final String id;
  final String subscriptionCode;
  final String customerId;
  final String customerName;
  final String? customerEmail;
  final String customerState;
  final String? customerGstin;
  final String? customerAddress;
  final String planName;
  final String billingCycleStart;
  final String billingCycleEnd;
  final double unitPrice;
  final int quantity;
  final double defaultTaxRate;
  final String status;
  final bool hasInvoice;

  AvailableSubscription({
    required this.id,
    required this.subscriptionCode,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    required this.customerState,
    this.customerGstin,
    this.customerAddress,
    required this.planName,
    required this.billingCycleStart,
    required this.billingCycleEnd,
    required this.unitPrice,
    required this.quantity,
    required this.defaultTaxRate,
    required this.status,
    required this.hasInvoice,
  });

  factory AvailableSubscription.fromJson(Map<String, dynamic> json) {
    return AvailableSubscription(
      id: json['id'] ?? '',
      subscriptionCode: json['subscription_code'] ?? '',
      customerId: json['customer_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'],
      customerState: json['customer_state'] ?? '',
      customerGstin: json['customer_gstin'],
      customerAddress: json['customer_address'],
      planName: json['plan_name'] ?? '',
      billingCycleStart: json['billing_cycle_start'] ?? '',
      billingCycleEnd: json['billing_cycle_end'] ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      defaultTaxRate: (json['default_tax_rate'] as num?)?.toDouble() ?? 18.0,
      status: json['status'] ?? 'ACTIVE',
      hasInvoice: json['has_invoice'] == true,
    );
  }
}

class InvoiceMetrics {
  final int totalInvoices;
  final int draftCount;
  final int postedCount;
  final int paidCount;
  final int cancelledCount;
  final double totalInvoicedAmount;
  final double totalPaidAmount;
  final double totalOutstandingAmount;
  final double totalTaxCollected;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalDiscountsGiven;

  InvoiceMetrics({
    required this.totalInvoices,
    required this.draftCount,
    required this.postedCount,
    required this.paidCount,
    required this.cancelledCount,
    required this.totalInvoicedAmount,
    required this.totalPaidAmount,
    required this.totalOutstandingAmount,
    required this.totalTaxCollected,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalDiscountsGiven,
  });

  factory InvoiceMetrics.fromJson(Map<String, dynamic> json) {
    return InvoiceMetrics(
      totalInvoices: (json['total_invoices'] as num?)?.toInt() ?? 0,
      draftCount: (json['draft_count'] as num?)?.toInt() ?? 0,
      postedCount: (json['posted_count'] as num?)?.toInt() ?? 0,
      paidCount: (json['paid_count'] as num?)?.toInt() ?? 0,
      cancelledCount: (json['cancelled_count'] as num?)?.toInt() ?? 0,
      totalInvoicedAmount: (json['total_invoiced_amount'] as num?)?.toDouble() ?? 0.0,
      totalPaidAmount: (json['total_paid_amount'] as num?)?.toDouble() ?? 0.0,
      totalOutstandingAmount: (json['total_outstanding_amount'] as num?)?.toDouble() ?? 0.0,
      totalTaxCollected: (json['total_tax_collected'] as num?)?.toDouble() ?? 0.0,
      totalCgst: (json['total_cgst'] as num?)?.toDouble() ?? 0.0,
      totalSgst: (json['total_sgst'] as num?)?.toDouble() ?? 0.0,
      totalIgst: (json['total_igst'] as num?)?.toDouble() ?? 0.0,
      totalDiscountsGiven: (json['total_discounts_given'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
