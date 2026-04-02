class OpsConstants {
  OpsConstants._();

  static const appName    = 'Jan Sampark Ops';
  static const appVersion = '1.0.0';

  // API
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  // Storage keys
  static const keyAccessToken  = 'ops_access_token';
  static const keyRefreshToken = 'ops_refresh_token';
  static const keyUserId       = 'ops_user_id';
  static const keyRole         = 'ops_role';
  static const keyFullName     = 'ops_full_name';

  // Endpoints
  static const endpointLogin         = '/auth/login';
  static const endpointMe            = '/users/me';
  static const endpointCorporators   = '/corporators';
  static const endpointAreas         = '/master/areas';
  static const endpointWards         = '/master/wards';
  static const endpointCategories    = '/master/complaint-categories';
  static const endpointHelpline      = '/master/helpline';
  static const endpointAnalytics     = '/analytics/platform';
  static const endpointComplaints    = '/complaints';
  static const endpointUsers         = '/users';

  // Pagination
  static const defaultPageSize = 20;
}