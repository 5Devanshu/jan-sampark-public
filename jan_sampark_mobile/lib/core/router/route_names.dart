/// Named route constants used throughout the app.
///
/// Usage:
///   context.goNamed(RouteNames.login)
///   context.goNamed(RouteNames.complaintDetail,
///     pathParameters: {'id': complaintId})
class RouteNames {
  RouteNames._();

  // ─────────────────────────────────────────────
  // Auth
  // ─────────────────────────────────────────────

  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String otpSend = 'otp-send';
  static const String otpVerify = 'otp-verify';
  static const String register = 'register';

  // ─────────────────────────────────────────────
  // Voter Shell (Bottom Nav)
  // ─────────────────────────────────────────────

  static const String voterHome = 'voter-home';
  static const String voterComplaints = 'voter-complaints';
  static const String voterCampaigns = 'voter-campaigns';
  static const String voterEvents = 'voter-events';
  static const String voterProfile = 'voter-profile';

  // Voter — Complaint sub-routes
  static const String fileComplaint = 'file-complaint';
  static const String complaintDetail = 'complaint-detail';
  static const String complaintFeedback = 'complaint-feedback';

  // Voter — Campaign sub-routes
  static const String campaignDetail = 'campaign-detail';
  static const String donate = 'donate';
  static const String donationStatus = 'donation-status';

  // Voter — Event sub-routes
  static const String eventDetail = 'event-detail';
  static const String myRegistrations = 'my-registrations';

  // Voter — Profile sub-routes
  static const String editProfile = 'edit-profile';
  static const String voterOcrStatus = 'voter-ocr-status';
  static const String verificationIntro = 'verification-intro';
  static const String captchaScreen = 'captcha';
  static const String epicSearch = 'epic-search';
  static const String detailSearch = 'detail-search';
  static const String verificationResult = 'verification-result';
  static const String verificationSuccess = 'verification-success';

  // Voter — Chat sub-routes
  static const String voterChats = 'voter-chats';
  static const String voterChatRoom = 'voter-chat-room';

  // Voter — Announcements
  static const String voterAnnouncements = 'voter-announcements';
  static const String voterAnnouncementDetail = 'voter-announcement-detail';

  // Voter — Polls
  static const String voterPolls = 'voter-polls';
  static const String voterPollVote = 'voter-poll-vote';
  static const String voterPollResults = 'voter-poll-results';

  // Voter — Helpline
  static const String helpline = 'helpline';

  // ─────────────────────────────────────────────
  // Leader Shell (Bottom Nav)
  // ─────────────────────────────────────────────

  static const String leaderHome = 'leader-home';
  static const String leaderComplaints = 'leader-complaints';
  static const String leaderVoters = 'leader-voters';
  static const String leaderEvents = 'leader-events';
  static const String leaderProfile = 'leader-profile';

  // Leader — Complaint sub-routes
  static const String leaderComplaintDetail = 'leader-complaint-detail';
  static const String acknowledgeComplaint = 'acknowledge-complaint';
  static const String updateComplaintStatus = 'update-complaint-status';
  static const String escalateComplaint = 'escalate-complaint';
  static const String rejectComplaint = 'reject-complaint';
  static const String reassignComplaint = 'reassign-complaint';
  static const String addComplaintNote = 'add-complaint-note';
  static const String groundVerification = 'ground-verification';

  // Leader — Voter sub-routes
  static const String voterProfileView = 'voter-profile-view';

  // Leader — Event sub-routes
  static const String createEvent = 'create-event';
  static const String leaderEventManagement = 'leader-event-management';
  static const String attendanceScreen = 'attendance-screen';

  // Leader — Chat sub-routes
  static const String leaderChats = 'leader-chats';
  static const String createChat = 'create-chat';
  static const String leaderChatRoom = 'leader-chat-room';
  static const String chatAnalytics = 'chat-analytics';

  // Leader — Announcements
  static const String leaderAnnouncements = 'leader-announcements';
  static const String createLeaderAnnouncement = 'create-leader-announcement';
  static const String leaderAnnouncementDetail = 'leader-announcement-detail';

  // ─────────────────────────────────────────────
  // Corporator Shell (Bottom Nav)
  // ─────────────────────────────────────────────

  static const String corporatorHome = 'corporator-home';
  static const String corporatorComplaints = 'corporator-complaints';
  static const String corporatorAnalytics = 'corporator-analytics';
  static const String corporatorManage = 'corporator-manage';
  static const String corporatorProfile = 'corporator-profile';

  // Corporator — Complaint sub-routes
  static const String corporatorComplaintDetail = 'corp-complaint-detail';
  static const String resolveComplaint = 'resolve-complaint';
  static const String assignComplaint = 'assign-complaint';
  static const String escalatedInbox = 'escalated-inbox';

  // Corporator — Analytics sub-routes
  static const String voterAnalytics = 'voter-analytics';
  static const String complaintAnalytics = 'complaint-analytics';
  static const String campaignAnalytics = 'campaign-analytics';
  static const String eventAnalyticsScreen = 'event-analytics';
  static const String leaderAnalytics = 'leader-analytics';
  static const String wardHeatmap = 'ward-heatmap';

  // Corporator — Leaders
  static const String leadersManagement = 'leaders-management';
  static const String createLeader = 'create-leader';
  static const String leaderDetail = 'leader-detail';
  static const String editLeader = 'edit-leader';

  // Corporator — Campaigns
  static const String campaignManagement = 'campaign-management';
  static const String createCampaign = 'create-campaign';
  static const String corpCampaignDetail = 'corp-campaign-detail';
  static const String pendingDonations = 'pending-donations';
  static const String donationVerification = 'donation-verification';

  // Corporator — Events
  static const String eventsManagement = 'events-management';
  static const String corpCreateEvent = 'corp-create-event';
  static const String corpEventDetail = 'corp-event-detail';
  static const String attendanceManagement = 'attendance-management';

  // Corporator — Chats
  static const String chatsManagement = 'chats-management';
  static const String corpCreateChat = 'corp-create-chat';
  static const String corpChatRoom = 'corp-chat-room';
  static const String corpChatAnalytics = 'corp-chat-analytics';

  // Corporator — Announcements
  static const String announcementsManagement = 'announcements-management';
  static const String createAnnouncement = 'create-announcement';
  static const String corpAnnouncementDetail = 'corp-announcement-detail';

  // Corporator — Polls
  static const String pollsManagement = 'polls-management';
  static const String createPoll = 'create-poll';
  static const String corpPollDetail = 'corp-poll-detail';
  static const String corpPollResults = 'corp-poll-results';

  // Corporator — Helpline management
  static const String helplineManagement = 'helpline-management';
  static const String createHelpline = 'create-helpline';
  static const String editHelpline = 'edit-helpline';

  // ─────────────────────────────────────────────
  // Shared
  // ─────────────────────────────────────────────

  static const String notifications = 'notifications';
}
