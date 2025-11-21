// lib/screens/edit_role_screen.dart
import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class EditRoleScreen extends StatefulWidget {
  final String roleId;
  final String roleName;
  final List<String> selectedPermissions;

  const EditRoleScreen({
    super.key,
    required this.roleId,
    required this.roleName,
    required this.selectedPermissions,
  });

  @override
  State<EditRoleScreen> createState() => _EditRoleScreenState();
}

class _EditRoleScreenState extends State<EditRoleScreen> {
  final TextEditingController _roleNameController = TextEditingController();
  final Map<String, bool> _permissions = {};

  @override
  void initState() {
    super.initState();
    // Initialize role name
    _roleNameController.text = widget.roleName;

    // Initialize all permissions with false
    for (var permission in _allPermissions) {
      _permissions[permission] = false;
    }

    // Set selected permissions to true
    for (var permission in widget.selectedPermissions) {
      if (_permissions.containsKey(permission)) {
        _permissions[permission] = true;
      }
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  // All permissions from the image
 final List<String> _allPermissions = [
    // Dashboard & Reports
    'view-dashboard',
    'view-reports',
    'export-data',
    
    // User Management
    'view-user',
    'create-user',
    'edit-user',
    'delete-user',
    
    // Role Management
    'view-role',
    'create-role',
    'edit-role',
    'delete-role',
    
    // Department Management
    'view-department',
    'create-department',
    'edit-department',
    'delete-department',
    
    // Designation Management
    'view-designation',
    'create-designation',
    'edit-designation',
    'delete-designation',
    
    // Note Management
    'view-note',
    'create-note',
    'edit-note',
    'delete-note',
    'approve-note',
    'reject-note',
    'view-all-notes',
    'export-notes',
    
    // Payment Note Management
    'view-payment-note',
    'create-payment-note',
    'edit-payment-note',
    'delete-payment-note',
    'approve-payment-note',
    'reject-payment-note',
    'view-all-payment-notes',
    'export-payment-notes',
    
    // Reimbursement Note Management
    'view-reimbursement-note',
    'create-reimbursement-note',
    'edit-reimbursement-note',
    'delete-reimbursement-note',
    'approve-reimbursement-note',
    'reject-reimbursement-note',
    'view-all-reimbursement-notes',
    'export-reimbursement-notes',
    
    // Vendor Management
    'view-vendors',
    'create-vendors',
    'edit-vendors',
    'delete-vendors',
    
    // Payment Management
    'view-payment',
    'create-payment',
    'edit-payment',
    'delete-payment',
    'approve-payment',
    'import-payment-excel',
    
    // Rule Management
    'view-rule',
    'create-rule',
    'edit-rule',
    'delete-rule',
    
    // Bank Letters
    'view-bank-letters',
    'create-bank-letters',
    'edit-bank-letters',
    'delete-bank-letters',
    'approve-bank-letter',
    
    // Organization Management
    'view-organizations',
    'create-organizations',
    'edit-organizations',
    'delete-organizations',
    'switch-organizations',
    
    // Logs & Audits
    'view-activity-logs',
    'view-audit-trail',
    
    // Ticket Management
    'view-tickets',
    'create-tickets',
    'edit-tickets',
    'delete-tickets',
    'assign-tickets',
    
    // Approvers
    'level-1-approver',
    'level-2-approver',
    'level-3-approver',
    'final-approver',
    
    // System
    'system-configuration',
    'view-system-logs',
  ];

  void _selectAllPermissions() {
    setState(() {
      for (var key in _permissions.keys) {
        _permissions[key] = true;
      }
    });
  }

  void _deselectAllPermissions() {
    setState(() {
      for (var key in _permissions.keys) {
        _permissions[key] = false;
      }
    });
  }

  void _updateRole() {
    final colorScheme = Theme.of(context).colorScheme;

    if (_roleNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter role name',
            style: TextStyle(
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: colorScheme.primary,
        ),
      );
      return;
    }

    final selectedPermissions = _permissions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select at least one permission',
            style: TextStyle(
              color: colorScheme.onPrimary,
            ),
          ),
          backgroundColor: colorScheme.primary,
        ),
      );
      return;
    }

    // TODO: Implement your API call here
    print('Role ID: ${widget.roleId}');
    print('Updated Role Name: ${_roleNameController.text}');
    print('Updated Permissions: $selectedPermissions');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Role updated with ${selectedPermissions.length} permissions',
          style: TextStyle(
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.orange[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Role',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update role details and permissions',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // Show permissions guide
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Permissions Guide'),
                              content: const SingleChildScrollView(
                                child: Text(
                                  'Permissions define what actions a user with this role can perform in the system.',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('Permissions Guide'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          side: BorderSide(color: Colors.blue[600]!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back to Roles'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.onSurface,
                          side: BorderSide(
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Role Information Section
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Role Information',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Role Name',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _roleNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter role name',
                      hintStyle: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Permissions Section
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security_outlined,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Permissions',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              backgroundColor: colorScheme.surface,
                              title: Text(
                                'Manage Permissions',
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _selectAllPermissions();
                                      Navigator.pop(dialogContext);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                    ),
                                    child: const Text('Select All'),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton(
                                    onPressed: () {
                                      _deselectAllPermissions();
                                      Navigator.pop(dialogContext);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: colorScheme.outline,
                                      ),
                                      foregroundColor: colorScheme.onSurface,
                                    ),
                                    child: const Text('Deselect All'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'What do these permissions mean?',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Permissions Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 1200
                          ? 4
                          : constraints.maxWidth > 800
                          ? 3
                          : constraints.maxWidth > 600
                          ? 2
                          : 1;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: 8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _allPermissions.length,
                        itemBuilder: (context, index) {
                          final permission = _allPermissions[index];
                          return _buildPermissionCheckbox(permission);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SecondaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  label: 'Cancel',
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  onPressed: _updateRole,
                  label: 'Create Role',
                ),
              ],
            ),                  ],
        ),
      ),
    );
  }

  Widget _buildPermissionCheckbox(String permission) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        setState(() {
          _permissions[permission] = !_permissions[permission]!;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _permissions[permission],
              onChanged: (value) {
                setState(() {
                  _permissions[permission] = value ?? false;
                });
              },
              activeColor: colorScheme.primary,
              checkColor: colorScheme.onPrimary,
              side: BorderSide(
                color: colorScheme.outline,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              permission,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
