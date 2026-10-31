import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/discount_model.dart';
import '../repositories/discount_repository.dart';

final discountRepositoryProvider = Provider<DiscountRepository>((ref) {
  return DiscountRepository();
});

class DiscountState {
  final List<Discount> discounts;
  final bool isLoading;
  final String? errorMessage;

  DiscountState({
    this.discounts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DiscountState copyWith({
    List<Discount>? discounts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DiscountState(
      discounts: discounts ?? this.discounts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class DiscountNotifier extends Notifier<DiscountState> {
  late final DiscountRepository _repository;

  @override
  DiscountState build() {
    _repository = ref.watch(discountRepositoryProvider);
    Future.microtask(() => fetchDiscounts());
    return DiscountState();
  }

  Future<void> fetchDiscounts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getDiscounts();
      state = state.copyWith(discounts: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> createDiscount({
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
    try {
      final newDisc = await _repository.createDiscount(
        code: code,
        name: name,
        discountType: discountType,
        value: value,
        scope: scope,
        productId: productId,
        minPurchaseAmount: minPurchaseAmount,
        minQuantity: minQuantity,
        startDate: startDate,
        expiryDate: expiryDate,
        maxUses: maxUses,
      );
      state = state.copyWith(discounts: [newDisc, ...state.discounts]);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deactivateDiscount(String id) async {
    try {
      await _repository.deleteDiscount(id);
      await fetchDiscounts();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<DiscountValidationResult> validateCoupon({
    required String code,
    required double subtotal,
    int totalQuantity = 1,
    String? productId,
  }) async {
    return await _repository.validateDiscount(
      code: code,
      subtotal: subtotal,
      totalQuantity: totalQuantity,
      productId: productId,
    );
  }
}

final discountProvider = NotifierProvider<DiscountNotifier, DiscountState>(DiscountNotifier.new);
