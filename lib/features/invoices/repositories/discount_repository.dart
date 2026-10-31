import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/discount_model.dart';

class DiscountRepository {
  final Dio _dio;

  DiscountRepository({Dio? dio}) : _dio = dio ?? _createConfiguredDio();

  static Dio _createConfiguredDio() {
    final client = ApiClient();
    client.dio.options.baseUrl = 'http://127.0.0.1:8000';
    return client.dio;
  }

  Future<List<Discount>> getDiscounts() async {
    final response = await _dio.get('/api/discounts');
    final List<dynamic> data = response.data;
    return data.map((json) => Discount.fromJson(json)).toList();
  }

  Future<Discount> createDiscount({
    required String code,
    required String name,
    required String discountType,
    required double value,
    String scope = 'SUBSCRIPTION',
    String? productId,
    double minPurchaseAmount = 0.0,
    int minQuantity = 1,
    String? startDate,
    String? expiryDate,
    int maxUses = 0,
  }) async {
    final response = await _dio.post(
      '/api/discounts',
      data: {
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
      },
    );
    return Discount.fromJson(response.data);
  }

  Future<Discount> updateDiscount(
    String id, {
    String? name,
    double? value,
    double? minPurchaseAmount,
    int? minQuantity,
    String? startDate,
    String? expiryDate,
    int? maxUses,
    bool? isActive,
  }) async {
    final response = await _dio.put(
      '/api/discounts/$id',
      data: {
        if (name != null) 'name': name,
        if (value != null) 'value': value,
        if (minPurchaseAmount != null) 'min_purchase_amount': minPurchaseAmount,
        if (minQuantity != null) 'min_quantity': minQuantity,
        if (startDate != null) 'start_date': startDate,
        if (expiryDate != null) 'expiry_date': expiryDate,
        if (maxUses != null) 'max_uses': maxUses,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return Discount.fromJson(response.data);
  }

  Future<void> deleteDiscount(String id) async {
    await _dio.delete('/api/discounts/$id');
  }

  Future<DiscountValidationResult> validateDiscount({
    required String code,
    required double subtotal,
    int totalQuantity = 1,
    String? productId,
  }) async {
    final response = await _dio.post(
      '/api/discounts/validate',
      data: {
        'code': code,
        'subtotal': subtotal,
        'total_quantity': totalQuantity,
        'product_id': productId,
      },
    );
    return DiscountValidationResult.fromJson(response.data);
  }
}
