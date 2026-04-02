import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/cards/event_card.dart';
import '../providers/event_provider.dart';
import '../models/event_models.dart';

/// Standalone "My Registrations" screen.
/// Used when navigating directly to registered events.
/// (The same content also appears as Tab 2 on EventsScreen.)
class MyRegistrationsScreen extends ConsumerStatefulWidget {
  const MyRegistrationsScreen({super.key});

  @override
  ConsumerState<MyRegistrationsScreen> createState() =>
      _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState
    extends ConsumerState<MyRegistrationsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(myRegistrationsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myRegistrationsProvider);

    return AppScaffold(
      title: 'My Registrations',
      body: Builder(
        builder: (_) {
          if (state.isLoading) {
            return const ShimmerListPlaceholder(itemHeight: 220);
          }

          if (state.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.textSecondary, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.errorMessage,
                    style:     AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(myRegistrationsProvider.notifier)
                        .load(),
                    icon:  const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.events.isEmpty) {
            return EmptyStateWidget(
              icon:     Icons.event_available_outlined,
              title:    'No Registrations Yet',
              subtitle: 'Browse events and register to see them here.',
              actionLabel: 'Browse Events',
              onAction:    () =>
                  context.goNamed(RouteNames.voterEvents),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(myRegistrationsProvider.notifier).load(),
            color: AppColors.primary,
            child: ListView.separated(
              controller:   _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical:   AppDimensions.pagePaddingTop,
              ),
              itemCount: state.events.length +
                  (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spaceMD),
              itemBuilder: (context, i) {
                if (i == state.events.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }

                final event = state.events[i];
                return _RegistrationCard(event: event);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced event card for the registrations list.
/// Shows a "You are registered" banner and attendance
/// status if the event is completed.
class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.event});
  final event;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventCard(
          title:           event.title,
          eventDate:       event.eventDate,
          eventTime:       event.eventTime,
          venueName:       event.venueName,
          status:          event.status,
          wardName:        event.wardName,
          totalRegistered: event.totalRegistered,
          maxCapacity:     event.maxCapacity,
          isRegistered:    true,
          coverImageUrl:   event.coverImageUrl,
          onTap: () => context.goNamed(
            RouteNames.eventDetail,
            pathParameters: {'id': event.id},
          ),
        ),

        // Attended badge for completed events
        if (event.isCompleted) ...[
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.cardPaddingH,
                vertical: 8),
            decoration: BoxDecoration(
              color:        AppColors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(
                    AppDimensions.cardRadius),
              ),
              border: const Border(
                left:   BorderSide(color: AppColors.borderGrey),
                right:  BorderSide(color: AppColors.borderGrey),
                bottom: BorderSide(color: AppColors.borderGrey),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  event.actualAttendees > 0
                      ? Icons.how_to_reg_outlined
                      : Icons.event_busy_outlined,
                  size:  16,
                  color: event.actualAttendees > 0
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  event.actualAttendees > 0
                      ? 'Event completed — '
                        '${event.actualAttendees} attended'
                      : 'Event completed',
                  style: AppTextStyles.caption.copyWith(
                    color: event.actualAttendees > 0
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

