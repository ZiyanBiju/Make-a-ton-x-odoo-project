import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final Dio _dio;

  InvoiceRepository({Dio? dio}) : _dio = dio ?? _createConfiguredDio();

  static Dio _createConfiguredDio() {
    final client = ApiClient();
    client.dio.options.baseUrl = 'http://127.0.0.1:8000';
    return client.dio;
  }

  Future<List<Invoice>> getInvoices({
    String? status,
    String? search,
    String? subscriptionId,
  }) async {
    final response = await _dio.get(
      '/api/invoices',
      queryParameters: {
        if (status != null && status != 'All') 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (subscriptionId != null) 'subscription_id': subscriptionId,
      },
    );
    final List<dynamic> data = response.data;
    return data.map((json) => Invoice.fromJson(json)).toList();
  }

  Future<Invoice> getInvoice(String id) async {
    final response = await _dio.get('/api/invoices/$id');
    return Invoice.fromJson(response.data);
  }

  Future<Invoice> createInvoice({
    String? subscriptionId,
    String? billingCycleStart,
    String? billingCycleEnd,
    required String customerId,
    required String customerName,
    String? customerEmail,
    required String customerState,
    String? customerGstin,
    String? customerAddress,
    String companyState = 'Kerala',
    String? discountCode,
    required List<Map<String, dynamic>> items,
    String? issueDate,
    String? dueDate,
    String? notes,
    bool autoPost = false,
  }) async {
    final response = await _dio.post(
      '/api/invoices',
      data: {
        'subscription_id': subscriptionId,
        'billing_cycle_start': billingCycleStart,
        'billing_cycle_end': billingCycleEnd,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_state': customerState,
        'customer_gstin': customerGstin,
        'customer_address': customerAddress,
        'company_state': companyState,
        'discount_code': discountCode,
        'items': items,
        'issue_date': issueDate,
        'due_date': dueDate,
        'notes': notes,
        'auto_post': autoPost,
      },
    );
    return Invoice.fromJson(response.data);
  }

  Future<Invoice> updateStatus(String invoiceId, String newStatus) async {
    final response = await _dio.patch(
      '/api/invoices/$invoiceId/status',
      data: {'status': newStatus},
    );
    return Invoice.fromJson(response.data);
  }

  Future<List<AvailableSubscription>> getAvailableSubscriptions() async {
    final response = await _dio.get('/api/invoices/subscriptions/available');
    final List<dynamic> data = response.data;
    return data.map((json) => AvailableSubscription.fromJson(json)).toList();
  }

  Future<Invoice> generateFromSubscription(
    String subscriptionId, {
    String? discountCode,
  }) async {
    final response = await _dio.post(
      '/api/invoices/generate-from-subscription/$subscriptionId',
      queryParameters: {
        if (discountCode != null && discountCode.isNotEmpty)
          'discount_code': discountCode,
      },
    );
    return Invoice.fromJson(response.data);
  }

  Future<InvoiceMetrics> getMetrics() async {
    final response = await _dio.get('/api/invoices/summary/metrics');
    return InvoiceMetrics.fromJson(response.data);
  }
}
