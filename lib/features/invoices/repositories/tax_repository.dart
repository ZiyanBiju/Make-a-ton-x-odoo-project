import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/tax_model.dart';

class TaxRepository {
  final Dio _dio;

  TaxRepository({Dio? dio}) : _dio = dio ?? _createConfiguredDio();

  static Dio _createConfiguredDio() {
    final client = ApiClient();
    // Default to port 8000 for FastAPI backend, with fallback support
    client.dio.options.baseUrl = 'http://127.0.0.1:8000';
    return client.dio;
  }

  Future<List<TaxRate>> getTaxRates({bool activeOnly = false}) async {
    final response = await _dio.get(
      '/api/taxes',
      queryParameters: {'active_only': activeOnly},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => TaxRate.fromJson(json)).toList();
  }

  Future<TaxRate> createTaxRate({
    required String name,
    required double rate,
    String? description,
    bool isActive = true,
  }) async {
    final response = await _dio.post(
      '/api/taxes',
      data: {
        'name': name,
        'rate': rate,
        'description': description,
        'is_active': isActive,
      },
    );
    return TaxRate.fromJson(response.data);
  }

  Future<TaxRate> updateTaxRate(
    String id, {
    String? name,
    double? rate,
    String? description,
    bool? isActive,
  }) async {
    final response = await _dio.put(
      '/api/taxes/$id',
      data: {
        if (name != null) 'name': name,
        if (rate != null) 'rate': rate,
        if (description != null) 'description': description,
        if (isActive != null) 'is_active': isActive,
      },
    );
    return TaxRate.fromJson(response.data);
  }

  Future<void> deleteTaxRate(String id) async {
    await _dio.delete('/api/taxes/$id');
  }

  Future<TaxCalculationResult> calculateTax({
    required double taxableAmount,
    required double taxRate,
    required String customerState,
    String companyState = 'Kerala',
  }) async {
    final response = await _dio.post(
      '/api/taxes/calculate',
      data: {
        'taxable_amount': taxableAmount,
        'tax_rate': taxRate,
        'customer_state': customerState,
        'company_state': companyState,
      },
    );
    return TaxCalculationResult.fromJson(response.data);
  }
}
