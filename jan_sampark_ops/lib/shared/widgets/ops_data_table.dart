import 'package:flutter/material.dart';
import '../../core/theme/ops_colors.dart';
import '../../core/theme/ops_text_styles.dart';

/// Reusable data table for the Ops console.
class OpsDataTable extends StatelessWidget {
  const OpsDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.emptyMessage = 'No data available.',
  });

  final List<String>        columns;
  final List<List<String>>  rows;
  final void Function(int)? onRowTap;
  final String              emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        OpsColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpsColors.borderGrey),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: OpsColors.surfaceGrey,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(9),
              ),
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  child: Text(
                    col.toUpperCase(),
                    style: OpsTextStyles.tableHeader,
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // Rows
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(emptyMessage,
                    style: OpsTextStyles.bodySecondary),
              ),
            )
          else
            ...rows.asMap().entries.map((entry) {
              final i    = entry.key;
              final row  = entry.value;
              final isLast = i == rows.length - 1;
              return _TableRow(
                cells:   row,
                isLast:  isLast,
                onTap:   onRowTap != null
                    ? () => onRowTap!(i)
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

class _TableRow extends StatefulWidget {
  const _TableRow({
    required this.cells,
    required this.isLast,
    this.onTap,
  });
  final List<String> cells;
  final bool         isLast;
  final VoidCallback? onTap;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter:  (_) => setState(() => _hovered = true),
      onExit:   (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered && widget.onTap != null
                ? OpsColors.surfaceGrey
                : OpsColors.white,
            borderRadius: widget.isLast
                ? const BorderRadius.vertical(
                    bottom: Radius.circular(9))
                : BorderRadius.zero,
          ),
          child: Column(
            children: [
              Row(
                children: widget.cells.map((cell) {
                  final isWarning = cell.startsWith('⚠');
                  return Expanded(
                    child: Text(
                      cell,
                      style: OpsTextStyles.tableCell.copyWith(
                        color: isWarning
                            ? OpsColors.warning
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
              if (!widget.isLast) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
              ],
            ],
          ),
        ),
      ),
    );
  }
}