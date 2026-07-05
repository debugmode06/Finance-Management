import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/proposal_model.dart';
import 'proposal_detail_controller.dart';

class ProposalDetailView extends GetView<ProposalDetailController> {
  const ProposalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Proposal Details'),
        actions: [
          Obx(() {
            final p = controller.proposal.value;
            if (p == null) return const SizedBox.shrink();
            if (controller.isDirector && p.isEditable) {
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await Get.toNamed(
                    AppRoutes.proposalEdit.replaceFirst(':id', p.id),
                    arguments: {'proposal': p},
                  );
                  controller.loadProposal();
                },
              );
            }
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.history_rounded),
                  onPressed: () => Get.toNamed(
                    AppRoutes.proposalHistory.replaceFirst(':id', p.id),
                    arguments: {'id': p.id},
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = controller.proposal.value;
        if (p == null) {
          return const Center(child: Text('Proposal not found'));
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(p),
                    const SizedBox(height: 16),
                    if (p.isRejected) _buildRejectionBanner(p),
                    _buildDetailsCard(p),
                    const SizedBox(height: 16),
                    _buildBudgetCard(p),
                    const SizedBox(height: 16),
                    if (p.isWaitingForBills || p.isCompleted)
                      _buildBillsSection(p),
                    const SizedBox(height: 16),
                    _buildCommentsSection(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildActionBar(context, p),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(ProposalModel p) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(p.title, style: AppTextStyles.headlineLarge),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: p.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(p.eventName,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.business_outlined, p.department),
              _chip(Icons.flag_outlined, p.priority),
              _chip(Icons.event_outlined,
                  DateFormat('d MMM yyyy').format(p.requiredDate)),
              if (p.createdBy != null)
                _chip(Icons.person_outline_rounded, p.createdBy!.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionBanner(ProposalModel p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rejection Reason',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.danger)),
                  const SizedBox(height: 4),
                  Text(p.rejectionReason ?? 'No reason provided',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.danger)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(ProposalModel p) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(p.description,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          if (p.purpose.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Purpose', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(p.purpose,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
          if (p.notes != null && p.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Notes', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(p.notes!,
                style: AppTextStyles.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildBudgetCard(ProposalModel p) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Budget Summary', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          _budgetRow('Requested Budget',
              'RM ${p.requestedBudget.toStringAsFixed(2)}',
              color: AppColors.textPrimary),
          if (p.approvedBudget != null) ...[
            const SizedBox(height: 8),
            _budgetRow('Approved Budget',
                'RM ${p.approvedBudget!.toStringAsFixed(2)}',
                color: AppColors.success),
          ],
          if (p.actualExpense > 0) ...[
            const SizedBox(height: 8),
            _budgetRow(
                'Actual Expense', 'RM ${p.actualExpense.toStringAsFixed(2)}',
                color: AppColors.textPrimary),
          ],
          if (p.remainingBudget != null) ...[
            const Divider(height: 24),
            _budgetRow('Remaining',
                'RM ${p.remainingBudget!.abs().toStringAsFixed(2)}',
                color: p.isOverBudget ? AppColors.danger : AppColors.success,
                bold: true),
            if (p.isOverBudget)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.warning_outlined,
                        color: AppColors.danger, size: 16),
                    const SizedBox(width: 6),
                    Text('Over budget!',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.danger)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillsSection(ProposalModel p) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bills & Receipts', style: AppTextStyles.headlineSmall),
              if (controller.isDirector && p.isWaitingForBills)
                TextButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.proposalBills.replaceFirst(':id', p.id),
                    arguments: {'id': p.id},
                  ),
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Upload'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (p.bills.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No bills uploaded yet',
            )
          else
            ...p.bills.map((bill) => _BillTile(bill: bill,
                proposalId: p.id,
                isFinanceDirector: controller.isFinanceDirector,
                onVerified: () {
                  controller.loadProposal();
                })),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Discussion', style: AppTextStyles.headlineSmall),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingComments.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              ...controller.comments.map((c) => _CommentBubble(comment: c)),
              const SizedBox(height: 12),
              // Comment input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.commentCtrl,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.primaryShadow,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: controller.postComment,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context, ProposalModel p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final loading = controller.isActioning.value;
        // Director actions
        if (controller.isDirector) {
          if (p.isDraft) {
            return AppButton(
              label: 'Submit for Review',
              icon: Icons.send_rounded,
              isLoading: loading,
              onPressed: () => controller.submit(),
            );
          }
          if (p.isRejected) {
            return AppButton(
              label: 'Edit & Resubmit',
              icon: Icons.edit_outlined,
              isLoading: loading,
              onPressed: () async {
                await Get.toNamed(
                  AppRoutes.proposalEdit.replaceFirst(':id', p.id),
                  arguments: {'proposal': p},
                );
                controller.loadProposal();
              },
            );
          }
          if (p.isWaitingForBills) {
            return AppButton(
              label: 'Upload Bills',
              icon: Icons.upload_rounded,
              isLoading: loading,
              onPressed: () => Get.toNamed(
                AppRoutes.proposalBills.replaceFirst(':id', p.id),
                arguments: {'id': p.id},
              ),
            );
          }
        }

        // Finance Director actions
        if (controller.isFinanceDirector) {
          if (p.isSubmitted || p.isResubmitted) {
            return Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reject',
                    variant: AppButtonVariant.destructive,
                    isLoading: loading,
                    onPressed: () => controller.showRejectSheet(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Approve',
                    isLoading: loading,
                    onPressed: () => controller.showApproveSheet(context),
                  ),
                ),
              ],
            );
          }
          if (p.isWaitingForBills) {
            final allVerified = p.bills.isNotEmpty &&
                p.bills.every((b) =>
                    b.verificationStatus == 'Verified' ||
                    b.verificationStatus == 'Completed');
            return AppButton(
              label: 'Mark as Completed',
              icon: Icons.task_alt_rounded,
              isLoading: loading,
              onPressed: allVerified
                  ? () => controller.complete()
                  : null,
            );
          }
        }

        // View history — always available
        return AppButton(
          label: 'View Proposal History',
          variant: AppButtonVariant.ghost,
          icon: Icons.history_rounded,
          onPressed: () => Get.toNamed(
            AppRoutes.proposalHistory.replaceFirst(':id', p.id),
            arguments: {'id': p.id},
          ),
        );
      }),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textTertiary),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _budgetRow(String label, String amount,
      {Color? color, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(amount,
            style: (bold ? AppTextStyles.headlineSmall : AppTextStyles.labelLarge)
                .copyWith(color: color ?? AppColors.textPrimary)),
      ],
    );
  }
}

class _BillTile extends StatelessWidget {
  final BillModel bill;
  final String proposalId;
  final bool isFinanceDirector;
  final VoidCallback onVerified;

  const _BillTile({
    required this.bill,
    required this.proposalId,
    required this.isFinanceDirector,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (bill.verificationStatus) {
      case 'Verified':
      case 'Completed':
        statusColor = AppColors.success;
        break;
      case 'Need Correction':
        statusColor = AppColors.danger;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_outlined, color: AppColors.primary, size: 20),
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
                Text('RM ${bill.amount.toStringAsFixed(2)} • ${bill.verificationStatus}',
                    style: AppTextStyles.caption.copyWith(color: statusColor)),
              ],
            ),
          ),
          if (isFinanceDirector && bill.isPending)
            PopupMenuButton<String>(
              onSelected: (action) async {
                // Mark verify/correction
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'verify', child: Text('Verify')),
                const PopupMenuItem(
                    value: 'correction', child: Text('Need Correction')),
              ],
              icon: const Icon(Icons.more_vert, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final CommentModel comment;
  const _CommentBubble({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: comment.isFinanceDirector
                ? AppColors.primary
                : AppColors.primaryLight,
            child: Text(
              comment.author?.name[0].toUpperCase() ?? '?',
              style: AppTextStyles.labelMedium.copyWith(
                color: comment.isFinanceDirector
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author?.name ?? 'Unknown',
                        style: AppTextStyles.labelLarge),
                    const SizedBox(width: 8),
                    if (comment.isFinanceDirector)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Finance Director',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.primary)),
                      ),
                    const Spacer(),
                    if (comment.createdAt != null)
                      Text(
                        DateFormat('d MMM, HH:mm').format(comment.createdAt!),
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(comment.message,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
