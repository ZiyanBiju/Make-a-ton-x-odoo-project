import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tax_model.dart';
import '../repositories/tax_repository.dart';

final taxRepositoryProvider = Provider<TaxRepository>((ref) {
  return TaxRepository();
});

class TaxState {
  final List<TaxRate> rates;
  final bool isLoading;
  final String? errorMessage;

  TaxState({
    this.rates = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TaxState copyWith({
    List<TaxRate>? rates,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaxState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TaxNotifier extends Notifier<TaxState> {
  late final TaxRepository _repository;

  @override
  TaxState build() {
    _repository = ref.watch(taxRepositoryProvider);
    Future.microtask(() => fetchRates());
    return TaxState();
  }

  Future<void> fetchRates() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final rates = await _repository.getTaxRates();
      state = state.copyWith(rates: rates, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addRate({
    required String name,
    required double rate,
    String? description,
  }) async {
    try {
      final newRate = await _repository.createTaxRate(
        name: name,
        rate: rate,
        description: description,
      );
      state = state.copyWith(rates: [...state.rates, newRate]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateRate(
    String id, {
    String? name,
    double? rate,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updated = await _repository.updateTaxRate(
        id,
        name: name,
        rate: rate,
        description: description,
        isActive: isActive,
      );
      final updatedList = state.rates.map((r) => r.id == id ? updated : r).toList();
      state = state.copyWith(rates: updatedList);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deactivateRate(String id) async {
    try {
      await _repository.deleteTaxRate(id);
      await fetchRates();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}

final taxProvider = NotifierProvider<TaxNotifier, TaxState>(TaxNotifier.new);
