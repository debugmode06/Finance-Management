import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/proposal_model.dart';
import 'proposals_list_controller.dart';

class ProposalsListView extends GetView<ProposalsListController> {
  const ProposalsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Proposals'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildFilterChips(),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.errorMessage.value != null) {
                return Center(
                    child: Text(controller.errorMessage.value!,
                        style: AppTextStyles.bodySmall));
              }
              if (controller.proposals.isEmpty) {
                return EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No proposals found',
                  subtitle: 'No proposals match your current filters',
                  actionLabel: 'Clear Filters',
                  onAction: () {
                    controller.selectedStatus.value = null;
                    controller.searchQuery.value = '';
                    controller.refresh();
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: () async => controller.refresh(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.proposals.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == controller.proposals.length) {
                      controller.fetchProposals();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _ProposalCard(proposal: controller.proposals[i]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.proposalCreate);
          if (result == true) controller.refresh();
        },
        backgroundColor: AppColors.primary,
        label: Text('New Proposal',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        elevation: 0,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        decoration: InputDecoration(
          hintText: 'Search proposals...',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = ['All', ...AppConstants.proposalStatuses];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            children: statuses.map((s) {
              final isAll = s == 'All';
              final selected = isAll
                  ? controller.selectedStatus.value == null
                  : controller.selectedStatus.value == s;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (_) =>
                      controller.setStatus(isAll ? null : s),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final ProposalModel proposal;
  const _ProposalCard({required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () async {
          await Get.toNamed(
            AppRoutes.proposalDetail.replaceFirst(':id', proposal.id),
            arguments: {'id': proposal.id},
          );
          Get.find<ProposalsListController>().refresh();
        },
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(proposal.title,
                      style: AppTextStyles.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: proposal.status, compact: true),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.business_outlined,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(proposal.department,
                        style: AppTextStyles.bodySmall),
                  ],
                ),
                if (proposal.createdBy != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(proposal.createdBy!.name,
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'RM ${proposal.requestedBudget.toStringAsFixed(2)}',
                    style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.event_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('d MMM yyyy').format(proposal.requiredDate),
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
