// lib/screens/create_role_screen.dart
import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';

class CreateRoleScreen extends StatefulWidget {
  const CreateRoleScreen({super.key});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final TextEditingController _roleNameController = TextEditingController();
  final Map<String, bool> _permissions = {};

  @override
  void initState() {
    super.initState();
    // Initialize all permissions with false
    for (var permission in _allPermissions) {
      _permissions[permission] = false;
    }
  }

  @override
  void dispose() {
    _roleNameController.dispose();
    super.dispose();
  }

  // All permissions from the image
  final List<String> _allPermissions = [
    'manage-users',
    'manage-roles',
    'manage-permissions',
    'manage-tickets',
    'manage-vendors',
    'view-beneficiaries',
    'manage-beneficiaries',
    'view-dashboard',
    'manage-settings',
    'view-reports',
    'export-data',
    'import-data',
    'view-user',
    'create-user',
    'edit-user',
    'delete-user',
    'manage-user-roles',
    'view-user-activity',
    'reset-user-password',
    'activate-user',
    'deactivate-user',
    'view-role',
    'create-role',
    'edit-role',
    'delete-role',
    'assign-permissions',
    'view-permissions',
    'create-permissions',
    'edit-permissions',
    'delete-permissions',
    'view-department',
    'create-department',
    'edit-department',
    'delete-department',
    'manage-department-users',
    'view-designation',
    'create-designation',
    'edit-designation',
    'delete-designation',
    'view-note',
    'create-note',
    'edit-note',
    'delete-note',
    'approve-note',
    'reject-note',
    'hold-note',
    'release-note',
    'view-note-history',
    'export-notes',
    'bulk-approve-notes',
    'view-all-notes',
    'edit-any-note',
    'view-payment-note',
    'create-payment-note',
    'edit-payment-note',
    'delete-payment-note',
    'approve-payment-note',
    'reject-payment-note',
    'hold-payment-note',
    'release-payment-note',
    'view-payment-note-history',
    'view-all-payment-notes',
    'edit-any-payment-note',
    'create-draft-payment-note',
    'edit-draft-payment-note',
    'delete-draft-payment-note',
    'view-reimbursement-note',
    'create-reimbursement-note',
    'edit-reimbursement-note',
    'delete-reimbursement-note',
    'approve-reimbursement-note',
    'reject-reimbursement-note',
    'hold-reimbursement-note',
    'release-reimbursement-note',
    'view-reimbursement-note-history',
    'view-all-reimbursement-notes',
    'bulk-approve-reimbursement-notes',
    'edit-any-reimbursement-note',
    'create-all-user-reimbursement-note',
    'all-reimbursement-note',
    'approver-reimbursement-note',
    'view-vendors',
    'create-vendors',
    'edit-vendors',
    'delete-vendors',
    'activate-vendors',
    'deactivate-vendors',
    'view-vendor-history',
    'export-vendors',
    'approve-vendors',
    'view-vendors-excel',
    'manage-vendor-accounts',
    'create-vendor',
    'view-vendor',
    'view-vendor-accounts',
    'create-vendor-accounts',
    'edit-vendor-accounts',
    'delete-vendor-accounts',
    'set-primary-account',
    'activate-vendor-account',
    'deactivate-vendor-account',
    'view-beneficiary',
    'create-beneficiary',
    'edit-beneficiary',
    'delete-beneficiary',
    'approve-beneficiary',
    'deactivate-beneficiary',
    'manage-beneficiaries',
    'import-beneficiaries',
    'view-payment',
    'create-payment',
    'edit-payment',
    'delete-payment',
    'approve-payment',
    'reject-payment',
    'process-payment',
    'cancel-payment',
    'view-payment-history',
    'export-payments',
    'import-payment-excel',
    'bulk-process-payments',
    'view-payments',
    'manage-payments',
    'update-payment',
    'create-rule',
    'edit-rule',
    'delete-rule',
    'activate-rule',
    'deactivate-rule',
    'test-rule',
    'duplicate-rule',
    'view-rule-statistics',
    'payment-note-view-rule',
    'payment-note-create-rule',
    'payment-note-edit-rule',
    'payment-note-delete-rule',
    'view-escrow-accounts',
    'create-escrow-accounts',
    'edit-escrow-accounts',
    'delete-escrow-accounts',
    'activate-escrow-account',
    'deactivate-escrow-account',
    'view-escrow-balance',
    'view-escrow-signatories',
    'view-escrow-transfers',
    'create-account-transfers',
    'edit-account-transfers',
    'delete-account-transfers',
    'approve-account-transfer',
    'reject-account-transfer',
    'process-account-transfer',
    'cancel-account-transfer',
    'view-transfer-history',
    'view-bank-letters',
    'create-bank-letters',
    'edit-bank-letters',
    'delete-bank-letters',
    'approve-bank-letter',
    'manage-bank-letter',
    'view-bank-letter-pdf',
    'send-bank-letter',
    'view-bank-letter-history',
    'view-organizations',
    'create-organizations',
    'edit-organizations',
    'delete-organizations',
    'switch-organizations',
    'manage-organization-users',
    'view-organization-settings',
    'edit-organization-settings',
    'view-audit-logs',
    'export-audit-logs',
    'delete-audit-logs',
    'edit-tickets',
    'delete-tickets',
    'assign-tickets',
    'close-tickets',
    'reopen-tickets',
    'view-ticket-comments',
    'create-ticket-comments',
    'edit-ticket-comments',
    'delete-ticket-comments',
    'view-templates',
    'create-templates',
    'edit-templates',
    'delete-templates',
    'manage-supporting-docs',
    'upload-supporting-docs',
    'download-supporting-docs',
    'delete-supporting-docs',
    'view-accounts',
    'manage-accounts',
    'view-ratios',
    'manage-ratios',
    'superadmin-access',
    'system-configuration',
    'backup-system',
    'restore-system',
    'view-system-logs',
    'manage-system-maintenance',
    'level-1-approver',
    'level-2-approver',
    'level-3-approver',
    'level-4-approver',
    'level-5-approver',
    'final-approver',
    'emergency-approver',
    'bypass-approval',
    'view-financial-reports',
    'generate-financial-reports',
    'export-financial-data',
    'view-budget-reports',
    'manage-budget-allocation',
    'view-expense-analytics',
    'view-payment-analytics',
    'bulk-approve',
    'bulk-reject',
    'bulk-delete',
    'bulk-export',
    'bulk-import',
    'bulk-update',
    'view-sensitive-data',
    'edit-sensitive-data',
    'access-all-departments',
    'cross-department-access',
    'emergency-access',
    'after-hours-access',
    'view-product',
    'create-product',
    'edit-product',
    'delete-product',
    'view-notes',
    'manage-notes',
    'view-approvals',
    'manage-approvals',
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

  void _createRole() {
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
    print('Role Name: ${_roleNameController.text}');
    print('Selected Permissions: $selectedPermissions');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Role created with ${selectedPermissions.length} permissions',
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
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline,
                  width: 0.5,
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
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_circle_outline,
                          color: colorScheme.onPrimary.withValues(alpha: 0.9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Role',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fill in the details to create a new role with permissions',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

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
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '1',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                          // Show dialog to select/deselect all
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
                          'What are these permissions mean?',
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
                  onPressed: _createRole,
                  label: 'Create User',
                ),
              ],
            ),          ],
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
