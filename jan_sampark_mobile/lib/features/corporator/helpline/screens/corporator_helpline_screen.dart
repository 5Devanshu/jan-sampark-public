import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/inputs/search_field.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../voter/helpline/widgets/helpline_tile.dart';
import '../../../voter/helpline/providers/helpline_provider.dart';
import '../providers/corporator_helpline_provider.dart';

/// Corporator helpline screen — same as voter's but with
/// Add Number FAB and swipe-to-delete for custom numbers.
class CorporatorHelplineScreen extends ConsumerStatefulWidget {
  const CorporatorHelplineScreen({super.key});

  @override
  ConsumerState<CorporatorHelplineScreen> createState() =>
      _CorporatorHelplineScreenState();
}

class _CorporatorHelplineScreenState
    extends ConsumerState<CorporatorHelplineScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(helplineProvider);

    final filtered = _searchQuery.isEmpty
        ? state.helplines
        : state.helplines.where((h) {
            final q = _searchQuery.toLowerCase();
            return h.name.toLowerCase().contains(q) ||
                h.number.contains(q) ||
                h.category.contains(q);
          }).toList();

    final system = filtered.where((h) => h.isSystem).toList();
    final custom = filtered.where((h) => !h.isSystem).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        backgroundColor:        AppColors.appBarWhite,
        elevation:              0,
        scrolledUnderElevation: 0,
        title: Text('Helpline Directory',
            style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH, 0,
              AppDimensions.pagePaddingH, 10,
            ),
            child: SearchField(
              hint:      'Search helplines',
              onChanged: (q) =>
                  setState(() => _searchQuery = q),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.goNamed(RouteNames.createHelpline),
        backgroundColor: AppColors.primary,
        icon:  const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Number',
            style: AppTextStyles.buttonMedium),
      ),
      body: _buildBody(context, state, system, custom),
    );
  }

  Widget _buildBody(BuildContext context, state,
      List system, List custom) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 90);
    }

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
                  ref.read(helplineProvider.notifier).load(),
              icon:  const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty ||
        (system.isEmpty && custom.isEmpty)) {
      return EmptyStateWidget(
        icon:        Icons.phone_outlined,
        title:       'No Helplines Found',
        subtitle:    _searchQuery.isNotEmpty
            ? 'No results for "$_searchQuery".'
            : 'Add local helpline numbers for your area.',
        actionLabel: 'Add Number',
        onAction:    () =>
            context.goNamed(RouteNames.createHelpline),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(helplineProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH,
          AppDimensions.pagePaddingTop,
          AppDimensions.pagePaddingH,
          100,
        ),
        children: [
          // Emergency banner
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            margin: const EdgeInsets.only(
                bottom: AppDimensions.spaceXL),
            decoration: BoxDecoration(
              color:        AppColors.errorLight,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.errorBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.emergency_outlined,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For life-threatening emergencies, '
                    'call 112 immediately.',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),

          // System numbers
          if (system.isNotEmpty) ...[
            _SectionLabel(
              title:     'Emergency Services',
              icon:      Icons.local_police_outlined,
              iconColor: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ...system.map((h) => Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.spaceMD),
              child: HelplineTile(helpline: h),
            )),
          ],

          // Custom numbers (with swipe-to-delete)
          if (custom.isNotEmpty) ...[
            if (system.isNotEmpty)
              const SizedBox(height: AppDimensions.spaceSM),
            _SectionLabel(
              title:     'Local Numbers',
              icon:      Icons.phone_outlined,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ...custom.map((h) => Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.spaceMD),
              child: Dismissible(
                key:       ValueKey(h.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color:        AppColors.errorLight,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius),
                  ),
                  child: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                ),
                confirmDismiss: (_) async {
                  final ok = await ref
                      .read(helplineActionProvider.notifier)
                      .delete(h.id);
                  if (ok && context.mounted) {
                    context.showSuccess(
                        '${h.name} removed.');
                    ref.invalidate(helplineProvider);
                  }
                  return ok;
                },
                child: HelplineTile(helpline: h),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.icon,
    required this.iconColor,
  });
  final String   title;
  final IconData icon;
  final Color    iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.heading3),
      ],
    );
  }
}
