//lib/core/router/router_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meducyte_app/core/routes/routes_provider.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _onboardingDone = _ref.read(onboardingProvider);
    _isLoggedIn = _ref.read(authProvider);
    _isReady = false;

    //Listen for onboarding state
    _ref.listen<bool>(onboardingProvider, (prev, next) {
      if (_onboardingDone != next) {
        _onboardingDone = next;
        notifyListeners();
      }
    });

    //Listen for authentication state
    _ref.listen<bool>(authProvider, (prev, next) {
      if (_isLoggedIn != next) {
        _isLoggedIn = next;
        notifyListeners();
      }
    });

    //Handle app initialization(and splash delay)
    _ref.listen<AsyncValue<void>>(appInitProvider, (prev, next) async {
      final loaded = next.maybeWhen(data: (_) => true, orElse: () => false);
      if (loaded && !_isReady) {
        //Keep splash visible for a few seconds
        await Future.delayed(const Duration(seconds: 5));
        _isReady = true;
        notifyListeners();
      }
    });
  }

  final Ref _ref;

  bool _onboardingDone = false;
  bool get onboardingDone => _onboardingDone;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isReady = false;
  bool get isReady => _isReady;
}
