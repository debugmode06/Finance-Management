import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 2));
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token == null || token.isEmpty) {
        debugPrint('[Splash] No token found in SharedPreferences');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      debugPrint('[Splash] Token found. Validating with server...');
      final response = await AuthProvider().getMe().timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
        await SecureStorageService.write(AppConstants.roleKey, user.role);

        if (user.isFinanceDirector) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.directorDashboard);
        }
      } else {
        debugPrint('[Splash] Token validation failed. Going to login...');
        await SecureStorageService.deleteAll();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('[Splash] Auth check error: $e. Redirecting to login...');
      // In case of offline or timeout, we can clear and go to login to be safe
      await SecureStorageService.deleteAll().catchError((_) {});
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
