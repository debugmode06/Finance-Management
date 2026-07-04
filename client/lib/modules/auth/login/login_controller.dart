import 'package:get/get.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';
import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final isLoading = false.obs;
  final emailError = RxnString();
  final passwordError = RxnString();

  Future<void> login(String email, String password) async {
    // Reset errors
    emailError.value = null;
    passwordError.value = null;

    // Client-side validation
    if (email.trim().isEmpty) {
      emailError.value = 'Email is required';
      return;
    }
    if (!GetUtils.isEmail(email.trim())) {
      emailError.value = 'Enter a valid email';
      return;
    }
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authProvider.login(email.trim(), password);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        final refreshToken = data['refreshToken'] as String? ?? '';
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        // Persist tokens and role
        await Future.wait([
          SecureStorageService.write(AppConstants.tokenKey, accessToken),
          SecureStorageService.write(AppConstants.refreshTokenKey, refreshToken),
          SecureStorageService.write(AppConstants.roleKey, user.role),
        ]);

        Get.snackbar(
          'Welcome back!',
          'Hello, ${user.name} 👋',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        if (user.isFinanceDirector) {
          Get.offAllNamed(AppRoutes.adminDashboard);
        } else {
          Get.offAllNamed(AppRoutes.directorDashboard);
        }
      } else {
        final message = response.data['message']?.toString() ?? 'Login failed';
        Get.snackbar('Login Failed', message, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Unable to connect. Check your network.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
