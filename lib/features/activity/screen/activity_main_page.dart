import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';
import 'package:ppv_components/features/activity/services/activity_logs_service.dart';
import 'package:ppv_components/features/activity/widgets/activity_header.dart';
import 'package:ppv_components/features/activity/widgets/activity_logs_table.dart';

class ActivityMainPage extends StatefulWidget {
  const ActivityMainPage({super.key});

  @override
  State<ActivityMainPage> createState() => _ActivityMainPageState();
}

class _ActivityMainPageState extends State<ActivityMainPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityLogsService>().loadLogs(forceRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void updateActivitySearch(String query) {
    setState(() => _searchQuery = query.trim());
  }

  List<ActivityLog> _applySearch(List<ActivityLog> logs) {
    if (_searchQuery.isEmpty) return logs;
    final query = _searchQuery.toLowerCase();
    return logs.where((log) {
      return log.name.toLowerCase().contains(query) ||
          log.description.toLowerCase().contains(query) ||
          log.relativeTime.toLowerCase().contains(query) ||
          log.createdAtDisplay.toLowerCase().contains(query) ||
          log.id.toString().contains(query);
    }).toList();
  }

  Future<void> _handlePageChanged(int zeroBasedPage) async {
    final service = context.read<ActivityLogsService>();
    await service.loadLogs(
      page: zeroBasedPage + 1,
      pageSize: service.pageSize,
      forceRefresh: true,
    );
  }

  Future<void> _handleRowsPerPageChanged(int? value) async {
    if (value == null) return;
    final service = context.read<ActivityLogsService>();
    await service.loadLogs(
      page: 1,
      pageSize: value,
      forceRefresh: true,
    );
  }

  Future<void> _retryLoad(ActivityLogsService service) async {
    await service.loadLogs(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget searchBar() {
      return SizedBox(
        width: 250,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            hintText: 'Search activity logs',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 0.25,
              ),
            ),
            isDense: true,
          ),
          onChanged: updateActivitySearch,
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Consumer<ActivityLogsService>(
          builder: (context, service, _) {
            final filteredLogs = _applySearch(service.logs);
            final pagination = service.pagination;
            final totalItems = pagination?.totalItems ?? filteredLogs.length;
            final currentPageZeroBased =
                (service.currentPage - 1).clamp(0, (pagination?.totalPages ?? 1) - 1);

            Widget content;
            if (service.isLoading && filteredLogs.isEmpty) {
              content = const Center(child: CircularProgressIndicator());
            } else if (service.error != null && filteredLogs.isEmpty) {
              content = Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service.error!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _retryLoad(service),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              content = ActivityTableView(
                activityData: filteredLogs,
                totalItems: totalItems,
                currentPage: currentPageZeroBased,
                rowsPerPage: service.pageSize,
                onPageChanged: _handlePageChanged,
                onRowsPerPageChanged: _handleRowsPerPageChanged,
                isLoading: service.isLoading,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: ActivityHeader(),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      const Spacer(),
                      searchBar(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}
