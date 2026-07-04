class AppEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String logout = '/auth/logout';

  // Users
  static const String users = '/users';
  static const String myProfile = '/users/me';
  static String userById(String id) => '/users/$id';
  static String activateUser(String id) => '/users/$id/activate';
  static String deactivateUser(String id) => '/users/$id/deactivate';
  static String resetPassword(String id) => '/users/$id/reset-password';

  // Proposals
  static const String proposals = '/proposals';
  static const String dashboardStats = '/proposals/dashboard-stats';
  static const String directorStats = '/proposals/director-stats';
  static String proposalById(String id) => '/proposals/$id';
  static String submitProposal(String id) => '/proposals/$id/submit';
  static String approveProposal(String id) => '/proposals/$id/approve';
  static String rejectProposal(String id) => '/proposals/$id/reject';
  static String resubmitProposal(String id) => '/proposals/$id/resubmit';
  static String completeProposal(String id) => '/proposals/$id/complete';
  static String uploadBills(String id) => '/proposals/$id/bills';
  static String verifyBills(String id) => '/proposals/$id/bills/verify';
  static String proposalHistory(String id) => '/proposals/$id/history';
  static String proposalActivity(String id) => '/proposals/$id/activity';

  // Comments
  static String comments(String proposalId) => '/proposals/$proposalId/comments';

  // Notifications
  static const String notifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static String markRead(String id) => '/notifications/$id/read';

  // Reports
  static const String exportReport = '/reports/export';
}
