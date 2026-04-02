import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../shared/widgets/ops_stat_card.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../../../shared/widgets/ops_section_header.dart';
import '../providers/ops_dashboard_provider.dart';

class OpsDashboardScreen extends ConsumerWidget {
  const OpsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(opsDashboardProvider);

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            color: OpsColors.primary),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 48, color: OpsColors.textSecondary),
            const SizedBox(height: 16),
            Text(e.toString(),
                style: OpsTextStyles.bodySecondary),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(opsDashboardProvider),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (data) => _DashboardContent(data: data),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.data});
  final OpsDashboardData data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Dashboard',
                      style: OpsTextStyles.heading1),
                  Text(
                    'Real-time overview across all areas.',
                    style: OpsTextStyles.bodySecondary,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Platform stats ───────────────────
          LayoutBuilder(builder: (_, constraints) {
            final cols = constraints.maxWidth > 900 ? 4 : 2;
            return Wrap(
              spacing:    16,
              runSpacing: 16,
              children: [
                _StatWrap(
                  cols: cols,
                  child: OpsStatCard(
                    title: 'Total Voters',
                    value: '${data.totalVoters}',
                    icon:  Icons.people_outline,
                    color: OpsColors.primary,
                    trend: data.voterGrowthPct,
                  ),
                ),
                _StatWrap(
                  cols: cols,
                  child: OpsStatCard(
                    title: 'Corporators',
                    value: '${data.totalCorporators}',
                    icon:  Icons.badge_outlined,
                    color: OpsColors.success,
                  ),
                ),
                _StatWrap(
                  cols: cols,
                  child: OpsStatCard(
                    title: 'Active Complaints',
                    value: '${data.activeComplaints}',
                    icon:  Icons.report_problem_outlined,
                    color: OpsColors.warning,
                    trend: data.complaintGrowthPct,
                  ),
                ),
                _StatWrap(
                  cols: cols,
                  child: OpsStatCard(
                    title: 'Resolution Rate',
                    value:
                        '${data.platformResolutionRate.toStringAsFixed(1)}%',
                    icon:  Icons.check_circle_outline,
                    color: OpsColors.success,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 32),

          // ── Area breakdown ───────────────────
          const OpsSectionHeader(title: 'Area-wise Summary'),
          const SizedBox(height: 16),
          OpsDataTable(
            columns: const [
              'Area',
              'Wards',
              'Voters',
              'Complaints',
              'Resolved',
              'Escalated',
              'Leaders',
            ],
            rows: data.areaSummaries.map((a) => [
              a.areaName,
              '${a.wardsCount}',
              '${a.votersCount}',
              '${a.complaintsTotal}',
              '${a.complaintsResolved}',
              a.complaintsEscalated > 0
                  ? '⚠ ${a.complaintsEscalated}'
                  : '${a.complaintsEscalated}',
              '${a.leadersCount}',
            ]).toList(),
          ),

          const SizedBox(height: 32),

          // ── Recent corporators ───────────────
          Row(
            children: [
              const Expanded(
                child: OpsSectionHeader(
                    title: 'Recent Corporators'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View all'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OpsDataTable(
            columns: const [
              'Name',
              'Mobile',
              'Area',
              'Wards',
              'Active',
            ],
            rows: data.recentCorporators.map((c) => [
              c.fullName,
              c.mobile,
              c.areaName,
              '${c.wardsCount}',
              c.isActive ? '✓ Active' : '✗ Inactive',
            ]).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatWrap extends StatelessWidget {
  const _StatWrap({required this.cols, required this.child});
  final int    cols;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = (MediaQuery.sizeOf(context).width - 48 - 240 -
            (cols - 1) * 16) /
        cols;
    return SizedBox(
      width: w.clamp(200.0, 400.0),
      child: child,
    );
  }
}