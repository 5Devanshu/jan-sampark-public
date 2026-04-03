import '../../../core/utils/ops_date_formatter.dart';

// ─────────────────────────────────────────────
// Period trend point — one data point per day/week
// ─────────────────────────────────────────────

class OpsTrendPoint {
  const OpsTrendPoint({
    required this.label,
    required this.value,
    this.secondaryValue,
  });

  final String label;
  final double value;
  final double? secondaryValue;

  factory OpsTrendPoint.fromJson(Map<String, dynamic> json) {
    return OpsTrendPoint(
      label: json['label'] as String? ?? '',
      value: _d(json['value']),
      secondaryValue: json['secondary_value'] != null
          ? _d(json['secondary_value'])
          : null,
    );
  }

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }
}

// ─────────────────────────────────────────────
// Complaint Analytics (platform-wide)
// ─────────────────────────────────────────────

class OpsComplaintAnalytics {
  const OpsComplaintAnalytics({
    this.total              = 0,
    this.pending            = 0,
    this.acknowledged       = 0,
    this.inProgress         = 0,
    this.escalated          = 0,
    this.resolved           = 0,
    this.rejected           = 0,
    this.closed             = 0,
    this.resolutionRate     = 0.0,
    this.avgResolutionDays  = 0.0,
    this.escalationRate     = 0.0,
    this.trend              = const [],
    this.byCategory         = const [],
    this.byPriority         = const {},
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
  final double escalationRate;
  final List<OpsTrendPoint>  trend;
  final List<OpsCategoryCount> byCategory;
  final Map<String, int>     byPriority;

  int get active => pending + acknowledged + inProgress + escalated;

  factory OpsComplaintAnalytics.fromJson(
      Map<String, dynamic> json) {
    final status  = json['by_status']   as Map<String, dynamic>? ?? {};
    final catList = json['by_category'] as List<dynamic>? ?? [];
    final priMap  = json['by_priority'] as Map<String, dynamic>? ?? {};
    final trendList = json['trend']     as List<dynamic>? ?? [];

    return OpsComplaintAnalytics(
      total:             json['total']              as int?    ?? 0,
      pending:           status['pending']          as int?    ?? 0,
      acknowledged:      status['acknowledged']     as int?    ?? 0,
      inProgress:        status['in_progress']      as int?    ?? 0,
      escalated:         status['escalated']        as int?    ?? 0,
      resolved:          status['resolved']         as int?    ?? 0,
      rejected:          status['rejected']         as int?    ?? 0,
      closed:            status['closed']           as int?    ?? 0,
      resolutionRate:    _d(json['resolution_rate']),
      avgResolutionDays: _d(json['avg_resolution_days']),
      escalationRate:    _d(json['escalation_rate']),
      trend: trendList
          .map((e) => OpsTrendPoint.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      byCategory: catList
          .map((e) => OpsCategoryCount.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      byPriority: {
        for (final e in priMap.entries)
          e.key: (e.value as int? ?? 0),
      },
    );
  }

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }
}

class OpsCategoryCount {
  const OpsCategoryCount({
    required this.categoryName,
    required this.count,
    required this.percentage,
    required this.resolutionRate,
  });

  final String categoryName;
  final int    count;
  final double percentage;
  final double resolutionRate;

  factory OpsCategoryCount.fromJson(
      Map<String, dynamic> json) {
    return OpsCategoryCount(
      categoryName:   json['category_name']  as String? ?? '',
      count:          json['count']          as int?    ?? 0,
      percentage:     OpsComplaintAnalytics._d(
          json['percentage']),
      resolutionRate: OpsComplaintAnalytics._d(
          json['resolution_rate']),
    );
  }
}

// ─────────────────────────────────────────────
// Voter Analytics
// ─────────────────────────────────────────────

class OpsVoterAnalytics {
  const OpsVoterAnalytics({
    this.total          = 0,
    this.verified       = 0,
    this.verifiedRate   = 0.0,
    this.growthPct      = 0.0,
    this.byGender       = const {},
    this.byReligion     = const {},
    this.trend          = const [],
  });

  final int    total;
  final int    verified;
  final double verifiedRate;
  final double growthPct;
  final Map<String, int>    byGender;
  final Map<String, int>    byReligion;
  final List<OpsTrendPoint> trend;

  factory OpsVoterAnalytics.fromJson(
      Map<String, dynamic> json) {
    Map<String, int> _parseMap(dynamic raw) {
      final m = raw as Map<String, dynamic>? ?? {};
      return {for (final e in m.entries) e.key: (e.value as int? ?? 0)};
    }

    return OpsVoterAnalytics(
      total:        json['total']          as int?    ?? 0,
      verified:     json['verified']       as int?    ?? 0,
      verifiedRate: OpsComplaintAnalytics._d(
          json['verified_rate']),
      growthPct:    OpsComplaintAnalytics._d(
          json['growth_pct']),
      byGender:    _parseMap(json['by_gender']),
      byReligion:  _parseMap(json['by_religion']),
      trend: (json['trend'] as List<dynamic>? ?? [])
          .map((e) => OpsTrendPoint.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Campaign Analytics
// ─────────────────────────────────────────────

class OpsCampaignAnalytics {
  const OpsCampaignAnalytics({
    this.total            = 0,
    this.active           = 0,
    this.completed        = 0,
    this.totalRaised      = 0.0,
    this.totalTarget      = 0.0,
    this.totalDonors      = 0,
    this.pendingDonations = 0,
    this.avgFundingRate   = 0.0,
    this.trend            = const [],
  });

  final int    total;
  final int    active;
  final int    completed;
  final double totalRaised;
  final double totalTarget;
  final int    totalDonors;
  final int    pendingDonations;
  final double avgFundingRate;
  final List<OpsTrendPoint> trend;

  double get overallFundingRate =>
      totalTarget > 0 ? (totalRaised / totalTarget * 100) : 0.0;

  factory OpsCampaignAnalytics.fromJson(
      Map<String, dynamic> json) {
    return OpsCampaignAnalytics(
      total:            json['total']             as int?    ?? 0,
      active:           json['active']            as int?    ?? 0,
      completed:        json['completed']         as int?    ?? 0,
      totalRaised:      OpsComplaintAnalytics._d(
          json['total_raised']),
      totalTarget:      OpsComplaintAnalytics._d(
          json['total_target']),
      totalDonors:      json['total_donors']      as int?    ?? 0,
      pendingDonations: json['pending_donations'] as int?    ?? 0,
      avgFundingRate:   OpsComplaintAnalytics._d(
          json['avg_funding_rate']),
      trend: (json['trend'] as List<dynamic>? ?? [])
          .map((e) => OpsTrendPoint.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Area Performance (for comparison table)
// ─────────────────────────────────────────────

class OpsAreaPerformance {
  const OpsAreaPerformance({
    required this.areaId,
    required this.areaName,
    required this.areaCode,
    required this.corporatorName,
    this.votersTotal       = 0,
    this.voterGrowthPct    = 0.0,
    this.complaintsTotal   = 0,
    this.complaintsResolved = 0,
    this.complaintsEscalated = 0,
    this.resolutionRate    = 0.0,
    this.avgResolutionDays = 0.0,
    this.campaignRaised    = 0.0,
    this.eventsCount       = 0,
    this.leadersCount      = 0,
  });

  final String areaId;
  final String areaName;
  final String areaCode;
  final String corporatorName;
  final int    votersTotal;
  final double voterGrowthPct;
  final int    complaintsTotal;
  final int    complaintsResolved;
  final int    complaintsEscalated;
  final double resolutionRate;
  final double avgResolutionDays;
  final double campaignRaised;
  final int    eventsCount;
  final int    leadersCount;

  factory OpsAreaPerformance.fromJson(
      Map<String, dynamic> json) {
    final comp = json['complaints'] as Map<String, dynamic>? ?? {};
    final voter = json['voters']   as Map<String, dynamic>? ?? {};

    return OpsAreaPerformance(
      areaId:           json['area_id']        as String? ?? '',
      areaName:         json['area_name']       as String? ?? '',
      areaCode:         json['area_code']       as String? ?? '',
      corporatorName:   json['corporator_name'] as String? ?? '—',
      votersTotal:      voter['total']          as int?    ?? 0,
      voterGrowthPct:   OpsComplaintAnalytics._d(
          voter['growth_pct']),
      complaintsTotal:  comp['total']           as int?    ?? 0,
      complaintsResolved: comp['resolved']      as int?    ?? 0,
      complaintsEscalated: comp['escalated']    as int?    ?? 0,
      resolutionRate:   OpsComplaintAnalytics._d(
          comp['resolution_rate']),
      avgResolutionDays: OpsComplaintAnalytics._d(
          comp['avg_resolution_days']),
      campaignRaised:   OpsComplaintAnalytics._d(
          json['campaign_raised']),
      eventsCount:      json['events_count']    as int?    ?? 0,
      leadersCount:     json['leaders_count']   as int?    ?? 0,
    );
  }
}

// ─────────────────────────────────────────────
// Full analytics payload
// ─────────────────────────────────────────────

class OpsAnalyticsData {
  const OpsAnalyticsData({
    required this.complaints,
    required this.voters,
    required this.campaigns,
    required this.areaPerformance,
    required this.period,
    required this.generatedAt,
  });

  final OpsComplaintAnalytics    complaints;
  final OpsVoterAnalytics        voters;
  final OpsCampaignAnalytics     campaigns;
  final List<OpsAreaPerformance> areaPerformance;
  final String                   period;
  final DateTime                 generatedAt;

  factory OpsAnalyticsData.fromJson(
    Map<String, dynamic> json, {
    String period = '30d',
  }) {
    return OpsAnalyticsData(
      complaints: OpsComplaintAnalytics.fromJson(
          json['complaints'] as Map<String, dynamic>? ?? {}),
      voters: OpsVoterAnalytics.fromJson(
          json['voters'] as Map<String, dynamic>? ?? {}),
      campaigns: OpsCampaignAnalytics.fromJson(
          json['campaigns'] as Map<String, dynamic>? ?? {}),
      areaPerformance:
          (json['areas'] as List<dynamic>? ?? [])
              .map((e) => OpsAreaPerformance.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
      period: period,
      generatedAt: OpsDateFormatter.fromApiString(
              json['generated_at'] as String?) ??
          DateTime.now(),
    );
  }
}