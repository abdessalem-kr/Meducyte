import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import 'router_notifier.dart';
import 'routes.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.read(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    extraCodec: const RouteExtraCodec(),
    routes: appRoutes.map((r) => r.toGoRoute()).toList(),
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final String loc = state.matchedLocation;

      // ✅Always allow staying on splash
      if (loc == AppRoutes.splash) {
        if (!routerNotifier.isReady) return null;
      }

      // 🔹If not ready→force splash
      if (!routerNotifier.isReady) {
        return AppRoutes.splash;
      }

      // 🔹If onboarding not completed
      if (!routerNotifier.onboardingDone) {
        if (loc == AppRoutes.onboarding) return null;
        return AppRoutes.onboarding;
      }

      // 🔹Onboarding done,but not logged in
      if (routerNotifier.onboardingDone && !routerNotifier.isLoggedIn) {
        //Allow OTP and password reset routes
        final allowedRoutes = [
          AppRoutes.welcome,
          AppRoutes.signup,
          AppRoutes.otpVerification,
          AppRoutes.forgotPassword,
          AppRoutes.resetPassword,
          AppRoutes.privacyPolicy,
          AppRoutes.termsOfUse,
        ];

        if (allowedRoutes.any((route) => loc.startsWith(route))) {
          return null;
        }
        return AppRoutes.welcome;
      }

      // 🔹Logged in→block onboarding/auth/splash
      if (routerNotifier.isLoggedIn) {
        final blockedRoutes = [
          AppRoutes.signup,
          AppRoutes.onboarding,
          AppRoutes.welcome,
          AppRoutes.splash,
          AppRoutes.otpVerification,
          AppRoutes.forgotPassword,
          AppRoutes.resetPassword,
        ];

        if (blockedRoutes.any((route) => loc.startsWith(route))) {
          return AppRoutes.home;
        }
      }

      //default→no redirect
      return null;
    },
  );
});

class RouteExtraCodec extends Codec<Object?, Object?> {
  const RouteExtraCodec();

  @override
  Converter<Object?, Object?> get decoder => const _RouteExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _RouteExtraEncoder();
}

// Memory registry to store references to non-serializable objects
final Map<String, Object> _extraRegistry = {};

class _RouteExtraEncoder extends Converter<Object?, Object?> {
  const _RouteExtraEncoder();
  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    // If it's already a standard primitive JSON-encodable type, return it as-is
    if (input is num || input is bool || input is String) {
      return input;
    }

    if (input is Map || input is List) {
      try {
        jsonEncode(input);
        return input;
      } catch (_) {
        // Fall through to register it
      }
    }

    // Generate a unique reference ID
    final refId = '${input.runtimeType}_${input.hashCode}_${DateTime.now().microsecondsSinceEpoch}';
    _extraRegistry[refId] = input;

    // Clean up older entries to prevent memory growth (keep last 100 entries)
    if (_extraRegistry.length > 100) {
      final keys = _extraRegistry.keys.toList();
      _extraRegistry.remove(keys.first);
    }

    return {
      '__type': 'RegistryRef',
      'id': refId,
    };
  }
}

class _RouteExtraDecoder extends Converter<Object?, Object?> {
  const _RouteExtraDecoder();
  @override
  Object? convert(Object? input) {
    if (input == null) return null;

    if (input is Map && input['__type'] == 'RegistryRef') {
      final refId = input['id'] as String?;
      if (refId != null && _extraRegistry.containsKey(refId)) {
        return _extraRegistry[refId];
      }
    }

    return input;
  }
}
