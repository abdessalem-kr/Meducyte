import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/features/auth/application/providers/auth_provider.dart';
import 'package:meducyte_app/features/subscription/data/models/subscription_model.dart';
import 'package:meducyte_app/features/subscription/data/repositories/subscription_repository.dart';

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlan>>((
  ref,
) async {
  return ref.watch(subscriptionRepositoryProvider).getSubscriptionPlans();
});

final activeOfferProvider = StateProvider<Offer?>((ref) => null);

final subscriptionControllerProvider =
    StateNotifierProvider<
      SubscriptionController,
      AsyncValue<UserSubscription?>
    >((ref) {
      return SubscriptionController(ref);
    });

class SubscriptionController
    extends StateNotifier<AsyncValue<UserSubscription?>> {
  final Ref _ref;
  SubscriptionController(this._ref) : super(const AsyncValue.data(null));

  Future<String?> subscribeWithChargily(String planId) async {
    state = const AsyncValue.loading();
    try {
      final checkoutUrl = await _ref
          .read(subscriptionRepositoryProvider)
          .createChargilyCheckout(planId);
      state = const AsyncValue.data(null);
      return checkoutUrl;
    } catch (e, st) {
      if (e is DioException) {
        debugPrint('Chargily Checkout Error Response: ${e.response?.data}');
        debugPrint('Status Code: ${e.response?.statusCode}');
      }
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> subscribe(String planId) async {
    state = const AsyncValue.loading();
    try {
      final offer = _ref.read(activeOfferProvider);
      final subscription = await _ref
          .read(subscriptionRepositoryProvider)
          .subscribe(planId, offerCode: offer?.code);
      state = AsyncValue.data(subscription);

      //Update auth state if needed to reflect new subscription
      _ref.read(authControllerProvider.notifier).getUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> applyOffer(String code) async {
    try {
      final offer = await _ref
          .read(subscriptionRepositoryProvider)
          .applyOffer(code);
      if (offer != null) {
        _ref.read(activeOfferProvider.notifier).state = offer;
      } else {
        //Handle invalid offer
      }
    } catch (e) {
      //Handle error
    }
  }
}
