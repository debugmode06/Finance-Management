import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/proposal_provider.dart';
import '../../../data/models/proposal_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/constants.dart';

class ProposalDetailController extends GetxController {
  final ProposalProvider _provider = ProposalProvider();

  final isLoading = true.obs;
  final isActioning = false.obs;
  final proposal = Rxn<ProposalModel>();
  final comments = <CommentModel>[].obs;
  final isLoadingComments = false.obs;
  final commentCtrl = TextEditingController();
  final currentRole = ''.obs;
  String get proposalId => (Get.arguments as Map)['id'] as String;

  @override
  void onInit() {
    super.onInit();
    loadRole();
    loadProposal();
    loadComments();
  }

  Future<void> loadRole() async {
    currentRole.value =
        await SecureStorageService.read(AppConstants.roleKey) ?? '';
  }

  bool get isFinanceDirector => currentRole.value == AppConstants.roleFinanceDirector;
  bool get isDirector => currentRole.value == AppConstants.roleDirector;

  Future<void> loadProposal() async {
    isLoading.value = true;
    try {
      final response = await _provider.getProposalById(proposalId);
      if (response.statusCode == 200 && response.data['success'] == true) {
        proposal.value = ProposalModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments() async {
    isLoadingComments.value = true;
    try {
      final response = await _provider.getComments(proposalId);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        comments.value = data
            .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> postComment() async {
    final msg = commentCtrl.text.trim();
    if (msg.isEmpty) return;
    try {
      await _provider.addComment(proposalId, msg);
      commentCtrl.clear();
      await loadComments();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> submit() async {
    isActioning.value = true;
    try {
      final response = await _provider.submitProposal(proposalId);
      if (response.statusCode == 200) {
        Get.snackbar('Submitted!', 'Proposal submitted for review');
        await loadProposal();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Submit failed');
      }
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> approve(double budget) async {
    isActioning.value = true;
    try {
      final response = await _provider.approveProposal(proposalId, budget);
      if (response.statusCode == 200) {
        Get.snackbar('Approved!', 'Proposal approved with RM ${budget.toStringAsFixed(2)}');
        await loadProposal();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Approval failed');
      }
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> reject(String reason) async {
    isActioning.value = true;
    try {
      final response = await _provider.rejectProposal(proposalId, reason);
      if (response.statusCode == 200) {
        Get.snackbar('Rejected', 'Proposal has been rejected');
        await loadProposal();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Rejection failed');
      }
    } finally {
      isActioning.value = false;
    }
  }

  Future<void> complete() async {
    isActioning.value = true;
    try {
      final response = await _provider.completeProposal(proposalId);
      if (response.statusCode == 200) {
        Get.snackbar('Completed!', 'Proposal marked as completed');
        await loadProposal();
      } else {
        Get.snackbar('Error', response.data['message'] ?? 'Complete failed');
      }
    } finally {
      isActioning.value = false;
    }
  }

  void showApproveSheet(BuildContext context) {
    final budgetCtrl = TextEditingController(
        text: proposal.value?.requestedBudget.toStringAsFixed(2) ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Approve Proposal',
                style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Set the approved budget amount:',
                style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: budgetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Approved Budget (RM)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34C759)),
                onPressed: () {
                  final budget = double.tryParse(budgetCtrl.text);
                  if (budget != null && budget > 0) {
                    Navigator.pop(ctx);
                    approve(budget);
                  }
                },
                child: const Text('Approve',
                    style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void showRejectSheet(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('Reject Proposal',
                style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Please provide a reason for rejection:',
                style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'Explain why this proposal is being rejected...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30)),
                onPressed: () {
                  if (reasonCtrl.text.trim().isNotEmpty) {
                    Navigator.pop(ctx);
                    reject(reasonCtrl.text.trim());
                  }
                },
                child: const Text('Reject',
                    style: TextStyle(color: Colors.white, fontSize: 17)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onClose() {
    commentCtrl.dispose();
    super.onClose();
  }
}
