import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/badges/status_badge.dart';
import '../models/event_models.dart';
import '../providers/event_provider.dart';
import '../widgets/event_info_card.dart';
import '../widgets/event_registration_button.dart';

/// Event detail screen — full info + registration.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  // Local registration flag for optimistic UI updates
  bool? _localIsRegistered;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(eventDetailProvider(widget.eventId));

    return async.when(
      loading: () => const AppScaffold(
        title: 'Event',
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => AppScaffold(
        title: 'Event',
        body: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load event',
          subtitle: e.toString(),
        ),
      ),
      data: (event) {
        // Apply local override if voter just registered/cancelled
        final displayEvent = _localIsRegistered != null
            ? event.copyWith(isRegistered: _localIsRegistered)
            : event;
        return _EventDetailContent(
          event: displayEvent,
          onRegistered: () => setState(() => _localIsRegistered = true),
          onCancelled: () => setState(() => _localIsRegistered = false),
        );
      },
    );
  }
}

class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent({
    required this.event,
    this.onRegistered,
    this.onCancelled,
  });

  final EventModel event;
  final VoidCallback? onRegistered;
  final VoidCallback? onCancelled;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Event Details',
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Cover image ────────────────
                  _buildCoverImage(),

                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.spaceSM),

                        // Status badge
                        StatusBadge(status: event.status),
                        const SizedBox(height: AppDimensions.spaceMD),

                        // Title
                        Text(event.title, style: AppTextStyles.heading1),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Info card
                        EventInfoCard(event: event),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Days countdown
                        if (event.isUpcoming && event.daysUntilEvent >= 0) ...[
                          _DaysCountdown(days: event.daysUntilEvent),
                          const SizedBox(height: AppDimensions.spaceXL),
                        ],

                        // Description
                        Text('About this Event', style: AppTextStyles.heading3),
                        const SizedBox(height: AppDimensions.spaceSM),
                        Text(event.description, style: AppTextStyles.body),

                        // Attendance rate (if completed)
                        if (event.isCompleted && event.actualAttendees > 0) ...[
                          const SizedBox(height: AppDimensions.spaceXL),
                          _AttendanceStats(event: event),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom action ───────────────────────
          Container(
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
            child: EventRegistrationButton(
              event: event,
              onRegistered: onRegistered,
              onCancelled: onCancelled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImage() {
    if (event.coverImageUrl != null) {
      return Image.network(
        event.coverImageUrl!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _CoverPlaceholder(),
      );
    }
    return _CoverPlaceholder();
  }
}

class _CoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: const Center(
        child: Icon(Icons.event, color: Colors.white, size: 64),
      ),
    );
  }
}

class _DaysCountdown extends StatelessWidget {
  const _DaysCountdown({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final isToday = days == 0;
    final isTomorrow = days == 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        children: [
          if (isToday)
            Text(
              'Event is TODAY',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            )
          else if (isTomorrow)
            Text(
              'Event is TOMORROW',
              style: AppTextStyles.heading2.copyWith(color: Colors.white),
            )
          else ...[
            Text(
              '$days',
              style: AppTextStyles.metricLarge.copyWith(color: Colors.white),
            ),
            Text(
              'days until this event',
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttendanceStats extends StatelessWidget {
  const _AttendanceStats({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(value: '${event.totalRegistered}', label: 'Registered'),
          Container(width: 1, height: 40, color: AppColors.borderGrey),
          _Stat(value: '${event.actualAttendees}', label: 'Attended'),
          Container(width: 1, height: 40, color: AppColors.borderGrey),
          _Stat(
            value: '${event.participationRate.toStringAsFixed(0)}%',
            label: 'Turnout',
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.valueColor});
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.metricSmall.copyWith(
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
