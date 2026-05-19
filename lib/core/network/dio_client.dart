import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:synchronized/synchronized.dart';

///Centralized Dio HTTP client for API requests
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  final Lock _refreshLock = Lock();
  final void Function()? onLogout;

  Dio get dio => _dio;

  DioClient({
    required String baseUrl,
    required FlutterSecureStorage secureStorage,
    this.onLogout,
  }) : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          //Only add auth token for our own API requests
          if (options.path.startsWith(_dio.options.baseUrl) ||
              !options.path.startsWith('http')) {
            final token = await _secureStorage.read(key: 'access_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final response = error.response;
          final requestOptions = error.requestOptions;

          //Handle 401 Unauthorized-token expired
          //Only for our own API requests
          if (response?.statusCode == 401 &&
              (requestOptions.path.startsWith(_dio.options.baseUrl) ||
                  !requestOptions.path.startsWith('http'))) {
            //Use lock to prevent multiple concurrent refresh calls
            return _refreshLock.synchronized(() async {
              try {
                final refreshToken = await _secureStorage.read(
                  key: 'refresh_token',
                );
                final deviceId = await _secureStorage.read(key: 'device_id');

                if (refreshToken == null || deviceId == null) {
                  throw Exception('Missing refresh token or device id');
                }

                //Call refresh endpoint
                final refreshResponse =
                    await Dio(BaseOptions(baseUrl: _dio.options.baseUrl)).post(
                      '/refresh',
                      data: {
                        'refresh_token': refreshToken,
                        'device_id': deviceId,
                      },
                    );

                if (refreshResponse.statusCode == 200) {
                  final data = refreshResponse.data as Map<String, dynamic>;
                  final newAccessToken = data['access_token'] as String?;
                  final newRefreshToken = data['refresh_token'] as String?;

                  if (newAccessToken != null) {
                    await _secureStorage.write(
                      key: 'access_token',
                      value: newAccessToken,
                    );
                  }
                  if (newRefreshToken != null) {
                    await _secureStorage.write(
                      key: 'refresh_token',
                      value: newRefreshToken,
                    );
                  }

                  //Retry original request
                  final opts = Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                  );
                  opts.headers?['Authorization'] = 'Bearer $newAccessToken';

                  final retryResponse = await _dio.request(
                    requestOptions.path,
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                    options: opts,
                  );
                  return handler.resolve(retryResponse);
                } else {
                  throw Exception('Refresh failed');
                }
              } catch (e) {
                //Clear tokens and trigger logout
                await _secureStorage.delete(key: 'access_token');
                await _secureStorage.delete(key: 'refresh_token');
                onLogout?.call();
                return handler.next(error);
              }
            });
          }
          return handler.next(error);
        },
      ),
    );
  }

  ///GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  ///POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  ///PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  ///DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  ///PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
