import 'package:get/get.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/dashboard_admin/admin_dashboard_view.dart';
import '../../modules/dashboard_admin/admin_dashboard_binding.dart';
import '../../modules/dashboard_director/director_dashboard_view.dart';
import '../../modules/dashboard_director/director_dashboard_binding.dart';
import '../../modules/directors/list/directors_list_view.dart';
import '../../modules/directors/list/directors_list_binding.dart';
import '../../modules/directors/create_edit/director_create_edit_view.dart';
import '../../modules/directors/create_edit/director_create_edit_binding.dart';
import '../../modules/directors/detail/director_detail_view.dart';
import '../../modules/directors/detail/director_detail_binding.dart';
import '../../modules/proposals/list/proposals_list_view.dart';
import '../../modules/proposals/list/proposals_list_binding.dart';
import '../../modules/proposals/create_edit/proposal_create_edit_view.dart';
import '../../modules/proposals/create_edit/proposal_create_edit_binding.dart';
import '../../modules/proposals/detail/proposal_detail_view.dart';
import '../../modules/proposals/detail/proposal_detail_binding.dart';
import '../../modules/proposals/bills/proposal_bills_view.dart';
import '../../modules/proposals/bills/proposal_bills_binding.dart';
import '../../modules/proposals/history/proposal_history_view.dart';
import '../../modules/notifications/notifications_view.dart';
import '../../modules/notifications/notifications_binding.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/reports/reports_view.dart';
import '../../modules/reports/reports_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.directorDashboard,
      page: () => const DirectorDashboardView(),
      binding: DirectorDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.directors,
      page: () => const DirectorsListView(),
      binding: DirectorsListBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.directorCreate,
      page: () => const DirectorCreateEditView(),
      binding: DirectorCreateEditBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.directorDetail,
      page: () => const DirectorDetailView(),
      binding: DirectorDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.proposals,
      page: () => const ProposalsListView(),
      binding: ProposalsListBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.proposalCreate,
      page: () => const ProposalCreateEditView(),
      binding: ProposalCreateEditBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.proposalDetail,
      page: () => const ProposalDetailView(),
      binding: ProposalDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.proposalEdit,
      page: () => const ProposalCreateEditView(),
      binding: ProposalCreateEditBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.proposalBills,
      page: () => const ProposalBillsView(),
      binding: ProposalBillsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.proposalHistory,
      page: () => const ProposalHistoryView(),
      binding: ProposalHistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
