import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/cards/event_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/event_provider.dart';
import '../widgets/event_filter_bar.dart';

/// Voter events screen.
///
/// Shows upcoming events in the voter's ward and area.
/// Filter bar lets voter switch between All / Upcoming / Ongoing / Past.
/// My Registrations tab shows events voter signed up for.
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _eventsScrollCtrl = ScrollController();
  final _regScrollCtrl = ScrollController();
  String _filter = 'upcoming';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    _eventsScrollCtrl.addListener(() {
      if (_eventsScrollCtrl.position.pixels >=
          _eventsScrollCtrl.position.maxScrollExtent - 200) {
        ref.read(eventListProvider.notifier).loadMore();
      }
    });

    _regScrollCtrl.addListener(() {
      if (_regScrollCtrl.position.pixels >=
          _regScrollCtrl.position.maxScrollExtent - 200) {
        ref.read(myRegistrationsProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _eventsScrollCtrl.dispose();
    _regScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Events', style: AppTextStyles.appBarTitle),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'My Registrations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Tab 1 — All events
          Column(
            children: [
              // Filter bar
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: EventFilterBar(
                  selected: _filter,
                  onChanged: (f) {
                    setState(() => _filter = f);
                    ref.read(eventListProvider.notifier).load();
                  },
                ),
              ),
              Expanded(
                child: _EventListTab(
                  scrollCtrl: _eventsScrollCtrl,
                  filter: _filter,
                ),
              ),
            ],
          ),

          // Tab 2 — My registrations
          _MyRegistrationsTab(scrollCtrl: _regScrollCtrl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// All Events Tab
// ─────────────────────────────────────────────

class _EventListTab extends ConsumerWidget {
  const _EventListTab({required this.scrollCtrl, required this.filter});
  final ScrollController scrollCtrl;
  final String filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventListProvider);

    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 220);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
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

    // Filter events client-side by status
    final filtered = filter == 'all'
        ? state.events
        : state.events.where((e) => e.status == filter).toList();

    if (filtered.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_outlined,
        title: 'No Events Found',
        subtitle: filter == 'upcoming'
            ? 'There are no upcoming events in your area.'
            : 'No events found for the selected filter.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(eventListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        itemCount: filtered.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == filtered.length) {
            return const _LoadingMore();
          }
          final event = filtered[i];
          return EventCard(
            title: event.title,
            eventDate: event.eventDate,
            eventTime: event.eventTime,
            venueName: event.venueName,
            status: event.status,
            wardName: event.wardName,
            totalRegistered: event.totalRegistered,
            maxCapacity: event.maxCapacity,
            isRegistered: event.isRegistered,
            coverImageUrl: event.coverImageUrl,
            onTap: () => context.goNamed(
              RouteNames.eventDetail,
              pathParameters: {'id': event.id},
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// My Registrations Tab
// ─────────────────────────────────────────────

class _MyRegistrationsTab extends ConsumerWidget {
  const _MyRegistrationsTab({required this.scrollCtrl});
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myRegistrationsProvider);

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
              onPressed: () =>
                  ref.read(myRegistrationsProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.events.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.event_available_outlined,
        title: 'No Registrations Yet',
        subtitle: 'Events you register for will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(myRegistrationsProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        itemCount: state.events.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.events.length) {
            return const _LoadingMore();
          }
          final event = state.events[i];
          return EventCard(
            title: event.title,
            eventDate: event.eventDate,
            eventTime: event.eventTime,
            venueName: event.venueName,
            status: event.status,
            wardName: event.wardName,
            totalRegistered: event.totalRegistered,
            maxCapacity: event.maxCapacity,
            isRegistered: event.isRegistered,
            coverImageUrl: event.coverImageUrl,
            onTap: () => context.goNamed(
              RouteNames.eventDetail,
              pathParameters: {'id': event.id},
            ),
          );
        },
      ),
    );
  }
}

class _LoadingMore extends StatelessWidget {
  const _LoadingMore();

  @override
  Widget build(BuildContext context) {
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
}
