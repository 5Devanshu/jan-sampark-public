import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../voter/chats/widgets/chat_list_tile.dart';
import '../providers/leader_chat_provider.dart';

class LeaderChatsScreen extends ConsumerStatefulWidget {
  const LeaderChatsScreen({super.key});

  @override
  ConsumerState<LeaderChatsScreen> createState() => _LeaderChatsScreenState();
}

class _LeaderChatsScreenState extends ConsumerState<LeaderChatsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 200) {
        ref.read(leaderChatListProvider.notifier).loadMore();
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
    final state = ref.watch(leaderChatListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor: AppColors.appBarWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Community Chats', style: AppTextStyles.appBarTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.goNamed(RouteNames.leaderCreateChat),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Chat', style: AppTextStyles.buttonMedium),
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, LeaderChatListState state) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 100);
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
              onPressed: () => ref.read(leaderChatListProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.forum_outlined,
        title: 'No Chats Yet',
        subtitle: 'Create a community chat for your ward voters.',
        actionLabel: 'Create Chat',
        onAction: () => context.goNamed(RouteNames.leaderCreateChat),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(leaderChatListProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.pagePaddingTop,
          AppDimensions.pagePaddingH,
          100,
        ),
        itemCount: state.chats.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spaceMD),
        itemBuilder: (context, i) {
          if (i == state.chats.length) {
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
          final chat = state.chats[i];
          return ChatListTile(
            chat: chat,
            onTap: () => context.goNamed(
              RouteNames.leaderChatRoom,
              pathParameters: {'id': chat.id},
            ),
          );
        },
      ),
    );
  }
}
