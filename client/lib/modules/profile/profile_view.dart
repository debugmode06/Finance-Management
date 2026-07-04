import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(title: const Text('My Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final u = controller.user.value;
        if (u == null) return const Center(child: Text('Profile not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Avatar ──────────────────────────────────────────────
              GestureDetector(
                onTap: controller.pickAndUploadAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: u.profileImage != null
                          ? NetworkImage(u.profileImage!)
                          : null,
                      child: u.profileImage == null
                          ? Text(u.name[0].toUpperCase(),
                              style: AppTextStyles.displayLarge
                                  .copyWith(color: AppColors.primary))
                          : null,
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_outlined,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(u.name, style: AppTextStyles.headlineLarge),
              Text(u.role.replaceAll('_', ' '),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              if (u.department != null)
                Text(u.department!,
                    style: AppTextStyles.bodySmall),
              const SizedBox(height: 28),

              // ── Edit profile ─────────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Details',
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Full Name',
                      controller: controller.nameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Email',
                      controller: TextEditingController(text: u.email),
                      enabled: false,
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Phone',
                      controller: controller.phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => AppButton(
                          label: 'Save Profile',
                          height: 48,
                          isLoading: controller.isSaving.value,
                          onPressed: controller.updateProfile,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Change password ──────────────────────────────────────
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Change Password',
                        style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Current Password',
                      controller: controller.currentPassCtrl,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'New Password',
                      controller: controller.newPassCtrl,
                      obscureText: true,
                      prefixIcon: Icons.lock_reset_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Confirm Password',
                      controller: controller.confirmPassCtrl,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => AppButton(
                          label: 'Change Password',
                          height: 48,
                          variant: AppButtonVariant.secondary,
                          isLoading: controller.isSaving.value,
                          onPressed: controller.changePassword,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Logout ───────────────────────────────────────────────
              AppButton(
                label: 'Sign Out',
                variant: AppButtonVariant.destructive,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  final confirm = await showConfirmSheet(
                    context: context,
                    title: 'Sign Out',
                    message: 'Are you sure you want to sign out?',
                    confirmLabel: 'Sign Out',
                    confirmColor: AppColors.danger,
                  );
                  if (confirm == true) controller.logout();
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
