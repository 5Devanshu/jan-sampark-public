import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../repositories/leader_complaint_repository.dart';

/// Bottom action bar on the complaint detail screen.
/// Shows context-sensitive action buttons based on complaint status.
class ComplaintActionBar extends StatelessWidget {
  const ComplaintActionBar({
    super.key,
    required this.complaint,
    required this.onAcknowledge,
    required this.onEscalate,
    required this.onAddNote,
    required this.onReject,
    required this.onMarkInProgress,
  });

  final ComplaintDetail complaint;
  final VoidCallback onAcknowledge;
  final VoidCallback onEscalate;
  final VoidCallback onAddNote;
  final VoidCallback onReject;
  final VoidCallback onMarkInProgress;

  @override
  Widget build(BuildContext context) {
    if (complaint.isTerminal) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.spaceMD,
          AppDimensions.pagePaddingH,
          AppDimensions.spaceMD + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.borderGrey)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'This complaint is ${complaint.status}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        AppDimensions.spaceMD,
        AppDimensions.pagePaddingH,
        AppDimensions.spaceMD + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Primary action ──────────────────────
          if (complaint.isPending)
            _PrimaryAction(
              label: 'Acknowledge',
              icon: Icons.thumb_up_outlined,
              color: AppColors.primary,
              onPressed: onAcknowledge,
            )
          else if (complaint.isAcknowledged)
            _PrimaryAction(
              label: 'Mark In Progress',
              icon: Icons.play_circle_outline,
              color: const Color(0xFF5521B5),
              onPressed: onMarkInProgress,
            ),

          const SizedBox(height: AppDimensions.spaceSM),

          // ── Secondary actions row ───────────────
          Row(
            children: [
              if (!complaint.isTerminal) ...[
                Expanded(
                  child: _SecondaryAction(
                    label: 'Escalate',
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.escalation,
                    onPressed: onEscalate,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _SecondaryAction(
                    label: 'Add Note',
                    icon: Icons.note_add_outlined,
                    color: AppColors.primaryAccent,
                    onPressed: onAddNote,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: _SecondaryAction(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: AppColors.error,
                    onPressed: onReject,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightMD,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: AppTextStyles.buttonMedium),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
