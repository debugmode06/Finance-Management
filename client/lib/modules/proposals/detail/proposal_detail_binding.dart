import 'package:get/get.dart';
import 'proposal_detail_controller.dart';

class ProposalDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProposalDetailController>(() => ProposalDetailController());
  }
}
