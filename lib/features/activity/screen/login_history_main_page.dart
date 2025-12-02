import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';
import 'package:ppv_components/features/activity/services/user_login_history_service.dart';
import 'package:ppv_components/features/activity/widgets/login_header.dart';
import 'package:ppv_components/features/activity/widgets/user_login_table.dart';

class LoginHistoryMainPage extends StatefulWidget {
  const LoginHistoryMainPage({super.key});

  @override
  State<LoginHistoryMainPage> createState() => _LoginHistoryMainPageState();
}

class _LoginHistoryMainPageState extends State<LoginHistoryMainPage> {
  //Create the controller as a final variable.
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLoginHistory();
    });
  }

  // Dispose of the controller when the widget is removed.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLoginHistory() async {
    await context.read<UserLoginHistoryService>().loadHistories();
  }

  void updateLoginSearch(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  List<UserLoginHistory> _filterHistories(List<UserLoginHistory> histories) {
    if (_searchQuery.isEmpty) return histories;

    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');
    return histories.where((log) {
      final loginTimeText = dateFormatter.format(log.loginTime).toLowerCase();
      return log.userLabel.toLowerCase().contains(_searchQuery) ||
          log.ipAddress.toLowerCase().contains(_searchQuery) ||
          log.userAgent.toLowerCase().contains(_searchQuery) ||
          loginTimeText.contains(_searchQuery) ||
          log.historyId.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loginHistoryService = context.watch<UserLoginHistoryService>();
    final filteredLoginLogs =
        _filterHistories(loginHistoryService.histories);

    Widget searchBar() {
      return SizedBox(
        width: 250,
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            hintText: 'Search login logs',
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
          onChanged: updateLoginSearch,
        ),
      );
    }

    Future<void> onRefresh() async {
      await loginHistoryService.loadHistories();
    }

    Widget body() {
      if (loginHistoryService.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (loginHistoryService.error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loginHistoryService.error!,
                style: TextStyle(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (filteredLoginLogs.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 48),
              const SizedBox(height: 12),
              const Text('No login history found'),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        );
      }

      return UserLoginTableView(
        loginData: filteredLoginLogs,
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
              child: UserLoginHeader(tabIndex: 0),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: loginHistoryService.isLoading ? null : onRefresh,
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                  ),
                  const Spacer(),
                  searchBar(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: body(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
