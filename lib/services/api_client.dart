import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kAccessToken = 'nodus_access_token';
const String _kRefreshToken = 'nodus_refresh_token';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

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
  }

  final Dio dio;

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_kAccessToken);
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
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_kRefreshToken);
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
      await prefs.setString(_kAccessToken, tokens['access_token'] as String);
      await prefs.setString(_kRefreshToken, tokens['refresh_token'] as String);

      final opts = error.requestOptions;
      opts.headers['Authorization'] = 'Bearer ${tokens['access_token']}';
      final retried = await dio.fetch(opts);
      handler.resolve(retried);
    } catch (_) {
      await prefs.remove(_kAccessToken);
      await prefs.remove(_kRefreshToken);
      handler.next(error);
    }
  }

  Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, access);
    await prefs.setString(_kRefreshToken, refresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kRefreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessToken);
  }
}

final apiClient = ApiClient();
