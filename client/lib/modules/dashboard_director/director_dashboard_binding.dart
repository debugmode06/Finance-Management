import 'package:get/get.dart';
import 'director_dashboard_controller.dart';

class DirectorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectorDashboardController>(() => DirectorDashboardController());
  }
}
