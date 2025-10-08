import 'package:flutter/material.dart';

class CustomTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double minTableWidth;
  final EdgeInsetsGeometry? padding;

  const CustomTable({
    super.key,
    required this.columns,
    required this.rows,
    this.minTableWidth = 900,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final modifiedColumns = columns
        .map((col) => DataColumn(
      label: Flexible(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            (col.label is Text) ? (col.label as Text).data ?? '' : '',
            style: (col.label is Text) ? (col.label as Text).style : null,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      numeric: col.numeric,
      tooltip: col.tooltip,
      onSort: col.onSort,
    ))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool needsHorizontalScroll = constraints.maxWidth < minTableWidth;

        Widget dataTableWidget = SizedBox(
          width: needsHorizontalScroll ? minTableWidth : constraints.maxWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Theme.of(context).colorScheme.surface,
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              columns: modifiedColumns,
              rows: rows,
              columnSpacing: 24,
              dataRowMinHeight: 48,
              headingRowHeight: 56,
            ),
          ),
        );

        return Container(
          width: constraints.maxWidth,
          padding: padding ?? const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 0.75,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: needsHorizontalScroll
                  ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: dataTableWidget,
              )
                  : dataTableWidget,
            ),
          ),
        );
      },
    );
  }
}
