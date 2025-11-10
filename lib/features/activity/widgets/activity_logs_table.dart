import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';

class ActivityTableView extends StatefulWidget {
  final List<ActivityLog> activityData;

  const ActivityTableView({
    super.key,
    required this.activityData,
  });

  @override
  State<ActivityTableView> createState() => _ActivityTableViewState();
}

class _ActivityTableViewState extends State<ActivityTableView> {
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<ActivityLog> paginatedLogs;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant ActivityTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activityData != oldWidget.activityData) {
      currentPage = 0;
      _updatePagination();
    }
  }

  void _updatePagination() {
    final totalPages = (widget.activityData.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.activityData.length);

    paginatedLogs = widget.activityData.sublist(start, end);
  }

  void changeRowsPerPage(int? value) {
    setState(() {
      rowsPerPage = value ?? 10;
      currentPage = 0;
      _updatePagination();
    });
  }

  void gotoPage(int page) {
    setState(() {
      currentPage = page;
      _updatePagination();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Description', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Time Ago', style: TextStyle(color: colorScheme.onSurface))),
    ];

    final rows = paginatedLogs.map((log) {
      return DataRow(
        cells: [
          DataCell(Text(log.id.toString(), style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.name, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.description, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(log.timeAgo, style: TextStyle(color: colorScheme.onSurface))),
        ],
      );
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Logs',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: CustomTable(
                        columns: columns,
                        rows: rows,
                      ),
                    ),
                    CustomPaginationBar(
                      totalItems: widget.activityData.length,
                      currentPage: currentPage,
                      rowsPerPage: rowsPerPage,
                      onPageChanged: (page) {
                        setState(() {
                          currentPage = page;
                          _updatePagination();
                        });
                      },
                      onRowsPerPageChanged: (value) {
                        setState(() {
                          rowsPerPage = value ?? 10;
                          currentPage = 0;
                          _updatePagination();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
