import 'package:get/get.dart';
import 'director_create_edit_controller.dart';

class DirectorCreateEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectorCreateEditController>(
        () => DirectorCreateEditController());
  }
}
