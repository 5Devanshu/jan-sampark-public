import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/ops_colors.dart';
import '../../../core/theme/ops_text_styles.dart';
import '../../../core/router/ops_router.dart';
import '../../../shared/widgets/ops_section_header.dart';
import '../../../shared/widgets/ops_data_table.dart';
import '../../../core/utils/ops_date_formatter.dart';
import '../providers/corporators_provider.dart';

class CorporatorsScreen extends ConsumerStatefulWidget {
  const CorporatorsScreen({super.key});

  @override
  ConsumerState<CorporatorsScreen> createState() =>
      _CorporatorsScreenState();
}

class _CorporatorsScreenState
    extends ConsumerState<CorporatorsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(corporatorsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Corporators',
                        style: OpsTextStyles.heading1),
                    Text(
                      'Manage corporator accounts across all areas.',
                      style: OpsTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    context.goNamed(OpsRoutes.createCorporator),
                icon:  const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Corporator'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Search ────────────────────────────
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchCtrl,
              style:      OpsTextStyles.body,
              decoration: InputDecoration(
                hintText:    'Search by name or mobile...',
                prefixIcon:  const Icon(Icons.search_rounded,
                    size: 18),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref
                              .read(
                                  corporatorsProvider.notifier)
                              .search('');
                        },
                      )
                    : null,
              ),
              onChanged: (q) => ref
                  .read(corporatorsProvider.notifier)
                  .search(q),
            ),
          ),

          const SizedBox(height: 20),

          // ── Total count ───────────────────────
          if (!state.isLoading && !state.hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${state.corporators.length} corporator'
                '${state.corporators.length == 1 ? '' : 's'}',
                style: OpsTextStyles.bodySecondary,
              ),
            ),

          // ── Table ─────────────────────────────
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CircularProgressIndicator(
                    color: OpsColors.primary),
              ),
            )
          else if (state.hasError)
            _ErrorCard(message: state.errorMessage)
          else
            OpsDataTable(
              columns: const [
                'Name',
                'Mobile',
                'Area',
                'Wards',
                'Status',
                'Created',
              ],
              rows: state.corporators.map((c) => [
                c.fullName,
                c.mobile,
                c.areaName,
                '${c.wardsCount}',
                c.isActive ? '✓ Active' : '✗ Inactive',
                OpsDateFormatter.toDate(c.createdAt),
              ]).toList(),
              onRowTap: (i) {
                final corp = state.corporators[i];
                context.goNamed(
                  OpsRoutes.corporatorDetail,
                  pathParameters: {'id': corp.id},
                );
              },
            ),

          // Load more
          if (state.hasMore && !state.isLoadingMore) ...[
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () => ref
                    .read(corporatorsProvider.notifier)
                    .loadMore(),
                child: const Text('Load More'),
              ),
            ),
          ],

          if (state.isLoadingMore)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                    color: OpsColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:        OpsColors.errorLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: OpsColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: OpsColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: OpsTextStyles.body.copyWith(
                    color: OpsColors.error)),
          ),
        ],
      ),
    );
  }
}