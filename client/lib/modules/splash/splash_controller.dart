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
    await Future.delayed(const Duration(milliseconds: 1800));

    try {
      final token = await SecureStorageService.read(AppConstants.tokenKey);
      if (token == null || token.isEmpty) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final response = await AuthProvider().getMe();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
        await SecureStorageService.write(AppConstants.roleKey, user.role);

        if (user.isFinanceDirector) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.directorDashboard);
        }
      } else {
        await SecureStorageService.deleteAll();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      await SecureStorageService.deleteAll();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
