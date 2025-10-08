import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/activity/data/activity_logs_mockdb.dart';
import 'package:ppv_components/features/activity/data/user_login_mockdb.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';
import 'package:ppv_components/features/activity/widgets/activity_header.dart';
import 'package:ppv_components/features/activity/widgets/activity_logs_table.dart';
import 'package:ppv_components/features/activity/widgets/login_header.dart';
import 'package:ppv_components/features/activity/widgets/user_login_table.dart';

class ActivityMainPage extends StatefulWidget {
  const ActivityMainPage({super.key});

  @override
  State<ActivityMainPage> createState() => _ActivityMainPageState();
}

class _ActivityMainPageState extends State<ActivityMainPage> {
  int tabIndex = 0;

  // Activity log state
  String activitySearchQuery = '';
  late List<ActivityLog> filteredActivityLogs;
  List<ActivityLog> allActivityLogs = List<ActivityLog>.from(activityLogs);

  // User login log state
  String loginSearchQuery = '';
  late List<UserLoginHistory> filteredLoginLogs;
  List<UserLoginHistory> allLoginLogs =
  List<UserLoginHistory>.from(userLoginHistoryData);

  @override
  void initState() {
    super.initState();
    filteredActivityLogs = List<ActivityLog>.from(allActivityLogs);
    filteredLoginLogs = List<UserLoginHistory>.from(allLoginLogs);
  }

  void updateActivitySearch(String query) {
    setState(() {
      activitySearchQuery = query.toLowerCase();
      filteredActivityLogs = allActivityLogs.where((log) {
        return log.name.toLowerCase().contains(activitySearchQuery) ||
            log.description.toLowerCase().contains(activitySearchQuery) ||
            log.timeAgo.toLowerCase().contains(activitySearchQuery) ||
            log.id.toString().contains(activitySearchQuery);
      }).toList();
    });
  }

  void updateLoginSearch(String query) {
    setState(() {
      loginSearchQuery = query.toLowerCase();
      filteredLoginLogs = allLoginLogs.where((log) {
        return log.user.toLowerCase().contains(loginSearchQuery) ||
            log.loginIp.toLowerCase().contains(loginSearchQuery) ||
            log.userAgent.toLowerCase().contains(loginSearchQuery) ||
            log.loginAt.toLowerCase().contains(loginSearchQuery) ||
            log.createdAt.toLowerCase().contains(loginSearchQuery) ||
            log.id.toString().contains(loginSearchQuery);
      }).toList();
    });
  }

  void onDeleteActivity(ActivityLog log) {
    setState(() {
      allActivityLogs.removeWhere((l) => l.id == log.id);
      updateActivitySearch(activitySearchQuery);
    });
  }

  void onEditActivity(ActivityLog log) {
    final index = allActivityLogs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      setState(() {
        allActivityLogs[index] = log;
        updateActivitySearch(activitySearchQuery);
      });
    }
  }

  void onDeleteLogin(UserLoginHistory log) {
    setState(() {
      allLoginLogs.removeWhere((l) => l.id == log.id);
      updateLoginSearch(loginSearchQuery);
    });
  }

  void onEditLogin(UserLoginHistory log) {
    final idx = allLoginLogs.indexWhere((l) => l.id == log.id);
    if (idx != -1) {
      setState(() {
        allLoginLogs[idx] = log;
        updateLoginSearch(loginSearchQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget searchBar({
      required String hint,
      required String value,
      required ValueChanged<String> onChanged,
    }) {
      return SizedBox(
        width: 250,
        child: TextField(
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            ),
          ),
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            hintText: hint,
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
          onChanged: onChanged,
        ),
      );
    }

    Widget tabHeader() {
      if (tabIndex == 0) return ActivityHeader(tabIndex: 0);
      return UserLoginHeader(tabIndex: 0);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tabHeader(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TabsBar(
                      tabs: const [
                        'Activity Logs',
                        'User Login History',
                      ],
                      selectedIndex: tabIndex,
                      onChanged: (idx) => setState(() => tabIndex = idx),
                    ),
                  ),
                  const Spacer(),
                  if (tabIndex == 0)
                    searchBar(
                      hint: 'Search activity logs',
                      value: activitySearchQuery,
                      onChanged: updateActivitySearch,
                    ),
                  if (tabIndex == 1)
                    searchBar(
                      hint: 'Search login logs',
                      value: loginSearchQuery,
                      onChanged: updateLoginSearch,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: tabIndex == 0
                  ? ActivityTableView(
                activityData: filteredActivityLogs,
              )
                  : UserLoginTableView(
                loginData: filteredLoginLogs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
