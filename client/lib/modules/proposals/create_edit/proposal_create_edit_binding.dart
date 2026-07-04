import 'package:get/get.dart';
import 'proposal_create_edit_controller.dart';

class ProposalCreateEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProposalCreateEditController>(
        () => ProposalCreateEditController());
  }
}
