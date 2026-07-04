import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class NotificationProvider {
  final Dio _dio = ApiClient.instance;

  Future<Response> getNotifications({
    int page = 1,
    int limit = 30,
    bool unreadOnly = false,
  }) async {
    return _dio.get(AppEndpoints.notifications, queryParameters: {
      'page': page,
      'limit': limit,
      if (unreadOnly) 'unreadOnly': 'true',
    });
  }

  Future<Response> markRead(String id) async {
    return _dio.patch(AppEndpoints.markRead(id));
  }

  Future<Response> markAllRead() async {
    return _dio.patch(AppEndpoints.markAllRead);
  }
}

class ReportProvider {
  final Dio _dio = ApiClient.instance;

  Future<Response> exportReport({
    required String format,
    String? period,
    String? department,
    String? status,
  }) async {
    return _dio.get(
      AppEndpoints.exportReport,
      queryParameters: {
        'format': format,
        if (period != null) 'period': period,
        if (department != null) 'department': department,
        if (status != null) 'status': status,
      },
      options: Options(responseType: ResponseType.bytes),
    );
  }
}
