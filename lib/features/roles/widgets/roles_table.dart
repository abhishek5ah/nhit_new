import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/roles/model/roles_model.dart';
import 'package:ppv_components/features/roles/screens/view_page.dart';
import 'package:ppv_components/features/roles/widgets/roles_grid.dart';
import 'package:ppv_components/features/roles/screens/edit_role.dart';
import 'package:ppv_components/features/roles/screens/create_role.dart';

class RoleTableView extends StatefulWidget {
  final List<Role> roleData;
  final void Function(Role) onDelete;
  final void Function(Role) onEdit;

  const RoleTableView({
    super.key,
    required this.roleData,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<RoleTableView> createState() => _RoleTableViewState();
}

class _RoleTableViewState extends State<RoleTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<Role> paginatedRoles;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant RoleTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.roleData.length);
    setState(() {
      paginatedRoles = widget.roleData.sublist(start, end);
      final totalPages = (widget.roleData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
        paginatedRoles = widget.roleData.sublist(start, end);
      }
    });
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

  Future<void> deleteRole(Role role) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete role "${role.roleName}"?',
        ),
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
      widget.onDelete(role);
      _updatePagination();
    }
  }

  // Navigate to EditRoleScreen
  Future<void> onEditRole(Role role) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoleScreen(
          roleId: role.id.toString(),
          roleName: role.roleName,
          selectedPermissions: role.permissions,
        ),
      ),
    );

    // If result is returned (updated role), call the onEdit callback
    if (result != null && result is Role) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  // Navigate to CreateRoleScreen
  Future<void> onCreateRole() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoleScreen()),
    );

    // If result is returned (new role), call the onEdit callback
    if (result != null && result is Role) {
      widget.onEdit(result);
      _updatePagination();
    }
  }

  // Navigate to ViewRoleScreen
  Future<void> onViewRole(Role role) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewRoleScreen(
          roleId: role.id.toString(),
          roleName: role.roleName,
          selectedPermissions: role.permissions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(
        label: Text('ID', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text(
          'Role Name',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text(
          'Permissions',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
      ),
    ];

    final rows = paginatedRoles.map((role) {
      final limitedPermissions = role.permissions.take(2).toList();
      final additionalCount =
          role.permissions.length - limitedPermissions.length;

      final List<Widget> permissionBadges = limitedPermissions
          .map(
            (perm) => BadgeChip(
              label: perm,
              type: ChipType.status,
              statusKey: perm,
              statusColorFunc: (_) => colorScheme.primary,
            ),
          )
          .toList();

      if (additionalCount > 0) {
        permissionBadges.add(
          BadgeChip(
            label: '+$additionalCount',
            type: ChipType.status,
            statusColorFunc: (_) => colorScheme.primary,
          ),
        );
      }

      return DataRow(
        cells: [
          DataCell(
            Text(
              role.id.toString(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(role.roleName, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(Wrap(spacing: 6, runSpacing: 4, children: permissionBadges)),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => onEditRole(role),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onViewRole(role),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => deleteRole(role),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  child: const Text('Delete'),
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
                        Text(
                          'Roles',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            PrimaryButton(
                              label: 'Create Role',
                              onPressed: onCreateRole,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                              children: [
                                Expanded(
                                  child: CustomTable(
                                    columns: columns,
                                    rows: rows,
                                  ),
                                ),
                                _paginationBar(context),
                              ],
                            )
                          : RolesGridView(
                              roleList: widget.roleData,
                              rowsPerPage: rowsPerPage,
                              currentPage: currentPage,
                              onPageChanged: (page) {
                                setState(() {
                                  currentPage = page;
                                  _updatePagination();
                                });
                              },
                              onRowsPerPageChanged: (rows) {
                                setState(() {
                                  rowsPerPage = rows ?? rowsPerPage;
                                  currentPage = 0;
                                  _updatePagination();
                                });
                              },
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

  Widget _paginationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final totalPages = (widget.roleData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.roleData.length);

    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;

    if (totalPages > windowSize) {
      if (currentPage <= 1) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (currentPage >= totalPages - 2) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = currentPage - 1;
        endWindow = currentPage + 2;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${widget.roleData.isEmpty ? 0 : start + 1} to $end of ${widget.roleData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0
                    ? () => gotoPage(currentPage - 1)
                    : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage
                          ? Colors.white
                          : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1
                    ? () => gotoPage(currentPage + 1)
                    : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: changeRowsPerPage,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text("page", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
