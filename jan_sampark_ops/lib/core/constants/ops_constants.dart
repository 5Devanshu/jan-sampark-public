/// Application-wide constants for Jan Sampark Ops Console.
///
/// API base URL, app metadata, timeout values,
/// storage keys, pagination defaults.
///
/// Never hardcode these values anywhere else.
class OpsConstants {
  OpsConstants._();

  // ─────────────────────────────────────────────
  // App Metadata
  // ─────────────────────────────────────────────

  static const String appName = 'Jan Sampark Ops';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Operations Console';

  // ─────────────────────────────────────────────
  // API Configuration
  // ─────────────────────────────────────────────

  /// Change this to your backend server address.
  static const String baseUrl = 'http://localhost:8000/api/v1';

  /// Connection timeout in milliseconds
  static const int connectTimeoutMs = 10000; // 10 seconds

  /// Receive timeout in milliseconds
  static const int receiveTimeoutMs = 30000; // 30 seconds

  /// Send timeout for file uploads in milliseconds
  static const int sendTimeoutMs = 60000; // 60 seconds

  /// Sidebar breakpoint for responsive layout (pixels)
  static const double sidebarBreakpoint = 1024.0;

  // ─────────────────────────────────────────────
  // API Endpoint Paths
  // ─────────────────────────────────────────────

  // Auth
  static const String endpointLogin = '/auth/login';
  static const String endpointRefresh = '/auth/refresh';
  static const String endpointLogout = '/auth/logout';
  static const String endpointMe = '/auth/me';

  // Dashboard
  static const String endpointDashboard = '/dashboard';

  // Complaints
  static const String endpointComplaints = '/complaints';
  static const String endpointComplaintCategories = '/complaint-categories';
  static const String endpointCategories = '/complaint-categories';

  // Corporators
  static const String endpointCorporators = '/corporators';

  // Areas & Wards
  static const String endpointAreas = '/areas';
  static const String endpointWards = '/wards';

  // Analytics
  static const String endpointAnalytics = '/analytics';

  // Masters
  static const String endpointMasters = '/masters';
  static const String endpointHelpline = '/helpline-numbers';

  // Secure Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyRole = 'user_role';
  static const String keyUserName = 'user_name';
  static const String keyFullName = 'full_name';
  static const String keyMobile = 'mobile';

  // ─────────────────────────────────────────────
  // Pagination Defaults
  // ─────────────────────────────────────────────

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int defaultPage = 1;
}
