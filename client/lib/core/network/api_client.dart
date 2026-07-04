import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import '../storage/secure_storage_service.dart';
import '../utils/constants.dart';
import '../../app/routes/app_routes.dart';

class ApiClient {
  static late Dio _dio;

  static Dio get instance => _dio;

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _ErrorInterceptor(),
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ),
    ]);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorageService.read(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await SecureStorageService.deleteAll();
      getx.Get.offAllNamed(AppRoutes.login);
      _showError('Session expired. Please log in again.');
      return;
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Don't show error snackbar for 401 — _AuthInterceptor handles it
    if (err.response?.statusCode == 401) {
      handler.next(err);
      return;
    }
    final message = _parseError(err);
    _showError(message);
    handler.next(err);
  }

  String _parseError(DioException err) {
    if (err.response?.data is Map) {
      final data = err.response!.data as Map;
      return data['message']?.toString() ?? 'An error occurred';
    }
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Check your network.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Check your network.';
      default:
        return err.message ?? 'An unexpected error occurred';
    }
  }
}

void _showError(String message) {
  getx.Get.snackbar(
    'Error',
    message,
    snackPosition: getx.SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    margin: const EdgeInsets.all(16),
    borderRadius: 14,
    backgroundColor: const Color(0xFF1C1C1E),
    colorText: Colors.white,
    icon: const Icon(Icons.error_outline, color: Colors.white),
  );
}
