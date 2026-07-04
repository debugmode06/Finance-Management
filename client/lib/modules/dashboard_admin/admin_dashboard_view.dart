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
import 'admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: RefreshIndicator(
        onRefresh: controller.loadDashboard,
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
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good day! 👋',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      const Text('Dashboard',
                          style: AppTextStyles.displayMedium),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(() => Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.notifications_outlined,
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
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${controller.unreadNotifications.value}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
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
              label: 'Total Directors',
              value: '${controller.totalDirectors.value}',
              color: AppColors.primary,
              icon: Icons.people_outline_rounded,
              onTap: () => Get.toNamed(AppRoutes.directors),
            ),
            StatCard(
              label: 'Total Proposals',
              value: '${controller.totalProposals.value}',
              color: AppColors.info,
              icon: Icons.description_outlined,
              onTap: () => Get.toNamed(AppRoutes.proposals),
            ),
            StatCard(
              label: 'Pending Review',
              value: '${(counts['Submitted'] ?? 0) + (counts['Resubmitted'] ?? 0)}',
              color: AppColors.warning,
              icon: Icons.pending_outlined,
              onTap: () => Get.toNamed(AppRoutes.proposals,
                  arguments: {'status': 'Submitted,Resubmitted'}),
            ),
            StatCard(
              label: 'Approved',
              value: '${counts['Approved'] ?? 0}',
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
              color: AppColors.success,
              icon: Icons.task_alt_rounded,
              onTap: () => Get.toNamed(AppRoutes.proposals,
                  arguments: {'status': 'Completed'}),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.people_alt_outlined,
                  label: 'Manage\nDirectors',
                  color: AppColors.primary,
                  onTap: () => Get.toNamed(AppRoutes.directors),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.description_outlined,
                  label: 'All\nProposals',
                  color: AppColors.info,
                  onTap: () => Get.toNamed(AppRoutes.proposals),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Export\nReports',
                  color: AppColors.success,
                  onTap: () => Get.toNamed(AppRoutes.reports),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Activity', style: AppTextStyles.headlineSmall),
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
              return const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No recent activity',
              );
            }
            return Column(
              children: controller.recentProposals
                  .map((p) => _ProposalListTile(proposal: p))
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
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
              Get.toNamed(AppRoutes.directors);
              break;
            case 3:
              Get.toNamed(AppRoutes.reports);
              break;
            case 4:
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
              icon: Icon(Icons.people_outline_rounded), label: 'Directors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ProposalListTile extends StatelessWidget {
  final ProposalModel proposal;
  const _ProposalListTile({required this.proposal});

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
                  Text(
                    '${proposal.department} • ${proposal.createdBy?.name ?? 'Unknown'}',
                    style: AppTextStyles.bodySmall,
                  ),
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
              child: Icon(
                Icons.event_rounded,
                color: isUrgent ? AppColors.danger : AppColors.warning,
              ),
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
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM yyyy').format(proposal.requiredDate),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isUrgent ? AppColors.dangerLight : AppColors.warningLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                daysLeft == 0
                    ? 'Today'
                    : daysLeft < 0
                        ? 'Overdue'
                        : '$daysLeft days',
                style: AppTextStyles.caption.copyWith(
                  color: isUrgent ? AppColors.danger : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
