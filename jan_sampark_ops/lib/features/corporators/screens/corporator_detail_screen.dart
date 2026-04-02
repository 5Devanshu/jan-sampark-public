import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/network/ops_dio_client.dart';
import '../../../core/constants/ops_constants.dart';
import '../../../core/utils/ops_date_formatter.dart';
import '../providers/corporators_provider.dart';

class CorporatorDetailScreen extends ConsumerWidget {
  const CorporatorDetailScreen({
    super.key,
    required this.corporatorId,
  });
  final String corporatorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
        corporatorDetailProvider(corporatorId));

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            color: OpsColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(e.toString(),
            style: OpsTextStyles.bodySecondary),
      ),
      data: (corp) => _CorporatorDetailContent(
        corporator: corp,
        corporatorId: corporatorId,
      ),
    );
  }
}

class _CorporatorDetailContent extends ConsumerWidget {
  const _CorporatorDetailContent({
    required this.corporator,
    required this.corporatorId,
  });

  final CorporatorDetail corporator;
  final String           corporatorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────
            Row(
              children: [
                IconButton(
                  icon:      const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(corporator.fullName,
                      style: OpsTextStyles.heading1),
                ),
                // Toggle active/inactive
                _StatusToggle(
                  corporatorId: corporatorId,
                  isActive:     corporator.isActive,
                  onChanged: () =>
                      ref.invalidate(
                          corporatorDetailProvider(corporatorId)),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Details grid ───────────────────
            LayoutBuilder(builder: (_, c) {
              final isWide = c.maxWidth > 600;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ProfileCard(
                            corporator: corporator)),
                        const SizedBox(width: 16),
                        Expanded(child: _PerformanceCard(
                            corporator: corporator)),
                      ],
                    )
                  : Column(
                      children: [
                        _ProfileCard(
                            corporator: corporator),
                        const SizedBox(height: 16),
                        _PerformanceCard(
                            corporator: corporator),
                      ],
                    );
            }),

            const SizedBox(height: 24),

            // ── Reset password ─────────────────
            _ResetPasswordCard(corporatorId: corporatorId),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.corporator});
  final CorporatorDetail corporator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        OpsColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpsColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: OpsTextStyles.heading3),
          const SizedBox(height: 16),
          _Row(label: 'Full Name', value: corporator.fullName),
          _Row(label: 'Mobile',    value: corporator.mobile),
          _Row(label: 'Area',      value: corporator.areaName),
          _Row(
            label: 'Status',
            value: corporator.isActive ? 'Active' : 'Inactive',
            valueColor: corporator.isActive
                ? OpsColors.success
                : OpsColors.error,
          ),
          _Row(
            label: 'Created',
            value: OpsDateFormatter.toDateTime(
                corporator.createdAt),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.corporator});
  final CorporatorDetail corporator;

  @override
  Widget build(BuildContext context) {
    final perf = corporator.performanceSummary ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        OpsColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpsColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance', style: OpsTextStyles.heading3),
          const SizedBox(height: 16),
          _Row(
            label: 'Complaints Resolved',
            value: '${perf['complaints_resolved'] ?? 0}',
          ),
          _Row(
            label: 'Donations Verified',
            value: '${perf['donations_verified'] ?? 0}',
          ),
          _Row(
            label: 'Campaigns Created',
            value: '${perf['campaigns_created'] ?? 0}',
          ),
          _Row(
            label: 'Leaders Managed',
            value: '${perf['leaders_count'] ?? corporator.assignedWards.length}',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: OpsTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: OpsTextStyles.bodyMedium.copyWith(
                  color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusToggle extends ConsumerWidget {
  const _StatusToggle({
    required this.corporatorId,
    required this.isActive,
    required this.onChanged,
  });

  final String   corporatorId;
  final bool     isActive;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive
            ? OpsColors.error
            : OpsColors.success,
        side: BorderSide(
          color: isActive
              ? OpsColors.error
              : OpsColors.success,
        ),
      ),
      onPressed: () async {
        final dio = ref.read(opsDioProvider);
        await dio.patch(
          '${OpsConstants.endpointCorporators}/$corporatorId',
          data: {'is_active': !isActive},
        );
        onChanged();
      },
      icon: Icon(
        isActive
            ? Icons.person_off_outlined
            : Icons.person_outlined,
        size: 16,
      ),
      label: Text(isActive ? 'Deactivate' : 'Activate'),
    );
  }
}

class _ResetPasswordCard extends ConsumerStatefulWidget {
  const _ResetPasswordCard({required this.corporatorId});
  final String corporatorId;

  @override
  ConsumerState<_ResetPasswordCard> createState() =>
      _ResetPasswordCardState();
}

class _ResetPasswordCardState
    extends ConsumerState<_ResetPasswordCard> {
  final _passCtrl = TextEditingController();
  bool  _isLoading = false;
  String _message  = '';

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_passCtrl.text.length < 8) {
      setState(() => _message = 'Min 8 characters required.');
      return;
    }
    setState(() { _isLoading = true; _message = ''; });
    try {
      final dio = ref.read(opsDioProvider);
      await dio.patch(
        '${OpsConstants.endpointCorporators}'
        '/${widget.corporatorId}/password',
        data: {'new_password': _passCtrl.text},
      );
      _passCtrl.clear();
      setState(() => _message = '✓ Password reset successfully.');
    } catch (e) {
      setState(() => _message = 'Failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        OpsColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpsColors.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reset Password',
              style: OpsTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            'Set a new temporary password for this corporator.',
            style: OpsTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller:  _passCtrl,
                  obscureText: true,
                  style:       OpsTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'New password (min 8 chars)',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _reset,
                child: Text(_isLoading
                    ? 'Resetting...'
                    : 'Reset'),
              ),
            ],
          ),
          if (_message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _message,
              style: OpsTextStyles.caption.copyWith(
                color: _message.startsWith('✓')
                    ? OpsColors.success
                    : OpsColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}