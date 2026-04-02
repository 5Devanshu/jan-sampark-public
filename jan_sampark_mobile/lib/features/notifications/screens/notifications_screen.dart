import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../shared_widgets/layout/app_scaffold.dart';
import '../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../shared_widgets/cards/notification_card.dart';
import '../providers/notification_provider.dart';
import '../models/notification_models.dart';

/// Notifications screen — accessible from all roles.
///
/// Features:
///   - Paginated list with infinite scroll
///   - Swipe left to dismiss (delete)
///   - Tap to mark as read and navigate to referenced entity
///   - "Mark all as read" action in app bar
///   - Unread count badge updates on load
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref
            .read(notificationListProvider.notifier)
            .loadMore();
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
    final state = ref.watch(notificationListProvider);

    return AppScaffold(
      title: 'Notifications',
      actions: [
        if (state.unreadCount > 0)
          state.isMarkingAll
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width:  20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () => ref
                      .read(notificationListProvider.notifier)
                      .markAllRead(),
                  child: Text(
                    'Mark all read',
                    style: AppTextStyles.captionMedium.copyWith(
                        color: AppColors.primary),
                  ),
                ),
      ],
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(
      BuildContext context, NotificationListState state) {
    // ── Loading ──────────────────────────────────
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 80);
    }

    // ── Error ────────────────────────────────────
    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(state.errorMessage,
                style:     AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(notificationListProvider.notifier).load(),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // ── Empty ────────────────────────────────────
    if (state.isEmpty) {
      return const EmptyStateWidget(
        icon:     Icons.notifications_none_outlined,
        title:    'No Notifications',
        subtitle: 'You are all caught up. '
            'Notifications about your complaints, '
            'events and donations will appear here.',
      );
    }

    // ── Unread summary banner ─────────────────────
    return Column(
      children: [
        if (state.unreadCount > 0)
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pagePaddingH,
                vertical:   10),
            color: AppColors.primaryLight,
            child: Text(
              '${state.unreadCount} unread notification'
              '${state.unreadCount == 1 ? '' : 's'}',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),

        // ── List ─────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationListProvider.notifier).load(),
            color: AppColors.primary,
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: state.notifications.length +
                  (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == state.notifications.length) {
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

                final n = state.notifications[i];
                return NotificationCard(
                  key:       ValueKey(n.id),
                  type:      n.type,
                  title:     n.title,
                  body:      n.body,
                  createdAt: n.createdAt,
                  isRead:    n.isRead,
                  onTap:     () => _onTap(context, n),
                  onDismiss: () => ref
                      .read(notificationListProvider.notifier)
                      .dismiss(n.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Handle tap — mark read then deep-link
  // ─────────────────────────────────────────────

  void _onTap(BuildContext context, NotificationModel n) {
    // Mark read (non-blocking)
    if (!n.isRead) {
      ref
          .read(notificationListProvider.notifier)
          .markRead(n.id);
    }

    // Deep-link based on reference type
    _navigate(context, n);
  }

  void _navigate(BuildContext context, NotificationModel n) {
    if (n.referenceId == null) return;

    switch (n.referenceType) {
      case 'complaint':
        // Works for all roles — GoRouter redirects to
        // the correct detail screen based on current role
        context.pushNamed(
          RouteNames.complaintDetail,
          pathParameters: {'id': n.referenceId!},
        );

      case 'donation':
        context.pushNamed(
          RouteNames.donationStatus,
          pathParameters: {'id': n.referenceId!},
        );

      case 'event':
        context.pushNamed(
          RouteNames.eventDetail,
          pathParameters: {'id': n.referenceId!},
        );

      case 'announcement':
        context.pushNamed(
          RouteNames.voterAnnouncementDetail,
          pathParameters: {'id': n.referenceId!},
        );

      case 'poll':
        context.pushNamed(
          RouteNames.voterPollResults,
          pathParameters: {'id': n.referenceId!},
        );

      case 'campaign':
        context.pushNamed(
          RouteNames.campaignDetail,
          pathParameters: {'id': n.referenceId!},
        );

      default:
        // Unknown type — stay on screen
        break;
    }
  }
}
