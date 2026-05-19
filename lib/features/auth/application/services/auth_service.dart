import 'package:meducyte_app/export.dart';

class AuthService {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthService({required this.dio, required this.storage});

  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String deviceId,
  ) async {
    try {
      final response = await dio.post(
        '/api/login',
        data: {'email': email, 'password': password, 'device_id': deviceId},
      );

      final data = response.data as Map<String, dynamic>;

      if (data['requires_verification'] == true) {
        throw EmailNotVerifiedException(email);
      }

      final accessToken = data['access_token'] as String?;
      if (accessToken != null) {
        await storage.write(key: 'access_token', value: accessToken);
      }

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> &&
            data['requires_verification'] == true) {
          throw EmailNotVerifiedException(email);
        }
      }
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/api/register', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
    String type,
  ) async {
    try {
      final response = await dio.post(
        '/api/verify-otp',
        data: {'email': email, 'otp': otp, 'type': type},
      );

      final data = response.data as Map<String, dynamic>;

      if (type == 'email_verification') {
        final accessToken = data['access_token'] as String?;
        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken);
        }
      }

      return data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email, String type) async {
    try {
      final response = await dio.post(
        '/api/resend-otp',
        data: {'email': email, 'type': type},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await dio.post(
        '/api/forgot-password',
        data: {'email': email},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await dio.post(
        '/api/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> refreshToken(
    String refreshToken,
    String deviceId,
  ) async {
    try {
      final response = await dio.post(
        '/api/refresh',
        data: {'refresh_token': refreshToken, 'device_id': deviceId},
      );

      final data = response.data as Map<String, dynamic>;

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken != null) {
        await storage.write(key: 'access_token', value: newAccessToken);
      }
      if (newRefreshToken != null) {
        await storage.write(key: 'refresh_token', value: newRefreshToken);
      }

      return data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await dio.post('/api/logout');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await dio.delete('/api/account/delete');
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await dio.get('/api/me');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/api/profile/update', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> updateFcmToken(String fcmToken, String deviceId) async {
    try {
      await dio.post(
        '/api/update-fcm-token',
        data: {'fcm_token': fcmToken, 'device_id': deviceId},
      );
    } catch (e) {
      //Intentionally swallow error if this endpoint doesn't exist yet
      debugPrint('DEBUG:Error updating FCM token: $e');
    }
  }
}
