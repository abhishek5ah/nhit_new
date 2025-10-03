  import 'package:flutter/material.dart';
  import 'package:ppv_components/common_widgets/button/toggle_button.dart';
  import 'package:ppv_components/common_widgets/custom_table.dart';
  import 'package:ppv_components/features/user/model/user_model.dart';
  import 'package:ppv_components/features/user/widgets/user_grid.dart';

  const List<String> availableRoles = [
    'Super Admin',
    'Admin',
    'ER Approver',
    'ER User',
    'GN Approver',
    'GN User',
    'PN Approver',
    'PN User',
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
      _updatePagination();
    }

    void _updatePagination() {
      final start = currentPage * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, widget.userData.length);
      setState(() {
        paginatedUsers = widget.userData.sublist(start, end);
        final totalPages = (widget.userData.length / rowsPerPage).ceil();
        if (currentPage >= totalPages && totalPages > 0) {
          currentPage = totalPages - 1;
          paginatedUsers = widget.userData.sublist(start, end);
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
      final formKey = GlobalKey<FormState>();
      final nameController = TextEditingController(text: user.name);
      final usernameController = TextEditingController(text: user.username);
      final emailController = TextEditingController(text: user.email);
      List<String> selectedRoles = List.from(user.roles);
      bool isActive = user.isActive;

      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final colorScheme = Theme.of(ctx).colorScheme;

          return Dialog(
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.4,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline, width: 0.5),
                borderRadius: BorderRadius.circular(20),
                color: colorScheme.surface, // edit modal background color
              ),
              child: StatefulBuilder(
                builder: (context, setState) => SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Edit User",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Input Fields
                        _buildInputField(
                          context,
                          Icons.person,
                          "Name",
                          nameController,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          context,
                          Icons.alternate_email,
                          "Username",
                          usernameController,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          context,
                          Icons.email,
                          "Email",
                          emailController,
                        ),
                        const SizedBox(height: 20),

                        // Roles Selector
                        Text(
                          "Roles",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: availableRoles.map((role) {
                            final selected = selectedRoles.contains(role);
                            return FilterChip(
                              label: Text(role),
                              selected: selected,
                              onSelected: (value) {
                                setState(() {
                                  if (value) {
                                    selectedRoles.add(role);
                                  } else {
                                    selectedRoles.remove(role);
                                  }
                                });
                              },
                              selectedColor: colorScheme.primaryContainer,
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        // Active Status
                        Row(
                          children: [
                            Text(
                              "Active Status",
                              style: TextStyle(
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Switch(
                              value: isActive,
                              onChanged: (value) =>
                                  setState(() => isActive = value),
                              activeColor: colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isActive ? "Active" : "Inactive",
                              style: TextStyle(color: colorScheme.onSurface),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Buttons
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Save"),
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
        },
        barrierDismissible: false,
      );

      if (result == true) {
        final updatedUser = user.copyWith(
          name: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          roles: selectedRoles,
          isActive: isActive,
        );
        widget.onEdit(updatedUser);
        _updatePagination();
      }
    }

    Widget _buildInputField(
      BuildContext context,
      IconData icon,
      String label,
      TextEditingController controller,
    ) {
      final theme = Theme.of(context);
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainer,// edit modal input background
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
          if (label == "Email" && !val.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      );
    }

    Future<void> onViewUser(User user) async {
      await showDialog(
        context: context,
        builder: (ctx) {
          final colorScheme = Theme.of(ctx).colorScheme;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: colorScheme.surface, // view modal background color
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.4,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline, width: 0.5),
                borderRadius: BorderRadius.circular(20), // match Dialog shape radius
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "User Details",
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
                  _buildDetail(
                    ctx,
                    Icons.confirmation_number,
                    "ID",
                    user.id.toString(),
                  ),
                  _buildDetail(ctx, Icons.person, "Name", user.name),
                  _buildDetail(
                    ctx,
                    Icons.alternate_email,
                    "Username",
                    user.username,
                  ),
                  _buildDetail(ctx, Icons.email, "Email", user.email),
                  _buildDetail(ctx, Icons.badge, "Roles", user.roles.join(', ')),
                  _buildStatus(ctx, user.isActive ? "Active" : "Inactive"),
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


    Widget _buildDetail(
      BuildContext ctx,
      IconData icon,
      String label,
      String value,
    ) {
      final colorScheme = Theme.of(ctx).colorScheme;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer, //edit modal input background color
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(width: 12),
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

    Widget _buildStatus(BuildContext ctx, String status) {
      final colorScheme = Theme.of(ctx).colorScheme;
      final isActive = status == "Active";
      final bg = isActive
          ? colorScheme.secondaryContainer
          : colorScheme.errorContainer;
      final txt = isActive
          ? colorScheme.onSecondaryContainer
          : colorScheme.onErrorContainer;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer, // edit modal status section background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.verified, color: colorScheme.primary, size: 22),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Text(
                "Status",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(color: txt, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      // table header column
      final columns = [
        DataColumn(
          label: Text('ID', style: TextStyle(color: colorScheme.onSurface)),
        ),
        DataColumn(
          label: Text('Name', style: TextStyle(color: colorScheme.onSurface)),
        ),
        DataColumn(
          label: Text('Username', style: TextStyle(color: colorScheme.onSurface)),
        ),
        DataColumn(
          label: Text('Email', style: TextStyle(color: colorScheme.onSurface)),
        ),
        DataColumn(
          label: Text('Roles', style: TextStyle(color: colorScheme.onSurface)),
        ),
        DataColumn(
          label: Text('Active', style: TextStyle(color: colorScheme.onSurface)),
        ),
        DataColumn(
          label: Text('Actions', style: TextStyle(color: colorScheme.onSurface)),
        ),
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
              child: Text(
                role,
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 12),
              ),
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
            DataCell(
              Text(
                user.id.toString(),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            DataCell(
              Text(user.name, style: TextStyle(color: colorScheme.onSurface)),
            ),
            DataCell(
              Text(user.username, style: TextStyle(color: colorScheme.onSurface)),
            ),
            DataCell(
              Text(user.email, style: TextStyle(color: colorScheme.onSurface)),
            ),
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
                  OutlinedButton(
                    onPressed: () => onEditUser(user),
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
                    onPressed: () => onViewUser(user),
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
                    onPressed: () => deleteUser(user),
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
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          ToggleBtn(
                            labels: ['Table', 'Grid'],
                            selectedIndex: toggleIndex,
                            onChanged: (index) =>
                                setState(() => toggleIndex = index),
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
                            : UserGridView(
                                userList: widget.userData,
                                rowsPerPage: rowsPerPage,
                                currentPage: currentPage,
                                onPageChanged: (page) =>
                                    setState(() => currentPage = page),
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

    Widget _paginationBar(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      final totalPages = (widget.userData.length / rowsPerPage).ceil();
      final start = currentPage * rowsPerPage;
      final end = (start + rowsPerPage).clamp(0, widget.userData.length);

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
              "Showing ${widget.userData.isEmpty ? 0 : start + 1} to $end of ${widget.userData.length} entries",
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
