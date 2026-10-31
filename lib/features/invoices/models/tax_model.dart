class TaxRate {
  final String id;
  final String name;
  final double rate;
  final String? description;
  final bool isActive;
  final String createdAt;

  TaxRate({
    required this.id,
    required this.name,
    required this.rate,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory TaxRate.fromJson(Map<String, dynamic> json) {
    return TaxRate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rate': rate,
      'description': description,
      'is_active': isActive,
    };
  }
}

class TaxCalculationResult {
  final double taxableAmount;
  final double taxRate;
  final bool isInterState;
  final String customerState;
  final String companyState;
  final double cgstRate;
  final double cgstAmount;
  final double sgstRate;
  final double sgstAmount;
  final double igstRate;
  final double igstAmount;
  final double totalTax;
  final double finalAmount;

  TaxCalculationResult({
    required this.taxableAmount,
    required this.taxRate,
    required this.isInterState,
    required this.customerState,
    required this.companyState,
    required this.cgstRate,
    required this.cgstAmount,
    required this.sgstRate,
    required this.sgstAmount,
    required this.igstRate,
    required this.igstAmount,
    required this.totalTax,
    required this.finalAmount,
  });

  factory TaxCalculationResult.fromJson(Map<String, dynamic> json) {
    return TaxCalculationResult(
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      isInterState: json['is_inter_state'] == true || json['is_inter_state'] == 1,
      customerState: json['customer_state'] ?? '',
      companyState: json['company_state'] ?? 'Kerala',
      cgstRate: (json['cgst_rate'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgst_amount'] as num?)?.toDouble() ?? 0.0,
      sgstRate: (json['sgst_rate'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgst_amount'] as num?)?.toDouble() ?? 0.0,
      igstRate: (json['igst_rate'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igst_amount'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['total_tax'] as num?)?.toDouble() ?? 0.0,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
