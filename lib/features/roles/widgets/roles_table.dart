import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/roles/model/roles_model.dart';
import 'package:ppv_components/features/roles/widgets/roles_grid.dart';

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
        content: Text('Are you sure you want to delete role "${role.roleName}"?'),
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

  Future<void> onEditRole(Role role) async {
    final formKey = GlobalKey<FormState>();
    final roleNameController = TextEditingController(text: role.roleName);
    final permissionsController = TextEditingController(text: role.permissions.join(', '));

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _roleDialog(
        ctx: ctx,
        formKey: formKey,
        roleNameController: roleNameController,
        permissionsController: permissionsController,
        dialogTitle: "Edit Role",
        saveLabel: "Save",
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      final updatedRole = role.copyWith(
        roleName: roleNameController.text,
        permissions: permissionsController.text.split(',').map((e) => e.trim()).toList(),
      );
      widget.onEdit(updatedRole);
      _updatePagination();
    }
  }

  Future<void> onAddRole() async {
    final formKey = GlobalKey<FormState>();
    final roleNameController = TextEditingController();
    final permissionsController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _roleDialog(
        ctx: ctx,
        formKey: formKey,
        roleNameController: roleNameController,
        permissionsController: permissionsController,
        dialogTitle: "Add Role",
        saveLabel: "Add",
      ),
      barrierDismissible: false,
    );

    if (result == true && roleNameController.text.isNotEmpty) {
      final newRole = Role(
        id: DateTime.now().millisecondsSinceEpoch,
        roleName: roleNameController.text,
        permissions: permissionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((perm) => perm.isNotEmpty)
            .toList(),
      );
      widget.onEdit(newRole);
      _updatePagination();
    }
  }

  Widget _roleDialog({
    required BuildContext ctx,
    required GlobalKey<FormState> formKey,
    required TextEditingController roleNameController,
    required TextEditingController permissionsController,
    required String dialogTitle,
    required String saveLabel,
  }) {
    final colorScheme = Theme.of(ctx).colorScheme;
    return Dialog(
      child: Container(
        width: MediaQuery.of(ctx).size.width * 0.4,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline, width: 0.5),
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dialogTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: Icon(Icons.close, color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(ctx, "Role Name", roleNameController),
                  const SizedBox(height: 20),
                  _buildInputField(
                    ctx,
                    "Permissions (comma separated)",
                    permissionsController,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.of(ctx).pop(true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(saveLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController controller) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      maxLines: label.contains('Permission') ? 3 : 1,
    );
  }

  Future<void> onViewRole(Role role) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: colorScheme.surface,
          child: Container(
            width: MediaQuery.of(ctx).size.width * 0.4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline, width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Role Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDetail(ctx, "ID", role.id.toString()),
                _buildDetail(ctx, "Role Name", role.roleName),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Permissions",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: role.permissions
                            .map((perm) => BadgeChip(
                          label: perm,
                          type: ChipType.status,
                          statusKey: perm,
                          statusColorFunc: (_) => colorScheme.primary,
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetail(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Role Name', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Permissions', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Actions', style: TextStyle(color: colorScheme.onSurface))),
    ];

    final rows = paginatedRoles.map((role) {
      final limitedPermissions = role.permissions.take(2).toList();
      final additionalCount = role.permissions.length - limitedPermissions.length;

      final List<Widget> permissionBadges = limitedPermissions
          .map((perm) => BadgeChip(
        label: perm,
        type: ChipType.status,
        statusKey: perm,
        statusColorFunc: (_) => colorScheme.primary,
      ))
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
            Text(role.id.toString(), style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Text(role.roleName, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(
            Wrap(spacing: 6, runSpacing: 4, children: permissionBadges),
          ),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => onEditRole(role),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => onViewRole(role),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => deleteRole(role),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                              label: 'Add Role',
                              onPressed: onAddRole,
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
                onPressed: currentPage > 0 ? () => gotoPage(currentPage - 1) : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      i == currentPage ? colorScheme.primary : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage ? Colors.white : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1 ? () => gotoPage(currentPage + 1) : null,
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
