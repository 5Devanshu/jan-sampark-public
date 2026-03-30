// lib/features/voter/dashboard/models/voter_dashboard_models.dart
//
// Lightweight summary models used only by the Voter Dashboard feed.
// Full feature models (Complaint, Event, Campaign, etc.) live in their
// own feature folders — these are thin projections of those documents.

// ─────────────────────────────────────────────
// Voter Profile Summary
// Loaded once on dashboard mount and cached in state.
// Source: GET /users/profile
// ─────────────────────────────────────────────

class VoterProfileSummary {
  const VoterProfileSummary({
    required this.userId,
    required this.fullName,
    required this.mobile,
    required this.epicVerified,
    required this.wardName,
    required this.areaName,
    required this.photoUrl,
    required this.profileComplete,
    required this.ocrStatus,
  });

  final String  userId;
  final String  fullName;
  final String  mobile;
  final bool    epicVerified;
  final String? wardName;
  final String? areaName;
  final String? photoUrl;
  final bool    profileComplete;
  final String? ocrStatus;   // 'pending' | 'processing' | 'completed' | 'failed' | null

  /// First name extracted from full name — used in the greeting.
  String get firstName => fullName.trim().split(' ').first;

  factory VoterProfileSummary.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return VoterProfileSummary(
      userId:          json['id']               as String? ?? '',
      fullName:        json['full_name']         as String? ?? '',
      mobile:          json['mobile']            as String? ?? '',
      epicVerified:    json['epic_verified']     as bool?   ?? false,
      wardName:        loc['ward_name']          as String?,
      areaName:        loc['area_name']          as String?,
      photoUrl:        json['profile_photo_url'] as String?,
      profileComplete: json['profile_complete']  as bool?   ?? true,
      ocrStatus:       json['ocr_status']        as String?,
    );
  }

  factory VoterProfileSummary.empty() => const VoterProfileSummary(
    userId: '', fullName: 'Voter', mobile: '',
    epicVerified: false, wardName: null, areaName: null,
    photoUrl: null, profileComplete: true, ocrStatus: null,
  );
}

// ─────────────────────────────────────────────
// Complaint Summary
// Built from the voter's own complaint list.
// Source: GET /complaints?page=1&page_size=50
// ─────────────────────────────────────────────

class VoterComplaintSummary {
  const VoterComplaintSummary({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.escalated,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final int escalated;

  factory VoterComplaintSummary.fromList(List<dynamic> items) {
    int pending = 0, inProgress = 0, resolved = 0, escalated = 0;
    for (final item in items) {
      final status = (item['status'] as String? ?? '').toLowerCase();
      switch (status) {
        case 'pending':                       pending++;   break;
        case 'acknowledged':
        case 'in_progress':                   inProgress++;break;
        case 'resolved':                      resolved++;  break;
        case 'escalated':                     escalated++; break;
      }
    }
    return VoterComplaintSummary(
      total:      items.length,
      pending:    pending,
      inProgress: inProgress,
      resolved:   resolved,
      escalated:  escalated,
    );
  }

  factory VoterComplaintSummary.empty() => const VoterComplaintSummary(
    total: 0, pending: 0, inProgress: 0, resolved: 0, escalated: 0,
  );
}

// ─────────────────────────────────────────────
// Dashboard Announcement Preview
// Source: GET /announcements?page=1&page_size=5
// ─────────────────────────────────────────────

class DashboardAnnouncement {
  const DashboardAnnouncement({
    required this.id,
    required this.title,
    required this.contentPreview,
    required this.category,
    required this.createdByName,
    required this.publishedAt,
    required this.isAcknowledged,
    required this.viewCount,
  });

  final String    id;
  final String    title;
  final String    contentPreview;
  final String    category;
  final String?   createdByName;
  final DateTime? publishedAt;
  final bool      isAcknowledged;
  final int       viewCount;

  factory DashboardAnnouncement.fromJson(Map<String, dynamic> json) {
    return DashboardAnnouncement(
      id:             json['id']              as String? ?? '',
      title:          json['title']           as String? ?? '',
      contentPreview: json['content_preview'] as String? ?? '',
      category:       json['category']        as String? ?? '',
      createdByName:  json['created_by_name'] as String?,
      publishedAt:    json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
      isAcknowledged: json['is_acknowledged'] as bool? ?? false,
      viewCount:      json['view_count']      as int?   ?? 0,
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard Event Preview
// Source: GET /events?page=1&page_size=4&status=upcoming
// ─────────────────────────────────────────────

class DashboardEvent {
  const DashboardEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.venueName,
    required this.maxParticipants,
    required this.registeredCount,
    required this.isRegistered,
    required this.status,
    required this.bannerUrl,
  });

  final String    id;
  final String    title;
  final String    description;
  final DateTime? eventDate;
  final String?   venueName;
  final int?      maxParticipants;
  final int       registeredCount;
  final bool      isRegistered;
  final String    status;
  final String?   bannerUrl;

  bool get isFull =>
      maxParticipants != null && registeredCount >= maxParticipants!;

  factory DashboardEvent.fromJson(Map<String, dynamic> json) {
    return DashboardEvent(
      id:               json['id']               as String? ?? '',
      title:            json['title']            as String? ?? '',
      description:      json['description']      as String? ?? '',
      eventDate:        json['event_date'] != null
          ? DateTime.tryParse(json['event_date'] as String)
          : null,
      venueName:        json['venue_name']        as String?,
      maxParticipants:  json['max_participants']  as int?,
      registeredCount:  json['registered_count']  as int? ?? 0,
      isRegistered:     json['is_registered']     as bool? ?? false,
      status:           json['status']            as String? ?? '',
      bannerUrl:        json['banner_url']         as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard Campaign Preview
// Source: GET /campaigns?page=1&page_size=4&status=active
// ─────────────────────────────────────────────

class DashboardCampaign {
  const DashboardCampaign({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.collectedAmount,
    required this.deadline,
    required this.status,
    required this.bannerUrl,
  });

  final String    id;
  final String    title;
  final String    description;
  final double    targetAmount;
  final double    collectedAmount;
  final DateTime? deadline;
  final String    status;
  final String?   bannerUrl;

  double get progressPercent =>
      targetAmount > 0 ? (collectedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  factory DashboardCampaign.fromJson(Map<String, dynamic> json) {
    return DashboardCampaign(
      id:              json['id']               as String? ?? '',
      title:           json['title']            as String? ?? '',
      description:     json['description']      as String? ?? '',
      targetAmount:    (json['target_amount']   as num?)?.toDouble() ?? 0.0,
      collectedAmount: (json['collected_amount']as num?)?.toDouble() ?? 0.0,
      deadline:        json['deadline'] != null
          ? DateTime.tryParse(json['deadline'] as String)
          : null,
      status:          json['status']           as String? ?? '',
      bannerUrl:       json['banner_url']       as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Leaderboard Entry Preview
// Source: GET /leaderboard?limit=5&role=all
// ─────────────────────────────────────────────

class DashboardLeaderboardEntry {
  const DashboardLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.fullName,
    required this.role,
    required this.points,
    required this.photoUrl,
    required this.wardName,
  });

  final int     rank;
  final String  userId;
  final String  fullName;
  final String  role;
  final int     points;
  final String? photoUrl;
  final String? wardName;

  factory DashboardLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return DashboardLeaderboardEntry(
      rank:     json['rank']      as int?    ?? 0,
      userId:   json['user_id']   as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role:     json['role']      as String? ?? '',
      points:   json['points']    as int?    ?? 0,
      photoUrl: json['photo_url'] as String?,
      wardName: json['ward_name'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Aggregated Dashboard Data
// Single state object — all sections together.
// ─────────────────────────────────────────────

class VoterDashboardData {
  const VoterDashboardData({
    required this.profile,
    required this.complaintSummary,
    required this.announcements,
    required this.upcomingEvents,
    required this.activeCampaigns,
    required this.leaderboard,
  });

  final VoterProfileSummary           profile;
  final VoterComplaintSummary         complaintSummary;
  final List<DashboardAnnouncement>   announcements;
  final List<DashboardEvent>          upcomingEvents;
  final List<DashboardCampaign>       activeCampaigns;
  final List<DashboardLeaderboardEntry> leaderboard;

  factory VoterDashboardData.empty() => VoterDashboardData(
    profile:          VoterProfileSummary.empty(),
    complaintSummary: VoterComplaintSummary.empty(),
    announcements:    const [],
    upcomingEvents:   const [],
    activeCampaigns:  const [],
    leaderboard:      const [],
  );
}