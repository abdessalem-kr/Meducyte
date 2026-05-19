import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/network/dio_client.dart';
import 'package:meducyte_app/shared/providers/network_provider.dart';
import 'package:meducyte_app/features/subscription/data/models/subscription_model.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SubscriptionRepository(dioClient);
});

class SubscriptionRepository {
  final DioClient _client;
  SubscriptionRepository(this._client);

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    const query = r'''
 query GetSubscriptionPlans{
   subscriptionPlans{
     id
     name
     sku
     price
     description
     duration_months
     has_ai_access
     access_level
     }
   }
 ''';

    final response = await _client.post('/graphql', data: {'query': query});

    final Map<String, dynamic> responseData =
        response.data as Map<String, dynamic>;
    if (responseData['errors'] != null) {
      throw Exception(responseData['errors'][0]['message']);
    }

    final List data = responseData['data']?['subscriptionPlans'] ?? [];
    return data.map((json) => SubscriptionPlan.fromJson(json)).toList();
  }

  Future<UserSubscription> subscribe(String planId, {String? offerCode}) async {
    const mutation = r'''
 mutation Subscribe($planId:ID!, $offerCode:String) {
   subscribe(planId: $planId,offerCode: $offerCode) {
     id
     plan_id
     starts_at
     expires_at
     status
     plan{
       id
       name
       sku
       price
       description
       duration_months
       has_ai_access
       access_level
       }
     }
   }
 ''';

    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'planId': planId, 'offerCode': offerCode},
      },
    );

    final Map<String, dynamic> responseData =
        response.data as Map<String, dynamic>;
    if (responseData['errors'] != null) {
      throw Exception(responseData['errors'][0]['message']);
    }

    return UserSubscription.fromJson(responseData['data']?['subscribe']);
  }

  Future<Offer?> applyOffer(String code) async {
    const mutation = r'''
 mutation ApplyOffer($code:String!) {
   applyOffer(code: $code) {
     id
     code
     discount_percent
     valid_until
     type
     }
   }
 ''';

    final response = await _client.post(
      '/graphql',
      data: {
        'query': mutation,
        'variables': {'code': code},
      },
    );

    final Map<String, dynamic> responseData =
        response.data as Map<String, dynamic>;
    if (responseData['errors'] != null) {
      throw Exception(responseData['errors'][0]['message']);
    }

    final data = responseData['data']?['applyOffer'];
    return data != null ? Offer.fromJson(data) : null;
  }

  Future<String> createChargilyCheckout(String planId) async {
    final response = await _client.post(
      '/api/payment/chargily/checkout',
      data: {'plan_id': planId},
    );

    if (response.data['checkout_url'] != null) {
      return response.data['checkout_url'] as String;
    } else if (response.data['error'] != null) {
      throw Exception(response.data['error']);
    } else {
      throw Exception('Failed to create checkout session');
    }
  }
}
