import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, destructive, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    Color bgColor;
    Color textColor;
    Color? borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = disabled ? AppColors.primary.withOpacity(0.5) : AppColors.primary;
        textColor = Colors.white;
        borderColor = null;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.primaryLight;
        textColor = AppColors.primary;
        borderColor = null;
        break;
      case AppButtonVariant.destructive:
        bgColor = disabled ? AppColors.danger.withOpacity(0.5) : AppColors.danger;
        textColor = Colors.white;
        borderColor = null;
        break;
      case AppButtonVariant.ghost:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        borderColor = AppColors.border;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
        boxShadow: variant == AppButtonVariant.primary && !disabled
            ? AppColors.primaryShadow
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.buttonLarge.copyWith(color: textColor),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
