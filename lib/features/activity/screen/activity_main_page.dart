import 'package:flutter/material.dart';
import 'package:ppv_components/features/activity/data/activity_logs_mockdb.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';
import 'package:ppv_components/features/activity/widgets/activity_header.dart';
import 'package:ppv_components/features/activity/widgets/activity_logs_table.dart';

class ActivityMainPage extends StatefulWidget {
  const ActivityMainPage({super.key});

  @override
  State<ActivityMainPage> createState() => _ActivityMainPageState();
}

class _ActivityMainPageState extends State<ActivityMainPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<ActivityLog> filteredActivityLogs;
  final List<ActivityLog> allActivityLogs = List<ActivityLog>.from(activityLogs);

  @override
  void initState() {
    super.initState();
    filteredActivityLogs = List<ActivityLog>.from(allActivityLogs);
  }

  // Dispose of the controller when the widget is removed.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void updateActivitySearch(String query) {
    setState(() {
      final searchQuery = query.toLowerCase();
      filteredActivityLogs = allActivityLogs.where((log) {
        return log.name.toLowerCase().contains(searchQuery) ||
            log.description.toLowerCase().contains(searchQuery) ||
            log.timeAgo.toLowerCase().contains(searchQuery) ||
            log.id.toString().contains(searchQuery);
      }).toList();
    });
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
        child: Column(
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
            Expanded(
              child: ActivityTableView(
                activityData: filteredActivityLogs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
