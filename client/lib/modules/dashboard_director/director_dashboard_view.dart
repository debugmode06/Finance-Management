import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/routes/app_routes.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/proposal_model.dart';
import 'director_dashboard_controller.dart';

class DirectorDashboardView extends GetView<DirectorDashboardController> {
  const DirectorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: RefreshIndicator(
        onRefresh: controller.loadStats,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildRecentProposals(),
                    const SizedBox(height: 24),
                    _buildUpcomingDeadlines(),
                    const SizedBox(height: 100),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.proposalCreate),
        backgroundColor: AppColors.primary,
        label: Text('New Proposal',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        elevation: 0,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Dashboard',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  const Text('Finance Proposals', style: AppTextStyles.displayMedium),
                ],
              ),
              Row(
                children: [
                  Obx(() => Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: AppColors.textPrimary),
                            onPressed: () =>
                                Get.toNamed(AppRoutes.notifications),
                          ),
                          if (controller.unreadNotifications.value > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Text(
                                    '${controller.unreadNotifications.value}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      )),
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.textPrimary),
                    onPressed: () => Get.toNamed(AppRoutes.profile),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final counts = controller.statusCounts;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            StatCard(
              label: 'My Proposals',
              value: '${controller.totalProposals.value}',
              color: AppColors.primary,
              icon: Icons.description_outlined,
              onTap: () => Get.toNamed(AppRoutes.proposals),
            ),
            StatCard(
              label: 'Pending',
              value: '${(counts['Submitted'] ?? 0) + (counts['Under Review'] ?? 0) + (counts['Resubmitted'] ?? 0)}',
              color: AppColors.warning,
              icon: Icons.pending_outlined,
              onTap: () => Get.toNamed(AppRoutes.proposals,
                  arguments: {'status': 'Submitted,Under Review,Resubmitted'}),
            ),
            StatCard(
              label: 'Approved',
              value: '${(counts['Approved'] ?? 0) + (counts['Waiting for Bills'] ?? 0)}',
              color: AppColors.success,
              icon: Icons.check_circle_outline_rounded,
              onTap: () => Get.toNamed(AppRoutes.proposals,
                  arguments: {'status': 'Approved'}),
            ),
            StatCard(
              label: 'Rejected',
              value: '${counts['Rejected'] ?? 0}',
              color: AppColors.danger,
              icon: Icons.cancel_outlined,
              onTap: () => Get.toNamed(AppRoutes.proposals,
                  arguments: {'status': 'Rejected'}),
            ),
            StatCard(
              label: 'Completed',
              value: '${counts['Completed'] ?? 0}',
              color: AppColors.info,
              icon: Icons.task_alt_rounded,
              onTap: () => Get.toNamed(AppRoutes.proposals,
                  arguments: {'status': 'Completed'}),
            ),
            StatCard(
              label: 'Drafts',
              value: '${counts['Draft'] ?? 0}',
              color: AppColors.textTertiary,
              icon: Icons.drafts_outlined,
              onTap: () =>
                  Get.toNamed(AppRoutes.proposals, arguments: {'status': 'Draft'}),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRecentProposals() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Recent Proposals', style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.proposals),
                child: Text('See All',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.recentProposals.isEmpty) {
              return EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No proposals yet',
                subtitle: 'Create your first finance proposal',
                actionLabel: 'New Proposal',
                onAction: () => Get.toNamed(AppRoutes.proposalCreate),
              );
            }
            return Column(
              children: controller.recentProposals
                  .map((p) => _ProposalTile(proposal: p))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming Deadlines', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.upcomingDeadlines.isEmpty) {
              return const EmptyState(
                icon: Icons.event_available_rounded,
                title: 'No upcoming deadlines',
              );
            }
            return Column(
              children: controller.upcomingDeadlines
                  .map((p) => _DeadlineTile(proposal: p))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 0:
              break;
            case 1:
              Get.toNamed(AppRoutes.proposals);
              break;
            case 2:
              Get.toNamed(AppRoutes.notifications);
              break;
            case 3:
              Get.toNamed(AppRoutes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined), label: 'Proposals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ProposalTile extends StatelessWidget {
  final ProposalModel proposal;
  const _ProposalTile({required this.proposal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => Get.toNamed(
          AppRoutes.proposalDetail.replaceFirst(':id', proposal.id),
          arguments: {'id': proposal.id},
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proposal.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('RM ${proposal.requestedBudget.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(status: proposal.status, compact: true),
          ],
        ),
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  final ProposalModel proposal;
  const _DeadlineTile({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final daysLeft = proposal.requiredDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 7;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () => Get.toNamed(
          AppRoutes.proposalDetail.replaceFirst(':id', proposal.id),
          arguments: {'id': proposal.id},
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.dangerLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.event_rounded,
                  color: isUrgent ? AppColors.danger : AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(proposal.title,
                      style: AppTextStyles.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                      DateFormat('d MMM yyyy').format(proposal.requiredDate),
                      style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.dangerLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                daysLeft <= 0 ? 'Overdue' : '$daysLeft days',
                style: AppTextStyles.caption.copyWith(
                    color: isUrgent ? AppColors.danger : AppColors.warning,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
