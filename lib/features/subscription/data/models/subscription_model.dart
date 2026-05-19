import 'package:flutter/foundation.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String sku;
  final double price;
  final String? description;
  final int durationMonths;

  final bool hasAiAccess;
  final String accessLevel;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.description,
    required this.durationMonths,
    required this.hasAiAccess,
    required this.accessLevel,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    try {
      return SubscriptionPlan(
        id: (json['id'] ?? '').toString(),
        name: json['name'] ?? 'Unknown Plan',
        sku: json['sku'] ?? '',
        price: _parsePrice(json['price']),
        description: json['description'],
        durationMonths: _parseInt(
          json['duration_months'] ?? json['durationMonths'],
        ),
        hasAiAccess: _parseBool(json['has_ai_access'] ?? json['hasAiAccess']),
        accessLevel: json['access_level'] ?? json['accessLevel'] ?? 'free',
      );
    } catch (e) {
      debugPrint('Error parsing SubscriptionPlan: $e');
      return SubscriptionPlan(
        id: 'error',
        name: 'Error',
        sku: '',
        price: 0.0,
        durationMonths: 1,
        hasAiAccess: false,
        accessLevel: 'free',
      );
    }
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'price': price,
    'description': description,
    'duration_months': durationMonths,
    'has_ai_access': hasAiAccess,
    'access_level': accessLevel,
  };
}

class Offer {
  final String id;
  final String code;
  final int discountPercent;
  final DateTime? validUntil;
  final String type;

  Offer({
    required this.id,
    required this.code,
    required this.discountPercent,
    this.validUntil,
    required this.type,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'].toString(),
      code: json['code'],
      discountPercent: json['discount_percent'] ?? json['discountPercent'] ?? 0,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : json['validUntil'] != null
          ? DateTime.parse(json['validUntil'])
          : null,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'discount_percent': discountPercent,
    'valid_until': validUntil?.toIso8601String(),
    'type': type,
  };
}

class UserSubscription {
  final String id;
  final String planId;
  final DateTime startsAt;
  final DateTime expiresAt;
  final String status;
  final SubscriptionPlan? plan;

  UserSubscription({
    required this.id,
    required this.planId,
    required this.startsAt,
    required this.expiresAt,
    required this.status,
    this.plan,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    try {
      final startsAtStr = json['starts_at'] ?? json['startsAt'];
      final expiresAtStr = json['expires_at'] ?? json['expiresAt'];

      return UserSubscription(
        id: (json['id'] ?? '').toString(),
        planId: (json['plan_id'] ?? json['planId'] ?? '').toString(),
        startsAt: startsAtStr != null
            ? DateTime.parse(startsAtStr)
            : DateTime.now(),
        expiresAt: expiresAtStr != null
            ? DateTime.parse(expiresAtStr)
            : DateTime.now().add(const Duration(days: 30)),
        status: json['status'] ?? 'unknown',
        plan: json['plan'] != null
            ? SubscriptionPlan.fromJson(json['plan'])
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing UserSubscription: $e');
      //Fallback object to prevent total crash
      return UserSubscription(
        id: 'error',
        planId: '',
        startsAt: DateTime.now(),
        expiresAt: DateTime.now(),
        status: 'error',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'plan_id': planId,
    'starts_at': startsAt.toIso8601String(),
    'expires_at': expiresAt.toIso8601String(),
    'status': status,
    'plan': plan?.toJson(),
  };

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());
}
