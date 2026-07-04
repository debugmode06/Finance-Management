import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class AuthProvider {
  final Dio _dio = ApiClient.instance;

  Future<Response> login(String email, String password) async {
    return _dio.post(AppEndpoints.login, data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getMe() async {
    return _dio.get(AppEndpoints.me);
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return _dio.post(AppEndpoints.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  Future<Response> logout() async {
    return _dio.post(AppEndpoints.logout);
  }
}
