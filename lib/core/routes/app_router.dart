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
