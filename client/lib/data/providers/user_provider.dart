import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class UserProvider {
  final Dio _dio = ApiClient.instance;

  Future<Response> getUsers({
    String? search,
    String? department,
    String? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    return _dio.get(AppEndpoints.users, queryParameters: {
      if (search != null) 'search': search,
      if (department != null) 'department': department,
      if (isActive != null) 'isActive': isActive,
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> getUserById(String id) async {
    return _dio.get(AppEndpoints.userById(id));
  }

  Future<Response> createUser(Map<String, dynamic> data) async {
    return _dio.post(AppEndpoints.users, data: data);
  }

  Future<Response> updateUser(String id, FormData formData) async {
    return _dio.put(AppEndpoints.userById(id), data: formData);
  }

  Future<Response> deleteUser(String id) async {
    return _dio.delete(AppEndpoints.userById(id));
  }

  Future<Response> activateUser(String id) async {
    return _dio.patch(AppEndpoints.activateUser(id));
  }

  Future<Response> deactivateUser(String id) async {
    return _dio.patch(AppEndpoints.deactivateUser(id));
  }

  Future<Response> resetPassword(String id, String newPassword) async {
    return _dio.post(AppEndpoints.resetPassword(id),
        data: {'newPassword': newPassword});
  }

  Future<Response> getMyProfile() async {
    return _dio.get(AppEndpoints.myProfile);
  }

  Future<Response> updateMyProfile(FormData formData) async {
    return _dio.put(AppEndpoints.myProfile, data: formData);
  }
}
