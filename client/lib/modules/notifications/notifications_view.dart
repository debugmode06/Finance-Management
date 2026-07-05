import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/comment_model.dart';
import '../../data/providers/notification_provider.dart';
import '../../app/routes/app_routes.dart';

class NotificationsController extends GetxController {
  final _provider = NotificationProvider();
  final isLoading = true.obs;
  final notifications = <NotificationModel>[].obs;
  int _page = 1;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications({bool reset = false}) async {
    if (reset) {
      _page = 1;
      notifications.clear();
      hasMore.value = true;
    }
    if (_page == 1) isLoading.value = true;
    try {
      final res = await _provider.getNotifications(page: _page);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'] as List<dynamic>;
        final fetched = data
            .map((n) =>
                NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList();
        notifications.addAll(fetched);
        _page++;
        final meta = res.data['meta'];
        if (meta != null && notifications.length >= (meta['total'] ?? 0)) {
          hasMore.value = false;
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(String id) async {
    await _provider.markRead(id);
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      notifications[idx] =
          NotificationModel.fromJson({...notifications[idx].toJson(), 'isRead': true});
    }
  }

  Future<void> markAllRead() async {
    await _provider.markAllRead();
    loadNotifications(reset: true);
  }
}

extension _NM on NotificationModel {
  Map<String, dynamic> toJson() => {
        '_id': id,
        'type': type,
        'title': title,
        'message': message,
        'relatedProposalId': relatedProposalId,
        'isRead': isRead,
        'createdAt': createdAt?.toIso8601String(),
      };
}


class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: Text('Mark all read',
                style:
                    AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications',
            subtitle: 'You are all caught up!',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => controller.loadNotifications(reset: true),
          color: AppColors.primary,
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: controller.notifications.length,
            itemBuilder: (_, i) {
              final n = controller.notifications[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  onTap: () async {
                    if (!n.isRead) controller.markRead(n.id);
                    if (n.relatedProposalId != null) {
                      await Get.toNamed(
                        AppRoutes.proposalDetail
                            .replaceFirst(':id', n.relatedProposalId!),
                        arguments: {'id': n.relatedProposalId},
                      );
                    }
                  },
                  color: n.isRead ? AppColors.background : AppColors.primaryLight.withValues(alpha: 0.4),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _notifColor(n.type).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_notifIcon(n.type),
                            color: _notifColor(n.type), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title,
                                style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: n.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(n.message,
                                style: AppTextStyles.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            if (n.createdAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _timeAgo(n.createdAt!),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _notifColor(String type) {
    switch (type) {
      case 'proposal_approved':
        return AppColors.success;
      case 'proposal_rejected':
        return AppColors.danger;
      case 'proposal_submitted':
      case 'proposal_resubmitted':
        return AppColors.primary;
      case 'bills_uploaded':
        return AppColors.warning;
      case 'reminder':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'proposal_approved':
        return Icons.check_circle_outline_rounded;
      case 'proposal_rejected':
        return Icons.cancel_outlined;
      case 'proposal_submitted':
      case 'proposal_resubmitted':
        return Icons.send_rounded;
      case 'bills_uploaded':
        return Icons.receipt_long_outlined;
      case 'reminder':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }
}
