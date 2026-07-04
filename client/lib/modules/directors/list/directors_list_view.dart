import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/user_model.dart';
import 'directors_list_controller.dart';

class DirectorsListView extends GetView<DirectorsListController> {
  const DirectorsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Directors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () async {
              await Get.toNamed(AppRoutes.directorCreate);
              controller.refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search directors...',
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
          // ── Filters ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    _filterChip('All', null,
                        controller.selectedActive.value == null),
                    const SizedBox(width: 8),
                    _filterChip('Active', 'true',
                        controller.selectedActive.value == 'true'),
                    const SizedBox(width: 8),
                    _filterChip('Inactive', 'false',
                        controller.selectedActive.value == 'false'),
                  ],
                )),
          ),
          const SizedBox(height: 8),
          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.directors.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'No directors found',
                  subtitle: 'Add directors to get started',
                  actionLabel: 'Add Director',
                  onAction: () => Get.toNamed(AppRoutes.directorCreate),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => controller.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: controller.directors.length,
                  itemBuilder: (_, i) =>
                      _DirectorTile(user: controller.directors[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? value, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        controller.selectedActive.value = value;
        controller.refresh();
      },
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _DirectorTile extends StatelessWidget {
  final UserModel user;
  const _DirectorTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<DirectorsListController>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: () async {
          await Get.toNamed(
            AppRoutes.directorDetail.replaceFirst(':id', user.id),
            arguments: {'id': user.id},
          );
          ctrl.refresh();
        },
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user.profileImage != null
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Text(user.name[0].toUpperCase(),
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.primary))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 2),
                  Text(user.department ?? '',
                      style: AppTextStyles.bodySmall),
                  Text(user.email,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary)),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive
                        ? AppColors.successLight
                        : AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Inactive',
                    style: AppTextStyles.caption.copyWith(
                      color:
                          user.isActive ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
