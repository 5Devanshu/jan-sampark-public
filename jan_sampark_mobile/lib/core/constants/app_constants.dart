/// Application-wide constants.
///
/// API base URL, app metadata, timeout values,
/// storage keys, pagination defaults.
///
/// Never hardcode these values anywhere else.
class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // App Metadata
  // ─────────────────────────────────────────────

  static const String appName = 'Jan Sampark';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Voice, Your Ward';

  // ─────────────────────────────────────────────
  // API Configuration
  // ─────────────────────────────────────────────

  /// Change this to your backend server address.
  /// For Android emulator use 10.0.2.2 instead of localhost.
  /// For iOS simulator localhost works directly.
  static const String baseUrl = 'http://localhost:8000/api/v1';

  /// Connection timeout in milliseconds
  static const int connectTimeoutMs = 10000; // 10 seconds

  /// Receive timeout in milliseconds
  static const int receiveTimeoutMs = 30000; // 30 seconds

  /// Send timeout for file uploads in milliseconds
  static const int sendTimeoutMs = 60000; // 60 seconds

  // ─────────────────────────────────────────────
  // API Endpoint Paths
  // ─────────────────────────────────────────────

  // Auth
  static const String endpointSendOtp = '/auth/register/send-otp';
  static const String endpointVerifyOtp = '/auth/register/verify-otp';
  static const String endpointRegister = '/auth/register/complete';
  static const String endpointLogin = '/auth/login';
  static const String endpointRefresh = '/auth/refresh';
  static const String endpointLogout = '/auth/logout';
  static const String endpointMe = '/auth/me';
  static const String endpointProfessions = '/auth/professions';

  // Users
  static const String endpointProfile = '/users/profile';
  static const String endpointProfilePhoto = '/users/profile/photo';
  static const String endpointVoters = '/users/voters';
  static const String endpointLeaders = '/users/leaders';
  static const String endpointCorporators = '/users/corporators';

  // Areas & Wards
  static const String endpointAreas = '/areas';
  static const String endpointWards = '/wards';

  // Complaint Categories
  static const String endpointComplaintCategories = '/complaint-categories';

  // Complaints
  static const String endpointComplaints = '/complaints';

  // Campaigns & Donations
  static const String endpointCampaigns = '/campaigns';
  static const String endpointDonations = '/donations';

  // Events
  static const String endpointEvents = '/events';

  // Chats
  static const String endpointChats = '/chats';

  // Announcements
  static const String endpointAnnouncements = '/announcements';

  // Polls
  static const String endpointPolls = '/polls';

  // Helpline
  static const String endpointHelpline = '/helpline-numbers';

  // Voter Verification
  static const String endpointVoterCaptcha = '/voter/captcha';
  static const String endpointVoterSearchEpic = '/voter/search-epic';
  static const String endpointVoterSearchDetails = '/voter/search-details';
  static const String endpointVoterSave = '/voter/save';
  static const String endpointVoterVerifyStatus = '/voter/verification-status';

  // Notifications
  static const String endpointNotifications = '/notifications';
  static const String endpointUnreadCount = '/notifications/unread-count';
  static const String endpointReadAll = '/notifications/read-all';

  // OCR
  static const String endpointOcrStatus = '/ocr/status';
  static const String endpointOcrRetry = '/ocr/retry';

  // Analytics
  static const String endpointAnalyticsCorporator = '/analytics/corporator';
  static const String endpointAnalyticsOps = '/analytics/ops';

  // ─────────────────────────────────────────────
  // Secure Storage Keys
  // ─────────────────────────────────────────────

  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  // ─────────────────────────────────────────────
  // Shared Preferences Keys
  // ─────────────────────────────────────────────

  static const String prefLanguage = 'pref_language';
  static const String prefOnboardingDone = 'pref_onboarding_done';
  static const String prefLastKnownRole = 'pref_last_known_role';
  static const String prefUserFullName = 'pref_user_full_name';
  static const String prefNotifPermAsked = 'pref_notif_perm_asked';

  // ─────────────────────────────────────────────
  // Pagination Defaults
  // ─────────────────────────────────────────────

  static const int defaultPageSize = 20;
  static const int defaultPageSizeLarge = 50;

  // ─────────────────────────────────────────────
  // OTP
  // ─────────────────────────────────────────────

  static const int otpLength = 6;
  static const int otpResendCooldownSecs = 60;
  static const int otpExpireMinutes = 10;

  // ─────────────────────────────────────────────
  // File Upload Limits
  // ─────────────────────────────────────────────

  static const int maxUploadSizeMb = 5;
  static const int maxComplaintImages = 3;

  // ─────────────────────────────────────────────
  // Registration Steps
  // ─────────────────────────────────────────────

  static const int registrationTotalSteps = 4;

  // ─────────────────────────────────────────────
  // Supported Languages
  // ─────────────────────────────────────────────

  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
    'gu': 'ગુજરાતી',
  };

  // ─────────────────────────────────────────────
  // Complaint Status Labels
  // ─────────────────────────────────────────────

  static const Map<String, String> complaintStatusLabels = {
    'pending': 'Pending',
    'acknowledged': 'Acknowledged',
    'in_progress': 'In Progress',
    'resolved': 'Resolved',
    'closed': 'Closed',
    'rejected': 'Rejected',
  };

  // ─────────────────────────────────────────────
  // Priority Labels
  // ─────────────────────────────────────────────

  static const Map<String, String> priorityLabels = {
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'emergency': 'Emergency',
  };

  // ─────────────────────────────────────────────
  // Donation Status Labels
  // ─────────────────────────────────────────────

  static const Map<String, String> donationStatusLabels = {
    'pending': 'Pending',
    'pending_review': 'Under Review',
    'accepted': 'Accepted',
    'rejected': 'Rejected',
  };

  // ─────────────────────────────────────────────
  // Announcement Category Labels
  // ─────────────────────────────────────────────

  static const Map<String, String> announcementCategoryLabels = {
    'announcement': 'Announcement',
    'policy': 'Policy',
    'scheme': 'Scheme',
    'achievement': 'Achievement',
    'party_message': 'Party Message',
  };

  // ─────────────────────────────────────────────
  // Asset Paths
  // ─────────────────────────────────────────────

  static const String assetLogo = 'assets/images/logo_jan_sampark.png';
  static const String assetLogoWhite =
      'assets/images/logo_jan_sampark_white.png';
  static const String assetLogoIcon = 'assets/images/logo_jan_sampark_icon.png';

  static const String assetEmptyComplaints =
      'assets/illustrations/empty_complaints.svg';
  static const String assetEmptyEvents =
      'assets/illustrations/empty_events.svg';
  static const String assetVerificationPending =
      'assets/illustrations/verification_pending.svg';
  static const String assetEpicVerified =
      'assets/illustrations/epic_verified.svg';

  static const String lottieSuccess = 'assets/lottie/success.json';
  static const String lottieLoading = 'assets/lottie/loading.json';
  static const String lottieEmpty = 'assets/lottie/empty.json';
}
