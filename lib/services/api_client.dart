import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'retry_interceptor.dart';

const String _kAccessToken = 'access_token';
const String _kRefreshToken = 'refresh_token';

class ApiClient {
  ApiClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _attachToken,
        onError: _refreshOnUnauthorized,
      ),
    );
    // Retry transient failures (timeouts, connection errors, HTTP 5xx) with
    // exponential backoff. Added after the auth wrapper so 401s are handled by
    // the token-refresh logic and are never retried here.
    dio.interceptors.add(RetryInterceptor(dio: dio));
  }

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  final Dio dio;
  
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: _kAccessToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _refreshOnUnauthorized(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode != 401) {
      handler.next(error);
      return;
    }
    final refreshToken = await _secureStorage.read(key: _kRefreshToken);
    if (refreshToken == null) {
      handler.next(error);
      return;
    }
    try {
      final resp = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {}),
      );
      final tokens = resp.data['data']['tokens'] as Map<String, dynamic>;
      await _secureStorage.write(key: _kAccessToken, value: tokens['access_token'] as String);
      await _secureStorage.write(key: _kRefreshToken, value: tokens['refresh_token'] as String);

      final opts = error.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${tokens['access_token']}';
      final retried = await dio.fetch(opts);
      handler.resolve(retried);
    } catch (_) {
      await _secureStorage.delete(key: _kAccessToken);
      await _secureStorage.delete(key: _kRefreshToken);
      handler.next(error);
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _secureStorage.write(key: _kAccessToken, value: access);
    await _secureStorage.write(key: _kRefreshToken, value: refresh);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _kAccessToken);
    await _secureStorage.delete(key: _kRefreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _kAccessToken);
  }
}

final apiClient = ApiClient();
