import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';
import 'package:ppv_components/features/roles/screens/view_role.dart';
import 'package:ppv_components/features/roles/widgets/roles_grid.dart';
import 'package:ppv_components/features/roles/screens/edit_role.dart';
import 'package:ppv_components/features/roles/screens/create_role.dart';

class RoleTableView extends StatefulWidget {
  final List<RoleModel> roleData;
  final Future<void> Function(RoleModel) onDelete;
  final Future<void> Function() onRefresh;

  const RoleTableView({
    super.key,
    required this.roleData,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<RoleTableView> createState() => _RoleTableViewState();
}

class _RoleTableViewState extends State<RoleTableView> {
  int toggleIndex = 0;
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<RoleModel> paginatedRoles;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant RoleTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.roleData.length != oldWidget.roleData.length) {
      currentPage = 0;
    }
    _updatePagination();
  }

  void _updatePagination() {
    final totalPages = (widget.roleData.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    final start = (currentPage * rowsPerPage).clamp(0, widget.roleData.length);
    final end = (start + rowsPerPage).clamp(0, widget.roleData.length);
    setState(() {
      paginatedRoles = widget.roleData.sublist(start, end);
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

  Future<void> deleteRole(RoleModel role) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete role "${role.name}"?',
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
      await widget.onDelete(role);
      await widget.onRefresh();
    }
  }

  Future<void> onEditRole(RoleModel role) async {
    if (role.roleId == null) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoleScreen(
          roleId: role.roleId!,
          roleName: role.name,
          selectedPermissions: role.permissions,
        ),
      ),
    );

    if (result != null && result == true) {
      await widget.onRefresh();
    }
  }

  Future<void> onCreateRole() async {
    final result = await context.push<bool>('/roles/create');

    if (result == true) {
      await widget.onRefresh();
    }
  }


  Future<void> onViewRole(RoleModel role) async {
    if (role.roleId == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewRoleScreen(
          roleId: role.roleId!,
          roleName: role.name,
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
          textColor: colorScheme.onPrimary,
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
              role.roleId?.substring(0, 8) ?? 'N/A',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(role.name, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(Wrap(spacing: 6, runSpacing: 4, children: permissionBadges)),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => onViewRole(role),
                  icon: const Icon(Icons.visibility_outlined),
                  color: colorScheme.primary,
                  iconSize: 20,
                  tooltip: 'View',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => onEditRole(role),
                  icon: const Icon(Icons.edit_outlined),
                  color: colorScheme.tertiary,
                  iconSize: 20,
                  tooltip: 'Edit',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.tertiary.withOpacity(0.1),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => deleteRole(role),
                  icon: const Icon(Icons.delete_outline),
                  color: colorScheme.error,
                  iconSize: 20,
                  tooltip: 'Delete',
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.error.withOpacity(0.1),
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
                          CustomPaginationBar(
                            totalItems: widget.roleData.length,
                            currentPage: currentPage,
                            rowsPerPage: rowsPerPage,
                            onPageChanged: gotoPage,
                            onRowsPerPageChanged: changeRowsPerPage,
                          ),
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
}
