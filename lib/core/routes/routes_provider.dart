import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Onboarding state(persisted)
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>(
  (ref) => OnboardingNotifier(),
);

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return; // ✅Prevent double initialization
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('onboardingDone') ?? false;
    _initialized = true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingDone', false);
    state = false;
  }
}

///Auth state(simple persisted flag for now)
final authProvider = StateNotifierProvider<AuthNotifier, bool>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return; // ✅Prevent re-init
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isLoggedIn') ?? false;
    _initialized = true;
  }

  Future<void> logIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    state = true;
  }

  Future<void> logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    state = false;
  }
}

///App init provider—ensures both persisted values are loaded on startup
final appInitProvider = FutureProvider<void>((ref) async {
  //Initialize both states before the router makes redirect decisions
  await Future.wait([
    ref.read(onboardingProvider.notifier).init(),
    ref.read(authProvider.notifier).init(),
  ]);
});
