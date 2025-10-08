import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/tabs.dart';
import 'package:ppv_components/features/user/model/user_model.dart';
import 'package:ppv_components/features/user/widgets/add_user_form.dart';
import 'package:ppv_components/features/user/widgets/user_header.dart';
import 'package:ppv_components/features/user/widgets/user_table.dart';
import 'package:ppv_components/features/user/data/user_mockdb.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({super.key});

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int tabIndex = 0;
  String searchQuery = '';
  late List<User> filteredUsers;
  List<User> allUsers = List<User>.from(userData);

  @override
  void initState() {
    super.initState();
    filteredUsers = List<User>.from(allUsers);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredUsers = allUsers.where((user) {
        final name = user.name.toLowerCase();
        final username = user.username.toLowerCase();
        final email = user.email.toLowerCase();
        return name.contains(searchQuery) ||
            username.contains(searchQuery) ||
            email.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteUser(User user) {
    setState(() {
      allUsers.removeWhere((u) => u.id == user.id);
      // Re-filter after deletion
      updateSearch(searchQuery);
    });
  }

  void onEditUser(User user) {
    final index = allUsers.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      setState(() {
        allUsers[index] = user;
        updateSearch(searchQuery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12, right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserHeader(tabIndex: tabIndex),
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
                      tabs: const ['User', 'Add User'],
                      selectedIndex: tabIndex,
                      onChanged: (idx) => setState(() => tabIndex = idx),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: 'Search users',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: colorScheme.outline,
                            width: 0.25,
                          ),
                        ),
                        isDense: true,
                      ),
                      onChanged: updateSearch,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tabIndex == 0
                  ? UserTableView(
                userData: filteredUsers,
                onDelete: onDeleteUser,
                onEdit: onEditUser,
              )
                  : const AddUserPage(),
            ),
          ],
        ),
      ),
    );
  }
}
