import 'api_client.dart';

class AuthService {
  final _dio = apiClient.dio;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final resp = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    });
    return resp.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = resp.data['data'] as Map<String, dynamic>;
    final tokens = data['tokens'] as Map<String, dynamic>;
    await apiClient.saveTokens(
      tokens['access_token'] as String,
      tokens['refresh_token'] as String,
    );
    return data;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } finally {
      await apiClient.clearTokens();
    }
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _dio.post('/auth/reset-password', data: {
      'token': token,
      'new_password': newPassword,
    });
  }
}
