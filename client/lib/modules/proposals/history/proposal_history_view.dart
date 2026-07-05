import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/providers/proposal_provider.dart';

class ProposalHistoryController extends GetxController {
  final _provider = ProposalProvider();
  final isLoading = true.obs;
  final history = <ProposalHistoryModel>[].obs;
  String get proposalId => (Get.arguments as Map)['id'] as String;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final res = await _provider.getProposalHistory(proposalId);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as List<dynamic>;
        history.value = data
            .map((h) =>
                ProposalHistoryModel.fromJson(h as Map<String, dynamic>))
            .toList();
      }
    } finally {
      isLoading.value = false;
    }
  }
}

class ProposalHistoryView extends GetView<ProposalHistoryController> {
  const ProposalHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('Proposal History')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.history.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No history available',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.history.length,
          itemBuilder: (_, i) {
            final h = controller.history[i];
            final isLast = i == controller.history.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.statusBg(h.status),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.statusText(h.status)
                                .withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: Icon(
                        _statusIcon(h.status),
                        color: AppColors.statusText(h.status),
                        size: 18,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 60,
                        color: AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(h.status,
                                  style: AppTextStyles.labelLarge
                                      .copyWith(
                                          color: AppColors.statusText(
                                              h.status))),
                              if (h.timestamp != null)
                                Text(
                                  DateFormat('d MMM yyyy, HH:mm')
                                      .format(h.timestamp!),
                                  style: AppTextStyles.caption,
                                ),
                            ],
                          ),
                          if (h.changedBy != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'by ${h.changedBy!.name}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                          if (h.note != null && h.note!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(h.note!,
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'resubmitted':
        return Icons.send_rounded;
      case 'under review':
        return Icons.visibility_outlined;
      case 'approved':
        return Icons.check_rounded;
      case 'rejected':
        return Icons.close_rounded;
      case 'waiting for bills':
        return Icons.receipt_long_outlined;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.edit_outlined;
    }
  }
}

class ProposalHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProposalHistoryController>(() => ProposalHistoryController());
  }
}
