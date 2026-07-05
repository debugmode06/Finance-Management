import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // Navigate to login immediately — no async, no storage, no network
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.offAllNamed(AppRoutes.login);
    });
  }
}
