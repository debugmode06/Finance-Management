class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
  // For iOS simulator: http://localhost:5000/api/v1
  // For physical device: http://YOUR_LAN_IP:5000/api/v1

  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  static const String roleFinanceDirector = 'finance_director';
  static const String roleDirector = 'director';

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;

  static const List<String> departments = [
    'Technical Activities',
    'Media & Communication',
    'Events & Outreach',
    'Professional Development',
    'Entrepreneurship',
    'Club',
  ];

  static const List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

  static const List<String> proposalStatuses = [
    'Draft',
    'Submitted',
    'Under Review',
    'Approved',
    'Rejected',
    'Resubmitted',
    'Waiting for Bills',
    'Completed',
  ];
}
