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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool needsHorizontalScroll = constraints.maxWidth < minTableWidth;

        Widget dataTableWidget = SizedBox(
          width: needsHorizontalScroll ? minTableWidth : constraints.maxWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Theme.of(context).colorScheme.surfaceContainer,
              ),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              columns: columns,
              rows: rows,
            ),
          ),
        );

        return Container(
          width: constraints.maxWidth,
          padding: padding ?? const EdgeInsets.only(bottom: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
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
