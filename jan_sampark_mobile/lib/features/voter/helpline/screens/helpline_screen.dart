import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/layout/empty_state_widget.dart';
import '../../../../shared_widgets/inputs/search_field.dart';
import '../providers/helpline_provider.dart';
import '../models/helpline_models.dart';
import '../widgets/helpline_tile.dart';

class HelplineScreen extends ConsumerStatefulWidget {
  const HelplineScreen({super.key});

  @override
  ConsumerState<HelplineScreen> createState() => _HelplineScreenState();
}

class _HelplineScreenState extends ConsumerState<HelplineScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(helplineProvider);

    // Filter by search query
    final filtered = _searchQuery.isEmpty
        ? state.helplines
        : state.helplines.where((h) {
            final q = _searchQuery.toLowerCase();
            return h.name.toLowerCase().contains(q) ||
                h.number.contains(q) ||
                h.category.contains(q);
          }).toList();

    // Separate system and custom
    final systemNumbers = filtered.where((h) => h.isSystem).toList();
    final customNumbers = filtered.where((h) => !h.isSystem).toList();

    return AppScaffold(
      title: 'Helpline Directory',
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pagePaddingH,
              10,
              AppDimensions.pagePaddingH,
              10,
            ),
            child: SearchField(
              hint: 'Search by name, number, or category',
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: _buildBody(context, state, systemNumbers, customNumbers),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HelplineState state,
    List<HelplineModel> systemNumbers,
    List<HelplineModel> customNumbers,
  ) {
    if (state.isLoading) {
      return const ShimmerListPlaceholder(itemHeight: 90);
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
              onPressed: () => ref.read(helplineProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.isEmpty || (systemNumbers.isEmpty && customNumbers.isEmpty)) {
      return EmptyStateWidget(
        icon: Icons.phone_outlined,
        title: 'No Helplines Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No results for "$_searchQuery".'
            : 'Helpline numbers will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(helplineProvider.notifier).load(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH,
          vertical: AppDimensions.pagePaddingTop,
        ),
        children: [
          // Emergency notice
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            margin: const EdgeInsets.only(bottom: AppDimensions.spaceXL),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.errorBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.emergency_outlined,
                  color: AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For life-threatening emergencies, '
                    'call 112 immediately.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // System numbers section
          if (systemNumbers.isNotEmpty) ...[
            _SectionHeader(
              title: 'Emergency Services',
              count: systemNumbers.length,
              iconColor: AppColors.error,
              icon: Icons.local_police_outlined,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ...systemNumbers.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                child: HelplineTile(helpline: h),
              ),
            ),
          ],

          // Custom numbers section
          if (customNumbers.isNotEmpty) ...[
            if (systemNumbers.isNotEmpty)
              const SizedBox(height: AppDimensions.spaceSM),
            _SectionHeader(
              title: 'Local Numbers',
              count: customNumbers.length,
              iconColor: AppColors.primary,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ...customNumbers.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                child: HelplineTile(helpline: h),
              ),
            ),
          ],

          const SizedBox(height: AppDimensions.spaceXL),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.heading3),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(color: iconColor),
          ),
        ),
      ],
    );
  }
}
