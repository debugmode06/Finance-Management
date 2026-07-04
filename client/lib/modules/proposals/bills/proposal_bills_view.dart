import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/proposal_model.dart';
import 'proposal_bills_controller.dart';

class ProposalBillsView extends GetView<ProposalBillsController> {
  const ProposalBillsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('Bills & Receipts')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = controller.proposal.value;
        if (p == null) return const Center(child: Text('Not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing bills
              if (p.bills.isNotEmpty) ...[
                const Text('Uploaded Bills', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 8),
                ...p.bills.map((b) => _ExistingBillTile(
                      bill: b,
                      proposalId: p.id,
                      onVerify: (status, note) =>
                          controller.verifyBill(b.id, status, note),
                    )),
                const SizedBox(height: 24),
              ],

              // Upload new bills
              if (p.isWaitingForBills) ...[
                const Text('Upload New Bills', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Obx(() => controller.pickedFiles.isEmpty
                          ? GestureDetector(
                              onTap: controller.pickFile,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 32),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.border,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.cloud_upload_outlined,
                                        size: 40,
                                        color: AppColors.textTertiary),
                                    const SizedBox(height: 8),
                                    Text('Tap to upload receipts/bills',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textSecondary)),
                                    const Text('PDF, JPG, PNG',
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ...List.generate(
                                  controller.pickedFiles.length,
                                  (i) => _PickedFileTile(
                                    fileName: controller.pickedFiles[i].name,
                                    amountValue: controller.amounts[i],
                                    onAmountChanged: (v) =>
                                        controller.setAmount(i, v),
                                    onRemove: () => controller.removeFile(i),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: controller.pickFile,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add More'),
                                ),
                              ],
                            )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => AppButton(
                      label: 'Upload Bills',
                      icon: Icons.upload_rounded,
                      isLoading: controller.isUploading.value,
                      onPressed: controller.pickedFiles.isEmpty
                          ? null
                          : controller.uploadBills,
                    )),
              ],

              if (!p.isWaitingForBills && p.bills.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No bills yet',
                  subtitle: 'Bills can be uploaded after proposal approval',
                ),

              const SizedBox(height: 60),
            ],
          ),
        );
      }),
    );
  }
}

class _PickedFileTile extends StatelessWidget {
  final String fileName;
  final String amountValue;
  final void Function(String) onAmountChanged;
  final VoidCallback onRemove;

  const _PickedFileTile({
    required this.fileName,
    required this.amountValue,
    required this.onAmountChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                    style: AppTextStyles.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                SizedBox(
                  height: 36,
                  child: TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: onAmountChanged,
                    style: AppTextStyles.bodySmall,
                    decoration: const InputDecoration(
                      hintText: 'Amount (RM)',
                      prefixText: 'RM ',
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.danger, size: 18),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _ExistingBillTile extends StatelessWidget {
  final BillModel bill;
  final String proposalId;
  final void Function(String status, String? note) onVerify;

  const _ExistingBillTile({
    required this.bill,
    required this.proposalId,
    required this.onVerify,
  });

  Color get _statusColor {
    switch (bill.verificationStatus) {
      case 'Verified':
      case 'Completed':
        return AppColors.success;
      case 'Need Correction':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_outlined,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.fileName,
                      style: AppTextStyles.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      'RM ${bill.amount.toStringAsFixed(2)} • ${bill.verificationStatus}',
                      style: AppTextStyles.caption
                          .copyWith(color: _statusColor)),
                ],
              ),
            ),
            if (bill.isPending)
              PopupMenuButton<String>(
                onSelected: (action) async {
                  if (action == 'verify') {
                    onVerify('Verified', null);
                  } else {
                    final noteCtrl = TextEditingController();
                    final note = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Need Correction'),
                        content: TextField(
                          controller: noteCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Note'),
                          maxLines: 2,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, noteCtrl.text),
                              child: const Text('Submit')),
                        ],
                      ),
                    );
                    if (note != null) onVerify('Need Correction', note);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'verify', child: Text('✓ Verify')),
                  const PopupMenuItem(
                      value: 'correction', child: Text('⚠ Need Correction')),
                ],
                icon: const Icon(Icons.more_vert, color: AppColors.textTertiary),
              ),
          ],
        ),
      ),
    );
  }
}
