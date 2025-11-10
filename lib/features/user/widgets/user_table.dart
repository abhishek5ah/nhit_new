import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/user/model/user_model.dart';
import 'package:ppv_components/features/user/screens/edit_user.dart';
import 'package:ppv_components/features/user/screens/view_user.dart';
import 'package:ppv_components/features/user/widgets/user_grid.dart';

const List<String> availableRoles = [
  'Super Admin', 'Admin', 'ER Approver', 'ER User', 'GN Approver',
  'GN User', 'PN Approver', 'PN User',
];

class UserTableView extends StatefulWidget {
  final List<User> userData;
  final void Function(User) onDelete;
  final void Function(User) onEdit;

  const UserTableView({
    super.key,
    required this.userData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<UserTableView> createState() => _UserTableViewState();
}

class _UserTableViewState extends State<UserTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<User> paginatedUsers;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant UserTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      currentPage = 0;
      _updatePagination();
    }
  }

  void _updatePagination() {
    final totalPages = (widget.userData.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.userData.length);
    paginatedUsers = widget.userData.sublist(start, end);
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

  Future<void> deleteUser(User user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      widget.onDelete(user);
      _updatePagination();
    }
  }

  Future<void> onEditUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(user: user),
      ),
    );
    if (result != null && result is User) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  Future<void> onViewUser(User user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewUserDetailsPage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Username', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Email', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Roles', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Active', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: colorScheme.onSurface))),
    ];

    final rows = paginatedUsers.map((user) {
      final roleBadges = <Widget>[];
      final limitedRoles = user.roles.take(2).toList();
      for (var role in limitedRoles) {
        roleBadges.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(role, style: TextStyle(color: colorScheme.onPrimary, fontSize: 12)),
          ),
        );
      }
      if (user.roles.length > 2) {
        roleBadges.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${user.roles.length - 2}',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }

      return DataRow(
        cells: [
          DataCell(Text(user.id.toString(), style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(user.name, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(user.username, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Text(user.email, style: TextStyle(color: colorScheme.onSurface))),
          DataCell(Wrap(spacing: 6, runSpacing: 4, children: roleBadges)),
          DataCell(
            Icon(
              user.isActive ? Icons.check_circle : Icons.cancel,
              color: user.isActive ? colorScheme.primary : colorScheme.error,
            ),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View Icon Button
                IconButton(
                  onPressed: () => onViewUser(user),
                  icon: const Icon(Icons.visibility_outlined),
                  color: colorScheme.primary,
                  iconSize: 20,
                  tooltip: 'View',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Edit Icon Button
                IconButton(
                  onPressed: () => onEditUser(user),
                  icon: const Icon(Icons.edit_outlined),
                  color: colorScheme.tertiary,
                  iconSize: 20,
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.tertiary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 4),
                // Delete Icon Button
                IconButton(
                  onPressed: () => deleteUser(user),
                  icon: const Icon(Icons.delete_outline),
                  color: colorScheme.error,
                  iconSize: 20,
                  tooltip: 'Delete',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Users',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your users',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha:0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        ToggleBtn(
                          labels: ['Table', 'Grid'],
                          selectedIndex: toggleIndex,
                          onChanged: (index) => setState(() => toggleIndex = index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                        children: [
                          Expanded(
                            child: CustomTable(columns: columns, rows: rows),
                          ),
                          // Use your reusable pagination bar here:
                          CustomPaginationBar(
                            totalItems: widget.userData.length,
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
                      )
                          : UserGridView(
                        userList: widget.userData,
                        rowsPerPage: rowsPerPage,
                        currentPage: currentPage,
                        onPageChanged: (page) => setState(() => currentPage = page),
                        onRowsPerPageChanged: (rows) => setState(() {
                          rowsPerPage = rows ?? rowsPerPage;
                          currentPage = 0;
                        }),
                        userData: [],
                      ),
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
