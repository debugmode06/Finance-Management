import 'package:get/get.dart';
import 'proposal_bills_controller.dart';

class ProposalBillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProposalBillsController>(() => ProposalBillsController());
  }
}
