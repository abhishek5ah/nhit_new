import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';

class ActivityTableView extends StatelessWidget {
  final List<ActivityLog> activityData;
  final int totalItems;
  final int currentPage;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int?> onRowsPerPageChanged;
  final bool isLoading;

  const ActivityTableView({
    super.key,
    required this.activityData,
    required this.totalItems,
    required this.currentPage,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Description', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Time Ago', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Created At', style: TextStyle(color: colorScheme.onSurface))),
    ];

    final startIndex = currentPage * rowsPerPage;

    final rows = activityData.asMap().entries.map((entry) {
      final log = entry.value;
      final displayIndex = startIndex + entry.key + 1;

      return DataRow(
        cells: [
          DataCell(Text(displayIndex.toString(), style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.name, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.description, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.relativeTime, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.createdAtDisplay, style: TextStyle(color: colorScheme.onSurface))),
        ],
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Logs',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLoading)
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Refreshing...',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomTable(
              columns: columns,
              rows: rows,
            ),
          ),
          CustomPaginationBar(
            totalItems: totalItems,
            currentPage: currentPage,
            rowsPerPage: rowsPerPage,
            onPageChanged: onPageChanged,
            onRowsPerPageChanged: onRowsPerPageChanged,
          ),
        ],
      ),
    );
  }
}
