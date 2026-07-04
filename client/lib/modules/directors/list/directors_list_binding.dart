import 'package:get/get.dart';
import 'directors_list_controller.dart';

class DirectorsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectorsListController>(() => DirectorsListController());
  }
}
