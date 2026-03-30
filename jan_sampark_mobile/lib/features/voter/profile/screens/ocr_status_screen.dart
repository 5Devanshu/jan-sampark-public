// lib/features/voter/profile/screens/ocr_status_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../models/voter_profile_models.dart';
import '../providers/voter_profile_provider.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_field_row.dart';

class OcrStatusScreen extends ConsumerWidget {
  const OcrStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ocrAsync = ref.watch(ocrStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title:   const Text('ID Verification Status'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ocrAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(
          child: Text(e.toString(), style: AppTextStyles.bodySecondary),
        ),
        data: (ocr) => ocr == null
            ? _NoOcrView()
            : _OcrDetailView(status: ocr),
      ),
    );
  }
}

class _NoOcrView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.document_scanner_outlined,
                size: 64, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text('No OCR record found',
                style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Your ID document may not have been '
              'uploaded during registration.',
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OcrDetailView extends ConsumerStatefulWidget {
  const _OcrDetailView({required this.status});
  final OcrJobStatus status;

  @override
  ConsumerState<_OcrDetailView> createState() => _OcrDetailViewState();
}

class _OcrDetailViewState extends ConsumerState<_OcrDetailView> {
  bool _isRetrying = false;

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    final err = await ref.read(ocrStatusProvider.notifier).retry();
    setState(() => _isRetrying = false);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('OCR retry queued successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    switch (s.status) {
      case 'completed':
        statusColor = AppColors.success;
        statusLabel = 'Completed';
        statusIcon  = Icons.check_circle_outline;
      case 'failed':
        statusColor = AppColors.error;
        statusLabel = 'Failed';
        statusIcon  = Icons.error_outline;
      default:
        statusColor = AppColors.primary;
        statusLabel = 'In Progress';
        statusIcon  = Icons.hourglass_top_rounded;
    }

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const SizedBox(height: 12),

        // ── Status card ──────────────────────────
        Container(
          padding:     const EdgeInsets.all(20),
          decoration:  BoxDecoration(
            color:        statusColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(statusLabel,
                      style: AppTextStyles.heading3.copyWith(
                        color: statusColor,
                      )),
                  Text(
                    s.documentType.replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Job info ─────────────────────────────
        ProfileInfoSection(
          title: 'Job Details',
          icon:  Icons.info_outline,
          children: [
            ProfileFieldRow(label: 'Job ID',  value: s.jobId),
            ProfileFieldRow(
              label: 'Submitted',
              value: s.createdAt != null
                  ? DateFormat('d MMM yyyy, h:mm a').format(s.createdAt!)
                  : '—',
            ),
            ProfileFieldRow(
              label: 'Completed',
              value: s.completedAt != null
                  ? DateFormat('d MMM yyyy, h:mm a').format(s.completedAt!)
                  : '—',
              isLast: true,
            ),
          ],
        ),

        if (s.isFailed && s.errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding:     const EdgeInsets.all(14),
            decoration:  BoxDecoration(
              color:        AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(color: AppColors.errorBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(s.errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      )),
                ),
              ],
            ),
          ),
        ],

        if (s.isCompleted && s.extractedData != null) ...[
          const SizedBox(height: 12),
          ProfileInfoSection(
            title: 'Extracted Data',
            icon:  Icons.document_scanner_outlined,
            children: [
              ProfileFieldRow(
                  label: 'Name', value: s.extractedData!.name ?? '—'),
              ProfileFieldRow(
                  label: 'ID Number', value: s.extractedData!.idNumber ?? '—'),
              ProfileFieldRow(
                  label: 'Date of Birth',
                  value: s.extractedData!.dateOfBirth ?? '—'),
              ProfileFieldRow(
                label:  'Address',
                value:  s.extractedData!.address ?? '—',
                isLast: true,
              ),
            ],
          ),
        ],

        if (s.isFailed) ...[
          const SizedBox(height: 24),
          PrimaryButton(
            label:     'Retry OCR',
            onPressed: _retry,
            isLoading: _isRetrying,
            icon:      Icons.refresh,
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Maximum 3 retry attempts allowed.',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}