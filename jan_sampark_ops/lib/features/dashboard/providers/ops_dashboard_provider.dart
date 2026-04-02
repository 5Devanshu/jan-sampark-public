import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';

// ─────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────

class AreaSummary {
  const AreaSummary({
    required this.areaId,
    required this.areaName,
    required this.wardsCount,
    required this.votersCount,
    required this.complaintsTotal,
    required this.complaintsResolved,
    required this.complaintsEscalated,
    required this.leadersCount,
  });

  final String areaId;
  final String areaName;
  final int    wardsCount;
  final int    votersCount;
  final int    complaintsTotal;
  final int    complaintsResolved;
  final int    complaintsEscalated;
  final int    leadersCount;

  factory AreaSummary.fromJson(Map<String, dynamic> json) {
    final c = json['complaints'] as Map<String, dynamic>? ?? {};
    return AreaSummary(
      areaId:               json['area_id']   as String? ?? '',
      areaName:             json['area_name'] as String? ?? '',
      wardsCount:           json['wards_count']   as int? ?? 0,
      votersCount:          json['voters_count']  as int? ?? 0,
      complaintsTotal:      c['total']            as int? ?? 0,
      complaintsResolved:   c['resolved']         as int? ?? 0,
      complaintsEscalated:  c['escalated']        as int? ?? 0,
      leadersCount:         json['leaders_count'] as int? ?? 0,
    );
  }
}

class RecentCorporator {
  const RecentCorporator({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.areaName,
    required this.wardsCount,
    required this.isActive,
  });

  final String id;
  final String fullName;
  final String mobile;
  final String areaName;
  final int    wardsCount;
  final bool   isActive;

  factory RecentCorporator.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    return RecentCorporator(
      id:         json['id']        as String? ?? '',
      fullName:   json['full_name'] as String? ?? '',
      mobile:     json['mobile']    as String? ?? '',
      areaName:   loc['area_name']  as String? ?? '',
      wardsCount: json['wards_count'] as int? ?? 0,
      isActive:   json['is_active'] as bool? ?? true,
    );
  }
}

class OpsDashboardData {
  const OpsDashboardData({
    required this.totalVoters,
    required this.totalCorporators,
    required this.activeComplaints,
    required this.platformResolutionRate,
    required this.voterGrowthPct,
    required this.complaintGrowthPct,
    required this.areaSummaries,
    required this.recentCorporators,
  });

  final int    totalVoters;
  final int    totalCorporators;
  final int    activeComplaints;
  final double platformResolutionRate;
  final double voterGrowthPct;
  final double complaintGrowthPct;
  final List<AreaSummary>      areaSummaries;
  final List<RecentCorporator> recentCorporators;

  factory OpsDashboardData.fromJson(Map<String, dynamic> json) {
    final areas = (json['areas'] as List<dynamic>? ?? [])
        .map((e) => AreaSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    final corps = (json['recent_corporators'] as List<dynamic>? ?? [])
        .map((e) =>
            RecentCorporator.fromJson(e as Map<String, dynamic>))
        .toList();

    return OpsDashboardData(
      totalVoters:           json['total_voters']             as int?    ?? 0,
      totalCorporators:      json['total_corporators']        as int?    ?? 0,
      activeComplaints:      json['active_complaints']        as int?    ?? 0,
      platformResolutionRate: _d(json['platform_resolution_rate']),
      voterGrowthPct:        _d(json['voter_growth_pct']),
      complaintGrowthPct:    _d(json['complaint_growth_pct']),
      areaSummaries:         areas,
      recentCorporators:     corps,
    );
  }

  static double _d(dynamic v) {
    if (v is double) return v;
    if (v is int)    return v.toDouble();
    return 0.0;
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final opsDashboardProvider =
    FutureProvider.autoDispose<OpsDashboardData>((ref) async {
  final dio = ref.watch(opsDioProvider);
  final res = await dio.get(OpsConstants.endpointAnalytics);
  return OpsDashboardData.fromJson(
      res.data as Map<String, dynamic>);
});