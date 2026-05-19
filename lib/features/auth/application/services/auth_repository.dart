import 'package:meducyte_app/export.dart';

class AuthRepository {
  final AuthService service;
  final FlutterSecureStorage storage;

  AuthRepository({required this.service, required this.storage});

  Future<User> login(String email, String password, String deviceId) async {
    final data = await service.login(email, password, deviceId);
    return _parseUser(data);
  }

  Future<User> signup(Map<String, dynamic> signupData) async {
    final data = await service.signup(signupData);
    return _parseUser(data);
  }

  Future<User> getCurrentUser() async {
    final data = await service.getCurrentUser();
    return _parseUser(data);
  }

  Future<void> logout() async {
    await service.logout();
  }

  Future<void> deleteAccount() async {
    await service.deleteAccount();
  }

  Future<User> updateUser(Map<String, dynamic> data) async {
    final responseData = await service.updateProfile(data);
    return _parseUser(responseData);
  }

  Future<void> updateFcmToken(String fcmToken, String deviceId) async {
    await service.updateFcmToken(fcmToken, deviceId);
  }

  User _parseUser(Map<String, dynamic> data) {
    if (data.containsKey('user') && data['user'] is Map) {
      return User.fromJson(data['user'] as Map<String, dynamic>);
    }
    return User.fromJson(data);
  }
}
