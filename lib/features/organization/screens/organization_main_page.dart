import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/organization/model/organization_model.dart';
import 'package:ppv_components/features/organization/data/organization_mockdb.dart';
import 'package:ppv_components/features/organization/screens/create_organization.dart';
import 'package:ppv_components/features/organization/screens/edit_organization.dart';
import 'package:ppv_components/features/organization/screens/view_organization.dart';

class OrganizationMainPage extends StatefulWidget {
  const OrganizationMainPage({super.key});

  @override
  State<OrganizationMainPage> createState() => _OrganizationMainPageState();
}

class _OrganizationMainPageState extends State<OrganizationMainPage> {
  List<Organization> organizations = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  void _loadOrganizations() {
    setState(() {
      organizations = OrganizationMockDB.organizations;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _createOrganization() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrganizationScreen(),
      ),
    );
    if (result != null) _loadOrganizations();
  }

  Future<void> _editOrganization(Organization org) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrganizationScreen(organization: org),
      ),
    );
    if (result != null) _loadOrganizations();
  }

  Future<void> _viewOrganization(Organization org) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewOrganizationScreen(organization: org),
      ),
    );
  }

  Future<void> _deleteOrganization(Organization org) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${org.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        OrganizationMockDB.delete(org.id);
        _loadOrganizations();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organization deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.business,
                            color: colorScheme.onPrimary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organizations Management',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your organizations',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PrimaryButton(
                    onPressed: _createOrganization,
                    label: 'Add Organization',
                    icon: Icons.add,
                  ),
                ],
              ),
            ),
          ),

          // Table section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomTable(
                minTableWidth: 900,
                columns: const [
                  DataColumn(label: Text('ORGANIZATION')),
                  DataColumn(label: Text('CODE')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('CREATED BY')),
                  DataColumn(label: Text('CREATED')),
                  DataColumn(label: Text('ACTIONS')),
                ],
                rows: organizations.map((org) {
                  final nameParts = org.name.split(' ');
                  final badgeText = nameParts.length >= 2
                      ? nameParts[0][0] + nameParts[1][0]
                      : org.name.substring(0, 2);

                  // Truncate the description
                  String displayDescription = org.description ?? '';
                  if (displayDescription.length > 70) {
                    displayDescription =
                    '${displayDescription.substring(0, 70)}...';
                  }

                  return DataRow(
                    cells: [
                      // Organization name + badge
                      DataCell(Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                badgeText.toUpperCase(),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  org.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (org.description != null &&
                                    org.description!.isNotEmpty)
                                  Text(
                                    displayDescription, // Use truncated description
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                      colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )),

                      // Code badge
                      DataCell(
                        BadgeChip(
                          label: org.code,
                          type: ChipType.status,
                          statusKey: 'code',
                          statusColorFunc: (_) =>
                          colorScheme.secondaryContainer,
                        ),
                      ),

                      // Status badge
                      DataCell(
                        BadgeChip(
                          label: org.status,
                          type: ChipType.status,
                          statusKey: org.status,
                          statusColorFunc: _getStatusColor,
                          textColor: colorScheme.surface,
                        ),
                      ),

                      // Created by
                      DataCell(
                        Text(
                          org.createdBy,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // Created date
                      DataCell(
                        Text(
                          org.createdDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),

                      // Action buttons
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined,
                                  size: 20),
                              color: colorScheme.primary,
                              tooltip: 'View',
                              onPressed: () => _viewOrganization(org),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                colorScheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              color: colorScheme.tertiary,
                              tooltip: 'Edit',
                              onPressed: () => _editOrganization(org),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                colorScheme.tertiary.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined,
                                  size: 20),
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              tooltip: 'Settings',
                              onPressed: () {},
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.content_copy_outlined,
                                  size: 20),
                              color: colorScheme.secondary,
                              tooltip: 'Duplicate',
                              onPressed: () {},
                              style: IconButton.styleFrom(
                                backgroundColor:
                                colorScheme.secondary.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              color: colorScheme.error,
                              tooltip: 'Delete',
                              onPressed: () => _deleteOrganization(org),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                colorScheme.error.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
