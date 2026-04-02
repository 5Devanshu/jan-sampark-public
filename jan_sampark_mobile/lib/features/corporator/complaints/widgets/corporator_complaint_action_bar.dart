import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../leader/complaints/repositories/leader_complaint_repository.dart';

/// Bottom action bar for the Corporator complaint detail screen.
///
/// Corporator can:
///   Pending / Acknowledged / In Progress → Resolve, Reject, Reassign
///   Resolved → Close
///   Terminal (closed / rejected) → disabled bar
class CorporatorComplaintActionBar extends StatelessWidget {
  const CorporatorComplaintActionBar({
    super.key,
    required this.complaint,
    required this.onResolve,
    required this.onReject,
    required this.onReassign,
    required this.onClose,
    required this.onAddNote,
  });

  final ComplaintDetail complaint;
  final VoidCallback    onResolve;
  final VoidCallback    onReject;
  final VoidCallback    onReassign;
  final VoidCallback    onClose;
  final VoidCallback    onAddNote;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    // Terminal state
    if (complaint.status == 'closed') {
      return _TerminalBar(
        label:    'Complaint closed',
        icon:     Icons.lock_outline,
        bottomPad: bottomPad,
      );
    }
    if (complaint.status == 'rejected') {
      return _TerminalBar(
        label:    'Complaint rejected',
        icon:     Icons.cancel_outlined,
        bottomPad: bottomPad,
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.spaceMD,
        AppDimensions.pagePaddingH,
        AppDimensions.spaceMD + bottomPad,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Primary action ─────────────────────
          if (complaint.status == 'resolved')
            _PrimaryButton(
              label:     'Close Complaint',
              icon:      Icons.lock_outline_rounded,
              color:     AppColors.textSecondary,
              onPressed: onClose,
            )
          else
            _PrimaryButton(
              label:     'Mark Resolved',
              icon:      Icons.check_circle_outline_rounded,
              color:     AppColors.success,
              onPressed: onResolve,
            ),

          const SizedBox(height: AppDimensions.spaceSM),

          // ── Secondary actions ──────────────────
          if (complaint.status != 'resolved')
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    label:     'Reject',
                    icon:      Icons.cancel_outlined,
                    color:     AppColors.error,
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _SecondaryButton(
                    label:     'Reassign',
                    icon:      Icons.swap_horiz_rounded,
                    color:     AppColors.primaryAccent,
                    onPressed: onReassign,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _SecondaryButton(
                    label:     'Add Note',
                    icon:      Icons.note_add_outlined,
                    color:     AppColors.textSecondary,
                    onPressed: onAddNote,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TerminalBar extends StatelessWidget {
  const _TerminalBar({
    required this.label,
    required this.icon,
    required this.bottomPad,
  });

  final String   label;
  final IconData icon;
  final double   bottomPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.spaceMD,
        AppDimensions.pagePaddingH,
        AppDimensions.spaceMD + bottomPad,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border:
            Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color:        AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size:  18,
                color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: AppDimensions.buttonHeightMD,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon:  Icon(icon, size: 18),
        label: Text(label,
            style: AppTextStyles.buttonMedium),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation:       0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppDimensions.buttonRadius),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String   label;
  final IconData icon;
  final Color    color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.buttonHeightSM,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5)),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppDimensions.radiusSM),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(
                    color: color)),
          ],
        ),
      ),
    );
  }
}