import 'package:flutter/material.dart';
import 'package:ppv_components/features/roles/model/roles_model.dart';
import 'package:ppv_components/features/roles/data/roles_mockdb.dart';
import 'package:ppv_components/features/roles/widgets/roles_header.dart';
import 'package:ppv_components/features/roles/widgets/roles_table.dart';

class RoleMainPage extends StatefulWidget {
  const RoleMainPage({super.key});

  @override
  State<RoleMainPage> createState() => _RoleMainPageState();
}

class _RoleMainPageState extends State<RoleMainPage> {
  String searchQuery = '';
  late List<Role> filteredRoles;
  List<Role> allRoles = List<Role>.from(roleData);

  @override
  void initState() {
    super.initState();
    filteredRoles = List<Role>.from(allRoles);
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredRoles = allRoles.where((role) {
        final roleName = role.roleName.toLowerCase();
        final permissions = role.permissions.join(',').toLowerCase();
        return roleName.contains(searchQuery) ||
            permissions.contains(searchQuery);
      }).toList();
    });
  }

  void onDeleteRole(Role role) {
    setState(() {
      allRoles.removeWhere((r) => r.id == role.id);
      updateSearch(searchQuery);
    });
  }

  void onEditRole(Role role) {
    final index = allRoles.indexWhere((r) => r.id == role.id);
    if (index != -1) {
      setState(() {
        allRoles[index] = role;
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
                  RoleHeader(tabIndex: 0),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            // Removed the TabsBar and related code here
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Removed the TabsBar widget
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        hintText: 'Search roles',
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
              child: RoleTableView(
                roleData: filteredRoles,
                onDelete: onDeleteRole,
                onEdit: onEditRole,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
