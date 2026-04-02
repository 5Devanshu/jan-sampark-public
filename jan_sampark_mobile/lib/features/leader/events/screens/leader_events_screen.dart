import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/cards/event_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../voter/events/providers/event_provider.dart';
import '../../../voter/events/widgets/event_filter_bar.dart';

/// Leader events screen.
/// Same event list as voters but with a Create FAB.
class LeaderEventsScreen extends ConsumerStatefulWidget {
  const LeaderEventsScreen({super.key});

  @override
  ConsumerState<LeaderEventsScreen> createState() => _LeaderEventsScreenState();
}

class _LeaderEventsScreenState extends ConsumerState<LeaderEventsScreen> {
  final _scrollCtrl = ScrollController();
  String _filter = 'upcoming';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(eventListProvider.notifier).loadMore();
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
    final state = ref.watch(eventListProvider);

    final filtered = _filter == 'all'
        ? state.events
        : state.events.where((e) => e.status == _filter).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Events', style: AppTextStyles.appBarTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(RouteNames.createEvent),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Create Event', style: AppTextStyles.buttonMedium),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: EventFilterBar(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(context, filtered, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, List events, state) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 220);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.errorMessage,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => ref.read(eventListProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_outlined,
        title: 'No Events',
        subtitle: 'Create the first event for your ward.',
        actionLabel: 'Create Event',
        onAction: () => context.goNamed(RouteNames.createEvent),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(eventListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.pagePaddingTop,
          AppDimensions.pagePaddingH,
          100, // FAB clearance
        ),
        itemCount: events.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == events.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final e = events[i];
          return EventCard(
            title: e.title,
            eventDate: e.eventDate,
            eventTime: e.eventTime,
            venueName: e.venueName,
            status: e.status,
            wardName: e.wardName,
            totalRegistered: e.totalRegistered,
            maxCapacity: e.maxCapacity,
            isRegistered: false,
            coverImageUrl: e.coverImageUrl,
            onTap: () => context.goNamed(
              RouteNames.eventDetail,
              pathParameters: {'id': e.id},
            ),
          );
        },
      ),
    );
  }
}
