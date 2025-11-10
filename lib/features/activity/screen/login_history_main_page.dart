import 'package:flutter/material.dart';
import 'package:ppv_components/features/activity/data/user_login_mockdb.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';
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
  late List<UserLoginHistory> filteredLoginLogs;
  final List<UserLoginHistory> allLoginLogs =
  List<UserLoginHistory>.from(userLoginHistoryData);

  @override
  void initState() {
    super.initState();
    filteredLoginLogs = List<UserLoginHistory>.from(allLoginLogs);
  }

  // Dispose of the controller when the widget is removed.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void updateLoginSearch(String query) {
    setState(() {
      final searchQuery = query.toLowerCase();
      filteredLoginLogs = allLoginLogs.where((log) {
        return log.user.toLowerCase().contains(searchQuery) ||
            log.loginIp.toLowerCase().contains(searchQuery) ||
            log.userAgent.toLowerCase().contains(searchQuery) ||
            log.loginAt.toLowerCase().contains(searchQuery) ||
            log.createdAt.toLowerCase().contains(searchQuery) ||
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
                  const Spacer(),
                  searchBar(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: UserLoginTableView(
                loginData: filteredLoginLogs,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
