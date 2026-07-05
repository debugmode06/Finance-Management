import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F7);
  static const Color backgroundTertiary = Color(0xFFEFEFF4);

  // ─── Primary ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A5FFF);
  static const Color primaryLight = Color(0xFFE8F0FF);
  static const Color primaryDark = Color(0xFF0040CC);

  // ─── Semantic ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFE8F8ED);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerLight = Color(0xFFFFEAE9);
  static const Color info = Color(0xFF5AC8FA);
  static const Color infoLight = Color(0xFFE5F7FF);

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Border / Divider ───────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E5EA);
  static const Color divider = Color(0xFFF2F2F7);
  static const Color separator = Color(0xFFC6C6C8);

  // ─── Status Badge Colors ────────────────────────────────────────────────────
  static Color statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFFF2F2F7);
      case 'submitted':
        return const Color(0xFFE5F7FF);
      case 'under review':
        return const Color(0xFFFFF4E5);
      case 'approved':
        return const Color(0xFFE8F8ED);
      case 'rejected':
        return const Color(0xFFFFEAE9);
      case 'resubmitted':
        return const Color(0xFFEEE9FF);
      case 'waiting for bills':
        return const Color(0xFFFFF4E5);
      case 'completed':
        return const Color(0xFFE8F8ED);
      default:
        return const Color(0xFFF2F2F7);
    }
  }

  static Color statusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(0xFF6E6E73);
      case 'submitted':
        return const Color(0xFF0A5FFF);
      case 'under review':
        return const Color(0xFFCC7700);
      case 'approved':
        return const Color(0xFF1A8F3C);
      case 'rejected':
        return const Color(0xFFCC1A15);
      case 'resubmitted':
        return const Color(0xFF6B3FAB);
      case 'waiting for bills':
        return const Color(0xFFCC7700);
      case 'completed':
        return const Color(0xFF1A8F3C);
      default:
        return const Color(0xFF6E6E73);
    }
  }

  static Color priorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return const Color(0xFFE8F8ED);
      case 'medium':
        return const Color(0xFFE5F7FF);
      case 'high':
        return const Color(0xFFFFF4E5);
      case 'urgent':
        return const Color(0xFFFFEAE9);
      default:
        return const Color(0xFFF2F2F7);
    }
  }

  static Color priorityText(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return const Color(0xFF1A8F3C);
      case 'medium':
        return const Color(0xFF0A5FFF);
      case 'high':
        return const Color(0xFFCC7700);
      case 'urgent':
        return const Color(0xFFCC1A15);
      default:
        return const Color(0xFF6E6E73);
    }
  }

  // ─── Shadow ─────────────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> mediumShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}
