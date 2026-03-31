/// Leader profile and performance data models.

class LeaderPerformance {
  const LeaderPerformance({
    this.complaintsAcknowledged = 0,
    this.complaintsEscalated = 0,
    this.eventsCreated = 0,
    this.groundVerificationsCompleted = 0,
    this.voterInteractions = 0,
  });

  final int complaintsAcknowledged;
  final int complaintsEscalated;
  final int eventsCreated;
  final int groundVerificationsCompleted;
  final int voterInteractions;

  factory LeaderPerformance.fromJson(Map<String, dynamic> json) {
    return LeaderPerformance(
      complaintsAcknowledged: json['complaints_acknowledged'] as int? ?? 0,
      complaintsEscalated: json['complaints_escalated'] as int? ?? 0,
      eventsCreated: json['events_created'] as int? ?? 0,
      groundVerificationsCompleted:
          json['ground_verifications_completed'] as int? ?? 0,
      voterInteractions: json['voter_interactions'] as int? ?? 0,
    );
  }
}

class LeaderLocation {
  const LeaderLocation({
    this.wardId,
    this.wardName,
    this.areaId,
    this.areaName,
  });

  final String? wardId;
  final String? wardName;
  final String? areaId;
  final String? areaName;

  factory LeaderLocation.fromJson(Map<String, dynamic> json) {
    return LeaderLocation(
      wardId: json['ward_id'] as String?,
      wardName: json['ward_name'] as String?,
      areaId: json['area_id'] as String?,
      areaName: json['area_name'] as String?,
    );
  }
}

class LeaderProfile {
  const LeaderProfile({
    required this.userId,
    required this.fullName,
    required this.mobile,
    required this.isActive,
    required this.performance,
    required this.location,
    this.responsibilities = const [],
    this.createdByCorporatorId,
  });

  final String userId;
  final String fullName;
  final String mobile;
  final bool isActive;
  final LeaderPerformance performance;
  final LeaderLocation location;
  final List<String> responsibilities;
  final String? createdByCorporatorId;

  bool get canCreateAnnouncements =>
      responsibilities.contains('create_announcements');
  bool get canCreateEvents => responsibilities.contains('create_events');

  factory LeaderProfile.fromJson(Map<String, dynamic> json) {
    final leaderProfile = json['leader_profile'] as Map<String, dynamic>? ?? {};
    final perfJson =
        leaderProfile['performance'] as Map<String, dynamic>? ?? {};
    final locJson = json['location'] as Map<String, dynamic>? ?? {};
    final respList =
        (leaderProfile['leader_responsibilities'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

    return LeaderProfile(
      userId: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      performance: LeaderPerformance.fromJson(perfJson),
      location: LeaderLocation.fromJson(locJson),
      responsibilities: respList,
      createdByCorporatorId:
          leaderProfile['created_by_corporator_id'] as String?,
    );
  }
}

// ─────────────────────────────────────────────
// Ward summary counts for the dashboard
// ─────────────────────────────────────────────

class WardComplaintSummary {
  const WardComplaintSummary({
    this.total = 0,
    this.pending = 0,
    this.inProgress = 0,
    this.escalated = 0,
    this.resolved = 0,
  });

  final int total;
  final int pending;
  final int inProgress;
  final int escalated;
  final int resolved;
}
