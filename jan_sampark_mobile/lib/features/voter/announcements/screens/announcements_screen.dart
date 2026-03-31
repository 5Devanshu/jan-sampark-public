import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/cards/announcement_card.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../providers/announcement_provider.dart';
import '../widgets/category_filter_row.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() =>
      _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(announcementListProvider.notifier).loadMore();
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
    final state = ref.watch(announcementListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Announcements', style: AppTextStyles.appBarTitle),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CategoryFilterRow(
              selected: state.selectedCategory,
              onChanged: (cat) =>
                  ref.read(announcementListProvider.notifier).setCategory(cat),
            ),
          ),
          const Divider(height: 1),

          Expanded(child: _buildBody(context, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AnnouncementListState state) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 130);
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage,
              style: AppTextStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () =>
                  ref.read(announcementListProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.campaign_outlined,
        title: 'No Announcements',
        subtitle:
            'Announcements from your representative '
            'will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(announcementListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        itemCount: state.announcements.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.announcements.length) {
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
          final a = state.announcements[i];
          return AnnouncementCard(
            title: a.title,
            contentPreview: a.contentPreview,
            category: a.category,
            createdByName: a.createdByName,
            publishedAt: a.publishedAt,
            isAcknowledged: a.isAcknowledged,
            viewCount: a.viewCount,
            onTap: () => context.goNamed(
              RouteNames.voterAnnouncementDetail,
              pathParameters: {'id': a.id},
            ),
          );
        },
      ),
    );
  }
}
