import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice_model.dart';
import '../repositories/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository();
});

class InvoiceState {
  final List<Invoice> invoices;
  final String statusFilter;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final Invoice? currentInvoice;
  final List<AvailableSubscription> availableSubscriptions;
  final InvoiceMetrics? metrics;

  InvoiceState({
    this.invoices = const [],
    this.statusFilter = 'All',
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.currentInvoice,
    this.availableSubscriptions = const [],
    this.metrics,
  });

  InvoiceState copyWith({
    List<Invoice>? invoices,
    String? statusFilter,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    Invoice? currentInvoice,
    List<AvailableSubscription>? availableSubscriptions,
    InvoiceMetrics? metrics,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentInvoice: currentInvoice ?? this.currentInvoice,
      availableSubscriptions:
          availableSubscriptions ?? this.availableSubscriptions,
      metrics: metrics ?? this.metrics,
    );
  }
}

class InvoiceNotifier extends Notifier<InvoiceState> {
  late final InvoiceRepository _repository;

  @override
  InvoiceState build() {
    _repository = ref.watch(invoiceRepositoryProvider);
    Future.microtask(() => refreshAll());
    return InvoiceState();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchInvoices(),
      fetchAvailableSubscriptions(),
      fetchMetrics(),
    ]);
  }

  Future<void> fetchInvoices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getInvoices(
        status: state.statusFilter,
        search: state.searchQuery,
      );
      state = state.copyWith(invoices: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
    fetchInvoices();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    fetchInvoices();
  }

  Future<void> fetchInvoiceDetails(String id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final inv = await _repository.getInvoice(id);
      state = state.copyWith(currentInvoice: inv, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<Invoice?> createInvoice({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final inv = await _repository.createInvoice(
        subscriptionId: subscriptionId,
        billingCycleStart: billingCycleStart,
        billingCycleEnd: billingCycleEnd,
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerState: customerState,
        customerGstin: customerGstin,
        customerAddress: customerAddress,
        companyState: companyState,
        discountCode: discountCode,
        items: items,
        issueDate: issueDate,
        dueDate: dueDate,
        notes: notes,
        autoPost: autoPost,
      );
      await refreshAll();
      return inv;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<Invoice?> generateFromSubscription(
    String subscriptionId, {
    String? discountCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final inv = await _repository.generateFromSubscription(
        subscriptionId,
        discountCode: discountCode,
      );
      await refreshAll();
      return inv;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> updateInvoiceStatus(String invoiceId, String newStatus) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _repository.updateStatus(invoiceId, newStatus);
      final updatedList =
          state.invoices.map((i) => i.id == invoiceId ? updated : i).toList();
      state = state.copyWith(
        invoices: updatedList,
        currentInvoice: updated,
        isLoading: false,
      );
      await fetchMetrics();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> fetchAvailableSubscriptions() async {
    try {
      final subs = await _repository.getAvailableSubscriptions();
      state = state.copyWith(availableSubscriptions: subs);
    } catch (_) {
      // Keep existing
    }
  }

  Future<void> fetchMetrics() async {
    try {
      final m = await _repository.getMetrics();
      state = state.copyWith(metrics: m);
    } catch (_) {
      // Keep existing
    }
  }
}

final invoiceProvider = NotifierProvider<InvoiceNotifier, InvoiceState>(InvoiceNotifier.new);
