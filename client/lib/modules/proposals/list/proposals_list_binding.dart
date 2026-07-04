import 'package:get/get.dart';
import 'proposals_list_controller.dart';

class ProposalsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProposalsListController>(() => ProposalsListController());
  }
}
