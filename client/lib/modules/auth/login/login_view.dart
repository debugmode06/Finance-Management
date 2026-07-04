import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ── Logo + Title ──────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.primaryShadow,
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('CSEA Finance', style: AppTextStyles.displayMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to continue',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 56),

              // ── Form ──────────────────────────────────────────────────
              Obx(() => AppTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline_rounded,
                    textCapitalization: TextCapitalization.none,
                    validator: (_) => controller.emailError.value,
                  )),

              const SizedBox(height: 16),

              Obx(() => AppTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: passCtrl,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                    textCapitalization: TextCapitalization.none,
                    validator: (_) => controller.passwordError.value,
                  )),

              const SizedBox(height: 32),

              // ── Sign In Button ─────────────────────────────────────────
              Obx(() => AppButton(
                    label: 'Sign In',
                    isLoading: controller.isLoading.value,
                    onPressed: () =>
                        controller.login(emailCtrl.text, passCtrl.text),
                    icon: Icons.arrow_forward_rounded,
                  )),

              const SizedBox(height: 40),

              // ── Credentials hint (dev mode) ───────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 6),
                        Text('Demo Credentials',
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _credRow('Finance Director', 'admin@csea.edu', 'Admin@1234'),
                    const SizedBox(height: 6),
                    _credRow('Director', 'ahmad@csea.edu', 'Director@1234'),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _credRow(String role, String email, String pass) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$role: $email / $pass',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
