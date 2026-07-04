class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';

  // Admin
  static const adminDashboard = '/admin/dashboard';
  static const directors = '/admin/directors';
  static const directorCreate = '/admin/directors/create';
  static const directorDetail = '/admin/directors/:id';

  // Proposals
  static const proposals = '/proposals';
  static const proposalCreate = '/proposals/create';
  static const proposalDetail = '/proposals/:id';
  static const proposalEdit = '/proposals/:id/edit';
  static const proposalBills = '/proposals/:id/bills';
  static const proposalHistory = '/proposals/:id/history';

  // Director
  static const directorDashboard = '/director/dashboard';

  // Shared
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const reports = '/reports';
}
