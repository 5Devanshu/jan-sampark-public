import '../../../../core/utils/date_formatter.dart';

// ─────────────────────────────────────────────
// Area Analytics
// ─────────────────────────────────────────────

class ComplaintAnalytics {
  const ComplaintAnalytics({
    this.total          = 0,
    this.pending        = 0,
    this.acknowledged   = 0,
    this.inProgress     = 0,
    this.escalated      = 0,
    this.resolved       = 0,
    this.rejected       = 0,
    this.closed         = 0,
    this.resolutionRate = 0.0,
    this.avgResolutionDays = 0.0,
    this.byCategory     = const [],
    this.byPriority     = const {},
  });

  final int    total;
  final int    pending;
  final int    acknowledged;
  final int    inProgress;
  final int    escalated;
  final int    resolved;
  final int    rejected;
  final int    closed;
  final double resolutionRate;
  final double avgResolutionDays;
  final List<CategoryCount> byCategory;
  final Map<String, int>    byPriority;

  int get active => pending + acknowledged + inProgress + escalated;

  factory ComplaintAnalytics.fromJson(Map<String, dynamic> json) {
    final statusMap = json['by_status'] as Map<String, dynamic>? ?? {};
    final cats = (json['by_category'] as List<dynamic>? ?? [])
        .map((e) => CategoryCount.fromJson(e as Map<String, dynamic>))
        .toList();
    final priMap = <String, int>{};
    (json['by_priority'] as Map<String, dynamic>? ?? {})
        .forEach((k, v) => priMap[k] = (v as int?) ?? 0);

    return ComplaintAnalytics(
      total:           json['total']              as int?    ?? 0,
      pending:         statusMap['pending']       as int?    ?? 0,
      acknowledged:    statusMap['acknowledged']  as int?    ?? 0,
      inProgress:      statusMap['in_progress']   as int?    ?? 0,
      escalated:       statusMap['escalated']     as int?    ?? 0,
      resolved:        statusMap['resolved']      as int?    ?? 0,
      rejected:        statusMap['rejected']      as int?    ?? 0,
      closed:          statusMap['closed']        as int?    ?? 0,
      resolutionRate:  _toDouble(json['resolution_rate']),
      avgResolutionDays: _toDouble(json['avg_resolution_days']),
      byCategory:      cats,
      byPriority:      priMap,
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    return 0.0;
  }
}

class CategoryCount {
  const CategoryCount({
    required this.categoryName,
    required this.count,
    required this.percentage,
  });

  final String categoryName;
  final int    count;
  final double percentage;

  factory CategoryCount.fromJson(Map<String, dynamic> json) {
    return CategoryCount(
      categoryName: json['category_name'] as String? ?? '',
      count:        json['count']         as int?    ?? 0,
      percentage:   ComplaintAnalytics._toDouble(json['percentage']),
    );
  }
}

// ─────────────────────────────────────────────
// Voter Demographics
// ─────────────────────────────────────────────

class VoterDemographics {
  const VoterDemographics({
    this.totalVoters      = 0,
    this.verifiedVoters   = 0,
    this.verificationRate = 0.0,
    this.byGender         = const {},
    this.byReligion       = const {},
    this.byAge            = const {},
  });

  final int    totalVoters;
  final int    verifiedVoters;
  final double verificationRate;
  final Map<String, int> byGender;
  final Map<String, int> byReligion;
  final Map<String, int> byAge;

  factory VoterDemographics.fromJson(Map<String, dynamic> json) {
    Map<String, int> _parse(dynamic raw) {
      final m = <String, int>{};
      (raw as Map<String, dynamic>? ?? {})
          .forEach((k, v) => m[k] = (v as int?) ?? 0);
      return m;
    }

    return VoterDemographics(
      totalVoters:      json['total_voters']      as int?    ?? 0,
      verifiedVoters:   json['verified_voters']   as int?    ?? 0,
      verificationRate: ComplaintAnalytics._toDouble(
          json['verification_rate']),
      byGender:   _parse(json['by_gender']),
      byReligion: _parse(json['by_religion']),
      byAge:      _parse(json['by_age']),
    );
  }
}

// ─────────────────────────────────────────────
// Campaign Analytics
// ─────────────────────────────────────────────

class CampaignAnalytics {
  const CampaignAnalytics({
    this.totalCampaigns   = 0,
    this.activeCampaigns  = 0,
    this.totalRaised      = 0.0,
    this.totalTarget      = 0.0,
    this.totalDonors      = 0,
    this.pendingDonations = 0,
    this.avgFundingRate   = 0.0,
  });

  final int    totalCampaigns;
  final int    activeCampaigns;
  final double totalRaised;
  final double totalTarget;
  final int    totalDonors;
  final int    pendingDonations;
  final double avgFundingRate;

  factory CampaignAnalytics.fromJson(Map<String, dynamic> json) {
    return CampaignAnalytics(
      totalCampaigns:   json['total_campaigns']   as int?    ?? 0,
      activeCampaigns:  json['active_campaigns']  as int?    ?? 0,
      totalRaised:      ComplaintAnalytics._toDouble(json['total_raised']),
      totalTarget:      ComplaintAnalytics._toDouble(json['total_target']),
      totalDonors:      json['total_donors']      as int?    ?? 0,
      pendingDonations: json['pending_donations'] as int?    ?? 0,
      avgFundingRate:   ComplaintAnalytics._toDouble(json['avg_funding_rate']),
    );
  }
}

// ─────────────────────────────────────────────
// Leader Performance Summary
// ─────────────────────────────────────────────

class LeaderSummary {
  const LeaderSummary({
    required this.leaderId,
    required this.leaderName,
    required this.wardName,
    this.complaintsAssigned  = 0,
    this.complaintsResolved  = 0,
    this.resolutionRate      = 0.0,
    this.avgResponseDays     = 0.0,
  });

  final String leaderId;
  final String leaderName;
  final String wardName;
  final int    complaintsAssigned;
  final int    complaintsResolved;
  final double resolutionRate;
  final double avgResponseDays;

  factory LeaderSummary.fromJson(Map<String, dynamic> json) {
    return LeaderSummary(
      leaderId:           json['leader_id']            as String? ?? '',
      leaderName:         json['leader_name']           as String? ?? '',
      wardName:           json['ward_name']             as String? ?? '',
      complaintsAssigned: json['complaints_assigned']   as int?    ?? 0,
      complaintsResolved: json['complaints_resolved']   as int?    ?? 0,
      resolutionRate:     ComplaintAnalytics._toDouble(
          json['resolution_rate']),
      avgResponseDays:    ComplaintAnalytics._toDouble(
          json['avg_response_days']),
    );
  }
}

// ─────────────────────────────────────────────
// Full Area Dashboard
// ─────────────────────────────────────────────

class AreaDashboard {
  const AreaDashboard({
    required this.complaints,
    required this.voters,
    required this.campaigns,
    this.leaders       = const [],
    this.eventsCount   = 0,
    this.chatsCount    = 0,
    this.pollsCount    = 0,
    this.generatedAt,
  });

  final ComplaintAnalytics complaints;
  final VoterDemographics  voters;
  final CampaignAnalytics  campaigns;
  final List<LeaderSummary> leaders;
  final int     eventsCount;
  final int     chatsCount;
  final int     pollsCount;
  final DateTime? generatedAt;

  factory AreaDashboard.fromJson(Map<String, dynamic> json) {
    final leaderList =
        (json['leaders'] as List<dynamic>? ?? [])
            .map((e) =>
                LeaderSummary.fromJson(e as Map<String, dynamic>))
            .toList();

    return AreaDashboard(
      complaints: ComplaintAnalytics.fromJson(
          json['complaints'] as Map<String, dynamic>? ?? {}),
      voters: VoterDemographics.fromJson(
          json['voters'] as Map<String, dynamic>? ?? {}),
      campaigns: CampaignAnalytics.fromJson(
          json['campaigns'] as Map<String, dynamic>? ?? {}),
      leaders:     leaderList,
      eventsCount: json['events_count'] as int? ?? 0,
      chatsCount:  json['chats_count']  as int? ?? 0,
      pollsCount:  json['polls_count']  as int? ?? 0,
      generatedAt: DateFormatter.fromApiString(
          json['generated_at'] as String?),
    );
  }
}