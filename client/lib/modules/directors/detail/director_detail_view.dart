import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import 'director_detail_controller.dart';

class DirectorDetailView extends GetView<DirectorDetailController> {
  const DirectorDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Director Profile'),
        actions: [
          Obx(() => controller.user.value != null
              ? IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    await Get.toNamed(
                      AppRoutes.directorCreate,
                      arguments: {'user': controller.user.value},
                    );
                    controller.loadDirector();
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final u = controller.user.value;
        if (u == null) {
          return const Center(child: Text('User not found'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Avatar ────────────────────────────────────────────
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    u.profileImage != null ? NetworkImage(u.profileImage!) : null,
                child: u.profileImage == null
                    ? Text(u.name[0].toUpperCase(),
                        style: AppTextStyles.displayLarge
                            .copyWith(color: AppColors.primary))
                    : null,
              ),
              const SizedBox(height: 16),
              Text(u.name, style: AppTextStyles.headlineLarge),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: u.isActive ? AppColors.successLight : AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  u.isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: u.isActive ? AppColors.success : AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Info Card ─────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _infoRow(Icons.mail_outline_rounded, 'Email', u.email),
                    const Divider(height: 24),
                    _infoRow(Icons.business_outlined, 'Department',
                        u.department ?? 'N/A'),
                    const Divider(height: 24),
                    _infoRow(Icons.phone_outlined, 'Phone',
                        u.phone ?? 'Not set'),
                    const Divider(height: 24),
                    _infoRow(Icons.badge_outlined, 'Role',
                        u.role.replaceAll('_', ' ').toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Actions ───────────────────────────────────────────
              AppButton(
                label: u.isActive ? 'Deactivate Account' : 'Activate Account',
                variant: u.isActive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.secondary,
                isLoading: controller.isActioning.value,
                onPressed: controller.toggleActive,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Reset Password',
                variant: AppButtonVariant.ghost,
                icon: Icons.lock_reset_rounded,
                onPressed: () => controller.resetPasswordDialog(context),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Delete Director',
                variant: AppButtonVariant.destructive,
                icon: Icons.delete_outline_rounded,
                isLoading: controller.isActioning.value,
                onPressed: () async {
                  final confirm = await showConfirmSheet(
                    context: context,
                    title: 'Delete Director',
                    message:
                        'Are you sure you want to permanently remove ${u.name}? This action cannot be undone.',
                    confirmLabel: 'Delete',
                    confirmColor: AppColors.danger,
                  );
                  if (confirm == true) controller.delete();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textTertiary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.labelLarge),
          ],
        ),
      ],
    );
  }
}
