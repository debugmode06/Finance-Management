import 'package:get/get.dart';
import 'director_detail_controller.dart';

class DirectorDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectorDetailController>(() => DirectorDetailController());
  }
}
