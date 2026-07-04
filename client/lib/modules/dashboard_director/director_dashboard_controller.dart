import 'package:get/get.dart';
import '../../data/providers/proposal_provider.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/models/proposal_model.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../app/routes/app_routes.dart';

class DirectorDashboardController extends GetxController {
  final _proposalProvider = ProposalProvider();
  final _notificationProvider = NotificationProvider();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final statusCounts = <String, int>{}.obs;
  final totalProposals = 0.obs;
  final recentProposals = <ProposalModel>[].obs;
  final upcomingDeadlines = <ProposalModel>[].obs;
  final unreadNotifications = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadUnreadCount();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _proposalProvider.getDirectorStats();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        totalProposals.value = data['totalProposals'] ?? 0;

        final stats = data['proposalStats'] as Map<String, dynamic>? ?? {};
        statusCounts.value = stats.map((k, v) => MapEntry(k, (v as num).toInt()));

        final recent = data['recentProposals'] as List<dynamic>? ?? [];
        recentProposals.value = recent
            .map((p) => ProposalModel.fromJson(p as Map<String, dynamic>))
            .toList();

        final deadlines = data['upcomingDeadlines'] as List<dynamic>? ?? [];
        upcomingDeadlines.value = deadlines
            .map((p) => ProposalModel.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final response = await _notificationProvider.getNotifications(limit: 1);
      if (response.statusCode == 200) {
        unreadNotifications.value =
            response.data['meta']?['unreadCount'] ?? 0;
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    await SecureStorageService.deleteAll();
    Get.offAllNamed(AppRoutes.login);
  }

  int getStatusCount(String status) => statusCounts[status] ?? 0;
}
