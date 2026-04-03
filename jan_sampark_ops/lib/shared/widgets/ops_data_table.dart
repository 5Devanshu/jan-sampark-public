import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';
import '../../core/theme/ops_dimensions.dart';

/// Reusable data table with hover rows, column headers,
/// optional row-tap callback, and an empty state message.
///
/// Usage:
///   OpsDataTable(
///     columns: const ['Name', 'Area', 'Status'],
///     rows: [
///       OpsTableRow(cells: ['Ramesh Pawar', 'K/W', 'Active']),
///       OpsTableRow(cells: ['Priya Singh',  'H/E', 'Inactive'],
///                   onTap: () => ...),
///     ],
///   )
class OpsDataTable extends StatelessWidget {
  const OpsDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.emptyMessage  = 'No data available.',
    this.isLoading     = false,
    this.skeletonRows  = 5,
    this.columnWidths,
  });

  final List<String>            columns;
  final List<OpsTableRow>       rows;
  final String                  emptyMessage;
  final bool                    isLoading;
  final int                     skeletonRows;
  final Map<int, TableColumnWidth>? columnWidths;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        OpsColors.white,
        borderRadius: BorderRadius.circular(
            OpsDimensions.cardRadius),
        border: Border.all(color: OpsColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            OpsDimensions.cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────
            _TableHeader(columns: columns),

            const Divider(height: 1),

            // ── Body ────────────────────────────────
            if (isLoading)
              _SkeletonBody(
                  rowCount: skeletonRows,
                  colCount: columns.length)
            else if (rows.isEmpty)
              _EmptyBody(message: emptyMessage)
            else
              _DataBody(rows: rows),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Row model
// ─────────────────────────────────────────────

class OpsTableRow {
  const OpsTableRow({
    required this.cells,
    this.onTap,
    this.badge,
  });

  /// Plain string per column. Prefix with special markers:
  ///   '⚠ text'  → amber warning colour
  ///   '✓ text'  → green success colour
  ///   '✗ text'  → red error colour
  final List<String>  cells;
  final VoidCallback? onTap;

  /// Optional widget injected into the last column.
  final Widget?       badge;
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.columns});
  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OpsColors.surfaceGrey,
      padding: const EdgeInsets.symmetric(
        horizontal: OpsDimensions.tableCellPadH,
        vertical:   OpsDimensions.tableCellPadV - 2,
      ),
      child: Row(
        children: columns.map((col) {
          return Expanded(
            child: Text(
              col.toUpperCase(),
              style: OpsTextStyles.label,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Data body
// ─────────────────────────────────────────────

class _DataBody extends StatelessWidget {
  const _DataBody({required this.rows});
  final List<OpsTableRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rows.asMap().entries.map((entry) {
        final i      = entry.key;
        final row    = entry.value;
        final isLast = i == rows.length - 1;
        return _DataRow(row: row, isLast: isLast);
      }).toList(),
    );
  }
}

class _DataRow extends StatefulWidget {
  const _DataRow({required this.row, required this.isLast});
  final OpsTableRow row;
  final bool        isLast;

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.row.onTap != null;

    return MouseRegion(
      cursor: canTap
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter:  (_) => setState(() => _hovered = true),
      onExit:   (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.row.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          color: _hovered && canTap
              ? OpsColors.primaryLight
              : OpsColors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OpsDimensions.tableCellPadH,
                  vertical:   OpsDimensions.tableCellPadV,
                ),
                child: Row(
                  children: widget.row.cells.asMap().entries.map((e) {
                    final idx  = e.key;
                    final cell = e.value;
                    final isLast =
                        idx == widget.row.cells.length - 1;

                    return Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _CellText(text: cell),
                          ),
                          if (isLast &&
                              widget.row.badge != null) ...[
                            const SizedBox(width: 8),
                            widget.row.badge!,
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (!widget.isLast)
                const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Cell text — handles colour prefixes
// ─────────────────────────────────────────────

class _CellText extends StatelessWidget {
  const _CellText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    Color? color;
    String display = text;

    if (text.startsWith('⚠')) {
      color   = OpsColors.warning;
      display = text;
    } else if (text.startsWith('✓')) {
      color   = OpsColors.success;
      display = text;
    } else if (text.startsWith('✗')) {
      color   = OpsColors.error;
      display = text;
    }

    return Text(
      display,
      style: OpsTextStyles.body.copyWith(color: color),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }
}

// ─────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 32, color: OpsColors.textDisabled),
            const SizedBox(height: 10),
            Text(message,
                style: OpsTextStyles.body.copyWith(
                  color: OpsColors.textSecondary,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Skeleton rows
// ─────────────────────────────────────────────

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody({
    required this.rowCount,
    required this.colCount,
  });
  final int rowCount;
  final int colCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rowCount, (i) {
        final isLast = i == rowCount - 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: OpsDimensions.tableCellPadH,
                vertical:   OpsDimensions.tableCellPadV,
              ),
              child: Row(
                children: List.generate(colCount, (j) {
                  // Vary widths for a realistic shimmer
                  final w = j == 0 ? 120.0 : (60.0 + j * 18);
                  return Expanded(
                    child: _SkeletonCell(width: w),
                  );
                }),
              ),
            ),
            if (!isLast) const Divider(height: 1),
          ],
        );
      }),
    );
  }
}

class _SkeletonCell extends StatelessWidget {
  const _SkeletonCell({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: 14,
      decoration: BoxDecoration(
        color:        OpsColors.borderGrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
