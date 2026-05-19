import 'dart:convert';
import 'package:meducyte_app/core/access/feature_access.dart';
import 'package:meducyte_app/export.dart';
import 'package:meducyte_app/features/notifications/application/services/notification_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final service = ref.watch(authServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(service: service, storage: storage);
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthService(dio: dio, storage: storage);
});

// ----------------AuthController Provider----------------
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return AuthController(repo, ref: ref);
    });

final featureAccessProvider = Provider.family<bool, FeatureId>((
  ref,
  featureId,
) {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return false;
  return user.hasAccess(featureId);
});

// ----------------AuthController----------------
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository repo;
  final Ref ref;
  String? _pendingVerificationEmail;
  String? _pendingVerificationType; // 'email_verification'or'password_reset'

  AuthController(this.repo, {required this.ref})
    : super(const AsyncValue.loading()) {
    _autoLogin();
  }

  String? get pendingVerificationEmail => _pendingVerificationEmail;
  String? get pendingVerificationType => _pendingVerificationType;

  // ✅Set pending verification
  void setPendingVerification(String email, String type) {
    _pendingVerificationEmail = email;
    _pendingVerificationType = type;
  }

  // ───User cache helpers───────────────────────────────────────────────────
  static const _userCacheKey = 'cached_user';

  Future<void> _saveUserCache(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userCacheKey, jsonEncode(user.toJson()));
  }

  Future<User?> _loadUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userCacheKey);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userCacheKey);
  }

  // ───Auto login on startup────────────────────────────────────────────────
  Future<void> _autoLogin() async {
    try {
      //1.Immediately load and show cached user if available
      final cached = await _loadUserCache();
      if (cached != null) {
        state = AsyncValue.data(cached);
        ref.read(authProvider.notifier).logIn();
        ref.read(notificationServiceProvider).initRemoteNotifications();
      }

      final accessToken = await repo.storage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        debugPrint('Auth:Token found,fetching current user...');
        final user = await repo.getCurrentUser();
        debugPrint('Auth:User fetched.Subscribed: ${user.isSubscriber}');
        if (user.activeSubscription != null) {
          debugPrint(
            'Auth:Subscription Status: ${user.activeSubscription!.status}',
          );
          debugPrint(
            'Auth:Subscription Expires: ${user.activeSubscription!.expiresAt}',
          );
        }
        await _saveUserCache(user);
        state = AsyncValue.data(user);
        if (cached == null) {
          ref.read(authProvider.notifier).logIn();
          ref.read(notificationServiceProvider).initRemoteNotifications();
        }
      } else {
        //No token stored→definitely logged out
        await _clearUserCache();
        state = const AsyncValue.data(null);
        ref.read(authProvider.notifier).logOut();
      }
    } on DioException catch (e) {
      debugPrint('Auth:DioException during auto-login: ${e.message}');
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        //Server explicitly rejected the token—genuine logout
        await repo.storage.delete(key: 'access_token');
        await repo.storage.delete(key: 'refresh_token');
        await _clearUserCache();
        state = const AsyncValue.data(null);
        ref.read(authProvider.notifier).logOut();
      } else {
        //Transient network error:restore cached user so the app is usable
        debugPrint(
          'Auth:Transient network error during auto-login: ${e.message}',
        );
        final cached = await _loadUserCache();
        state = AsyncValue.data(cached);
      }
    } on ApiException catch (e) {
      debugPrint('Auth:API error during auto-login: $e');
      final cached = await _loadUserCache();
      state = AsyncValue.data(cached);
    } catch (e, st) {
      debugPrint('Auth:Unknown error during auto-login: $e');
      debugPrint('Stacktrace: $st');
      //Unknown error:restore cached user
      final cached = await _loadUserCache();
      state = AsyncValue.data(cached);
    }
  }

  // ───Login────────────────────────────────────────────────────────────────
  Future<void> login(String email, String password, String deviceId) async {
    state = const AsyncValue.loading();
    try {
      final user = await repo.login(email, password, deviceId);
      await _saveUserCache(user);
      state = AsyncValue.data(user);
      _pendingVerificationEmail = null;
      ref.read(authProvider.notifier).logIn();
      ref.read(notificationServiceProvider).initRemoteNotifications();
    } on EmailNotVerifiedException catch (e) {
      _pendingVerificationEmail = email;
      _pendingVerificationType = 'email_verification';
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signup(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final email = data['email'] as String?;
      await repo.signup(data);

      if (email != null) {
        _pendingVerificationEmail = email;
        _pendingVerificationType = 'email_verification';
      }
      state = const AsyncValue.data(null); //User not fully authenticated yet
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (_pendingVerificationEmail == null || _pendingVerificationType == null) {
      throw Exception('No pending email verification');
    }

    state = const AsyncValue.loading();
    try {
      final result = await repo.service.verifyOtp(
        _pendingVerificationEmail!,
        otp,
        _pendingVerificationType!,
      );

      //If verification returns user data(auto-login),update state
      if (result['user'] != null) {
        final userJson = result['user'] as Map<String, dynamic>;
        final user = User.fromJson(userJson);

        //Store tokens if provided
        final token = result['access_token'] as String?;
        final deviceId = result['device_id'] as String?;
        final expiresAt = result['expires_at'] as String?;

        if (token != null) {
          await repo.storage.write(key: 'access_token', value: token);
        }
        if (deviceId != null) {
          await repo.storage.write(key: 'device_id', value: deviceId);
        }
        if (expiresAt != null) {
          await repo.storage.write(key: 'expires_at', value: expiresAt);
        }

        state = AsyncValue.data(user);
        //Sync with boolean auth state
        ref.read(authProvider.notifier).logIn();
        ref.read(notificationServiceProvider).initRemoteNotifications();
      } else {
        state = const AsyncValue.data(null);
      }

      //Clear pending verification
      _pendingVerificationEmail = null;
      _pendingVerificationType = null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Verification failed';
      state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> resendOtp() async {
    if (_pendingVerificationEmail == null || _pendingVerificationType == null) {
      throw Exception('No pending email verification');
    }

    state = const AsyncValue.loading(); //Show loading state

    try {
      await repo.service.resendOtp(
        _pendingVerificationEmail!,
        _pendingVerificationType!,
      );

      //Update state on success
      state = const AsyncValue.data(null);
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] ?? 'Failed to resend OTP';
      state = AsyncValue.error(Exception(errorMessage), StackTrace.current);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  //For password reset flow
  Future<void> forgotPassword(String email) async {
    try {
      await repo.service.forgotPassword(email);
      _pendingVerificationEmail = email;
      _pendingVerificationType = 'password_reset';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(
    String otp,
    String password,
    String passwordConfirmation,
  ) async {
    if (_pendingVerificationEmail == null ||
        _pendingVerificationType != 'password_reset') {
      throw Exception('No pending password reset');
    }

    try {
      await repo.service.resetPassword(
        _pendingVerificationEmail!,
        otp,
        password,
        passwordConfirmation,
      );

      //Clear pending verification after successful reset
      _pendingVerificationEmail = null;
      _pendingVerificationType = null;
    } catch (e) {
      rethrow;
    }
  }

  void clearPendingVerification() {
    _pendingVerificationEmail = null;
    _pendingVerificationType = null;
  }

  Future<void> logout() async {
    try {
      await repo.logout();
    } finally {
      await repo.storage.delete(key: 'access_token');
      await repo.storage.delete(key: 'refresh_token');
      _pendingVerificationEmail = null;
      _pendingVerificationType = null;
      state = const AsyncValue.data(null);
      //Sync with boolean auth state
      ref.read(authProvider.notifier).logOut();
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();
    try {
      await repo.deleteAccount();
      await repo.storage.delete(key: 'access_token');
      await repo.storage.delete(key: 'refresh_token');
      await _clearUserCache();
      _pendingVerificationEmail = null;
      _pendingVerificationType = null;
      state = const AsyncValue.data(null);
      ref.read(authProvider.notifier).logOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refreshToken() async {
    try {
      final refreshToken = await repo.storage.read(key: 'refresh_token');
      if (refreshToken == null) throw Exception('No refresh token');

      final deviceId = await repo.storage.read(key: 'device_id');
      if (deviceId == null) throw Exception('No device ID');

      final newTokens = await repo.service.refreshToken(refreshToken, deviceId);

      final newAccessToken = newTokens['access_token'] as String?;
      final newRefreshToken = newTokens['refresh_token'] as String?;

      if (newAccessToken != null) {
        await repo.storage.write(key: 'access_token', value: newAccessToken);
      }
      if (newRefreshToken != null) {
        await repo.storage.write(key: 'refresh_token', value: newRefreshToken);
      }
    } catch (e) {
      await repo.storage.delete(key: 'access_token');
      await repo.storage.delete(key: 'refresh_token');
      _pendingVerificationEmail = null;
      _pendingVerificationType = null;
      state = const AsyncValue.data(null);
      //Sync with boolean auth state
      ref.read(authProvider.notifier).logOut();
      rethrow;
    }
  }

  Future<void> getUser() => _autoLogin();

  Future<void> updateUser(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await repo.updateUser(data);
      await _saveUserCache(updatedUser);
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
