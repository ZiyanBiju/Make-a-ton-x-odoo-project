class Discount {
  final String id;
  final String code;
  final String name;
  final String discountType; // 'PERCENTAGE' or 'FIXED'
  final double value;
  final String scope; // 'SUBSCRIPTION' or 'PRODUCT'
  final String? productId;
  final double minPurchaseAmount;
  final int minQuantity;
  final String? startDate;
  final String? expiryDate;
  final int maxUses;
  final int usedCount;
  final bool isActive;
  final String createdAt;
  final bool isValidNow;
  final String statusLabel;

  Discount({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.value,
    required this.scope,
    this.productId,
    required this.minPurchaseAmount,
    required this.minQuantity,
    this.startDate,
    this.expiryDate,
    required this.maxUses,
    required this.usedCount,
    required this.isActive,
    required this.createdAt,
    this.isValidNow = true,
    this.statusLabel = 'Active',
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      discountType: json['discount_type'] ?? 'PERCENTAGE',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      scope: json['scope'] ?? 'SUBSCRIPTION',
      productId: json['product_id'],
      minPurchaseAmount: (json['min_purchase_amount'] as num?)?.toDouble() ?? 0.0,
      minQuantity: (json['min_quantity'] as num?)?.toInt() ?? 1,
      startDate: json['start_date'],
      expiryDate: json['expiry_date'],
      maxUses: (json['max_uses'] as num?)?.toInt() ?? 0,
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at'] ?? '',
      isValidNow: json['is_valid_now'] == true || json['is_valid_now'] == null,
      statusLabel: json['status_label'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'discount_type': discountType,
      'value': value,
      'scope': scope,
      'product_id': productId,
      'min_purchase_amount': minPurchaseAmount,
      'min_quantity': minQuantity,
      'start_date': startDate,
      'expiry_date': expiryDate,
      'max_uses': maxUses,
    };
  }
}

class DiscountValidationResult {
  final bool isValid;
  final String discountCode;
  final String? discountName;
  final double discountAmount;
  final String? discountType;
  final double? discountValue;
  final String message;

  DiscountValidationResult({
    required this.isValid,
    required this.discountCode,
    this.discountName,
    required this.discountAmount,
    this.discountType,
    this.discountValue,
    required this.message,
  });

  factory DiscountValidationResult.fromJson(Map<String, dynamic> json) {
    return DiscountValidationResult(
      isValid: json['is_valid'] == true,
      discountCode: json['discount_code'] ?? '',
      discountName: json['discount_name'],
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'],
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      message: json['message'] ?? '',
    );
  }
}
