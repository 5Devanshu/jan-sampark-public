import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../providers/notification_provider.dart';

/// App bar notification bell with unread count badge.
///
/// Usage — place in AppBar actions:
///   actions: [const NotificationBell()]
///
/// The bell refreshes its unread count whenever it is
/// rebuilt so the badge stays current after navigating
/// back from the notifications screen.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(unreadCountProvider);

    final count = countAsync.maybeWhen(
      data:   (c) => c,
      orElse: ()  => 0,
    );

    return Stack(
      children: [
        IconButton(
          icon:    const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () async {
            await context.pushNamed(RouteNames.notifications);
            // Refresh badge after returning from screen
            ref.invalidate(unreadCountProvider);
          },
        ),

        // Badge
        if (count > 0)
          Positioned(
            right: 6,
            top:   6,
            child: IgnorePointer(
              child: Container(
                constraints: const BoxConstraints(
                  minWidth:  16,
                  minHeight: 16,
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color:        AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   9,
                    fontWeight: FontWeight.w700,
                    height:     1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}