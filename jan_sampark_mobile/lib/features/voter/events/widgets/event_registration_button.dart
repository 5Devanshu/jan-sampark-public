import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/buttons/secondary_button.dart';
import '../../../../shared_widgets/dialogs/confirm_dialog.dart';
import '../models/event_models.dart';
import '../providers/event_provider.dart';

/// Register / Cancel registration button for event detail.
///
/// Handles all registration states:
///   - Can register      → blue Register button
///   - Already registered → green "Registered" + Cancel link
///   - Full              → grey "Fully Booked" disabled
///   - Deadline passed   → grey "Registration Closed"
///   - Cancelled event   → grey "Event Cancelled"
///   - Completed         → grey "Event Completed"
class EventRegistrationButton extends ConsumerWidget {
  const EventRegistrationButton({
    super.key,
    required this.event,
    this.onRegistered,
    this.onCancelled,
  });

  final EventModel event;
  final VoidCallback? onRegistered;
  final VoidCallback? onCancelled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regState = ref.watch(registrationProvider);

    // Listen for errors
    ref.listen<RegistrationState>(registrationProvider, (_, next) {
      if (next.hasError && next.errorMessage.isNotEmpty) {
        context.showError(next.errorMessage);
      }
    });

    // ── Already registered ─────────────────────
    if (event.isRegistered) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Registered confirmation banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.successBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'You are registered for this event',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // Cancel registration option (only for upcoming events)
          if (event.isUpcoming) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: regState.isLoading
                  ? null
                  : () async {
                      final confirm = await showConfirmDialog(
                        context: context,
                        title: 'Cancel Registration',
                        message:
                            'Are you sure you want to cancel your '
                            'registration for "${event.title}"?',
                        confirmLabel: 'Yes, Cancel',
                        isDestructive: true,
                        icon: Icons.event_busy_outlined,
                      );
                      if (confirm == true && context.mounted) {
                        final success = await ref
                            .read(registrationProvider.notifier)
                            .cancel(event.id);
                        if (success && context.mounted) {
                          context.showInfo('Registration cancelled.');
                          onCancelled?.call();
                        }
                      }
                    },
              child: Text(
                regState.isLoading ? 'Cancelling...' : 'Cancel Registration',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.error,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // ── Cannot register — various reasons ──────
    if (!event.isUpcoming) {
      return _DisabledButton(
        label: switch (event.status) {
          'cancelled' => 'Event Cancelled',
          'completed' => 'Event Completed',
          'ongoing' => 'Event is Ongoing',
          _ => 'Registration Closed',
        },
        icon: switch (event.status) {
          'cancelled' => Icons.cancel_outlined,
          'completed' => Icons.check_circle_outline,
          _ => Icons.lock_outline,
        },
      );
    }

    if (event.isFull) {
      return const _DisabledButton(
        label: 'Fully Booked',
        icon: Icons.people_outline,
      );
    }

    if (event.isDeadlinePassed) {
      return const _DisabledButton(
        label: 'Registration Closed',
        icon: Icons.timer_off_outlined,
      );
    }

    if (!event.registrationOpen) {
      return const _DisabledButton(
        label: 'Registration Not Open',
        icon: Icons.lock_outline,
      );
    }

    // ── Register button ────────────────────────
    return PrimaryButton(
      label: 'Register for Event',
      icon: Icons.event_available_outlined,
      isLoading: regState.isLoading,
      onPressed: () async {
        final success = await ref
            .read(registrationProvider.notifier)
            .register(event.id);
        if (success && context.mounted) {
          context.showSuccess('You are registered!');
          onRegistered?.call();
        }
      },
    );
  }
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
