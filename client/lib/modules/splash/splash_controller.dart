import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/utils/constants.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Overall safety net: if anything hangs for more than 10s, bail to login
    try {
      await _doCheckAuth().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[Splash] Auth check timed out — going to login');
          Get.offAllNamed(AppRoutes.login);
        },
      );
    } catch (_) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _doCheckAuth() async {
    String? token;

    // Secure storage read can hang on some devices — wrap with its own timeout
    try {
      token = await SecureStorageService.read(AppConstants.tokenKey)
          .timeout(const Duration(seconds: 5));
      debugPrint('[Splash] Token read: ${token != null ? "found" : "null"}');
    } catch (e) {
      debugPrint('[Splash] SecureStorage read failed/timed out: $e');
      // Clear corrupted storage and go to login
      try {
        await SecureStorageService.deleteAll()
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (token == null || token.isEmpty) {
      debugPrint('[Splash] No token — going to login');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // Token exists: validate with server
    try {
      debugPrint('[Splash] Calling getMe()...');
      final response = await AuthProvider().getMe();
      debugPrint('[Splash] getMe() status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = UserModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
        try {
          await SecureStorageService.write(AppConstants.roleKey, user.role)
              .timeout(const Duration(seconds: 3));
        } catch (_) {}

        if (user.isFinanceDirector) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.directorDashboard);
        }
      } else {
        debugPrint('[Splash] getMe() non-200 — going to login');
        try {
          await SecureStorageService.deleteAll()
              .timeout(const Duration(seconds: 3));
        } catch (_) {}
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('[Splash] getMe() failed: $e — going to login');
      try {
        await SecureStorageService.deleteAll()
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
