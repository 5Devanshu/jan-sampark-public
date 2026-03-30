import '../constants/app_constants.dart';

/// HTTP method constants and common header keys.
/// Endpoint paths are defined in AppConstants.
class ApiConstants {
  ApiConstants._();

  // ─────────────────────────────────────────────
  // Headers
  // ─────────────────────────────────────────────

  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerRequestId = 'X-Request-ID';

  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';

  static const String bearerPrefix = 'Bearer ';

  // ─────────────────────────────────────────────
  // Status Codes
  // ─────────────────────────────────────────────

  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusTooLarge = 413;
  static const int statusUnprocessable = 422;
  static const int statusTooManyRequests = 429;
  static const int statusServerError = 500;

  // ─────────────────────────────────────────────
  // Pagination Query Parameters
  // ─────────────────────────────────────────────

  static const String paramPage = 'page';
  static const String paramPageSize = 'page_size';
  static const String paramStatus = 'status';
  static const String paramWardId = 'ward_id';
  static const String paramAreaId = 'area_id';
  static const String paramCategoryId = 'category_id';
  static const String paramEscalated = 'escalated';
  static const String paramPriority = 'priority';
}

/// Helper to build endpoint paths with dynamic segments.
///
/// Usage:
///   ApiPath.complaint('abc123')  →  '/complaints/abc123'
class ApiPath {
  ApiPath._();

  // Complaints
  static String complaint(String id) =>
      '${AppConstants.endpointComplaints}/$id';
  static String complaintAssign(String id) =>
      '${AppConstants.endpointComplaints}/$id/assign';
  static String complaintAcknowledge(String id) =>
      '${AppConstants.endpointComplaints}/$id/acknowledge';
  static String complaintStatus(String id) =>
      '${AppConstants.endpointComplaints}/$id/status';
  static String complaintEscalate(String id) =>
      '${AppConstants.endpointComplaints}/$id/escalate';
  static String complaintResolve(String id) =>
      '${AppConstants.endpointComplaints}/$id/resolve';
  static String complaintReject(String id) =>
      '${AppConstants.endpointComplaints}/$id/reject';
  static String complaintNote(String id) =>
      '${AppConstants.endpointComplaints}/$id/note';
  static String complaintFeedback(String id) =>
      '${AppConstants.endpointComplaints}/$id/feedback';

  // Campaigns
  static String campaign(String id) => '${AppConstants.endpointCampaigns}/$id';
  static String campaignStatus(String id) =>
      '${AppConstants.endpointCampaigns}/$id/status';

  // Donations
  static String donation(String id) => '${AppConstants.endpointDonations}/$id';
  static String donationVerify(String id) =>
      '${AppConstants.endpointDonations}/$id/verify';
  static String donationReceipt(String id) =>
      '${AppConstants.endpointDonations}/$id/receipt';

  // Events
  static String event(String id) => '${AppConstants.endpointEvents}/$id';
  static String eventStatus(String id) =>
      '${AppConstants.endpointEvents}/$id/status';
  static String eventRegister(String id) =>
      '${AppConstants.endpointEvents}/$id/register';
  static String eventAttendance(String eventId, String voterId) =>
      '${AppConstants.endpointEvents}/$eventId/attendance/$voterId';
  static String eventRegistrations(String id) =>
      '${AppConstants.endpointEvents}/$id/registrations';

  // Chats
  static String chat(String id) => '${AppConstants.endpointChats}/$id';
  static String chatToggle(String id) =>
      '${AppConstants.endpointChats}/$id/toggle';
  static String chatMessages(String chatId) =>
      '${AppConstants.endpointChats}/$chatId/messages';
  static String chatMessage(String chatId, String messageId) =>
      '${AppConstants.endpointChats}/$chatId/messages/$messageId';
  static String chatMessageReact(String chatId, String messageId) =>
      '${AppConstants.endpointChats}/$chatId/messages/$messageId/react';
  static String chatMessageFeedback(String chatId, String messageId) =>
      '${AppConstants.endpointChats}/$chatId/messages/$messageId/feedback';
  static String chatAnalytics(String id) =>
      '${AppConstants.endpointChats}/$id/analytics';

  // Announcements
  static String announcement(String id) =>
      '${AppConstants.endpointAnnouncements}/$id';
  static String announcementPublish(String id) =>
      '${AppConstants.endpointAnnouncements}/$id/publish';
  static String announcementAcknowledge(String id) =>
      '${AppConstants.endpointAnnouncements}/$id/acknowledge';

  // Polls
  static String poll(String id) => '${AppConstants.endpointPolls}/$id';
  static String pollPublish(String id) =>
      '${AppConstants.endpointPolls}/$id/publish';
  static String pollVote(String id) => '${AppConstants.endpointPolls}/$id/vote';
  static String pollResults(String id) =>
      '${AppConstants.endpointPolls}/$id/results';
  static String pollClose(String id) =>
      '${AppConstants.endpointPolls}/$id/close';

  // Users
  static String voter(String id) => '${AppConstants.endpointVoters}/$id';
  static String leader(String id) => '${AppConstants.endpointLeaders}/$id';
  static String corporator(String id) =>
      '${AppConstants.endpointCorporators}/$id';

  // Helpline
  static String helpline(String id) => '${AppConstants.endpointHelpline}/$id';

  // Notifications
  static String notificationRead(String id) =>
      '${AppConstants.endpointNotifications}/$id/read';
  static String notificationDelete(String id) =>
      '${AppConstants.endpointNotifications}/$id';

  // Analytics
  static String corporatorAnalytics(String section) =>
      '${AppConstants.endpointAnalyticsCorporator}/$section';

  // Areas / Wards
  static String ward(String id) => '${AppConstants.endpointWards}/$id';
  static String area(String id) => '${AppConstants.endpointAreas}/$id';
}
