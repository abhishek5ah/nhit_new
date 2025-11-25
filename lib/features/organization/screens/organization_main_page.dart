import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart';
import 'package:ppv_components/features/organization/model/organization_model.dart';
import 'package:ppv_components/features/organization/screens/create_organization.dart';
import 'package:ppv_components/features/organization/screens/edit_organization.dart';
import 'package:ppv_components/features/organization/screens/view_organization.dart';
import 'package:ppv_components/features/organization/services/organizations_api_service.dart';

class OrganizationMainPage extends StatefulWidget {
  const OrganizationMainPage({super.key});

  @override
  State<OrganizationMainPage> createState() => _OrganizationMainPageState();
}

class _OrganizationMainPageState extends State<OrganizationMainPage> {
  List<OrganizationModel> organizations = [];
  bool isLoading = true;
  String? errorMessage;

  // Convert OrganizationModel to Organization for legacy screens
  Organization _convertToLegacyOrganization(OrganizationModel orgModel) {
    return Organization(
      id: orgModel.orgId.hashCode, // Convert string ID to int
      name: orgModel.name,
      code: orgModel.code,
      status: orgModel.status == 'activated' ? 'Active' : 'Inactive',
      createdBy: orgModel.createdByDisplay, // Use new fallback method
      createdDate: '${orgModel.createdAt.day}/${orgModel.createdAt.month}/${orgModel.createdAt.year}',
      description: orgModel.description,
      logoPath: orgModel.logo.isNotEmpty ? orgModel.logo : null,
      projects: orgModel.initialProjects,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final orgService = context.read<OrganizationsApiService>();
      final result = await orgService.loadOrganizations();
      
      if (result.success) {
        setState(() {
          organizations = orgService.organizations;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = result.message ?? 'Failed to load organizations';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading organizations: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'activated':
        return Colors.green;
      case 'deactivated':
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

  Future<void> _editOrganization(OrganizationModel org) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrganizationScreen(
          organization: _convertToLegacyOrganization(org),
          organizationModel: org,
        ),
      ),
    );
    if (result != null) _loadOrganizations();
  }

  Future<void> _viewOrganization(OrganizationModel org) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewOrganizationScreen(
          organization: _convertToLegacyOrganization(org),
        ),
      ),
    );
  }

  Future<void> _toggleOrganizationStatus(OrganizationModel org) async {
    final newStatus = org.status == 'activated' ? 'deactivated' : 'activated';
    final actionText = org.status == 'activated' ? 'deactivate' : 'activate';

    final shouldToggle = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${actionText == 'activate' ? 'Activate' : 'Deactivate'} Organization'),
        content: Text(
          'Are you sure you want to $actionText ${org.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: newStatus == 'activated' ? Colors.green : Colors.orange,
            ),
            child: Text(actionText == 'activate' ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldToggle == true) {
      try {
        final orgService = context.read<OrganizationsApiService>();
        final updateRequest = UpdateOrganizationRequest(
          orgId: org.orgId,
          name: org.name,
          code: org.code,
          description: org.description,
          logo: org.logo,
          status: newStatus,
        );
        
        final result = await orgService.updateOrganization(org.orgId, updateRequest);
        
        if (result.success) {
          await _loadOrganizations();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Organization ${actionText}d successfully'),
                backgroundColor: newStatus == 'activated' ? Colors.green : Colors.orange,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? 'Failed to update organization'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Future<void> _deleteOrganization(OrganizationModel org) async {
  //   final shouldDelete = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Confirm Delete'),
  //       content: Text('Are you sure you want to delete ${org.name}?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (shouldDelete == true) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Delete functionality not yet implemented'),
  //           backgroundColor: Colors.orange,
  //         ),
  //       );
  //     }
  //   }
  // }

  Widget _buildOrganizationLogo(OrganizationModel org, ColorScheme colorScheme) {
    // If logo URL exists, show the network image
    if (org.logo.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            org.logo,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // If image fails to load, show initials badge
              return _buildInitialsBadge(org, colorScheme);
            },
          ),
        ),
      );
    }

    // If no logo, show initials badge
    return _buildInitialsBadge(org, colorScheme);
  }

  Widget _buildInitialsBadge(OrganizationModel org, ColorScheme colorScheme) {
    final nameParts = org.name.split(' ');
    final badgeText = nameParts.length >= 2
        ? nameParts[0][0] + nameParts[1][0]
        : org.name.substring(0, 2);

    return Container(
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
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Organizations didn’t load. Please refresh.',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrganizations,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (organizations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Organizations Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first organization to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createOrganization,
              icon: const Icon(Icons.add),
              label: const Text('Create Organization'),
            ),
          ],
        ),
      );
    }

    return CustomTable(
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
        // Truncate the description
        String displayDescription = org.description;
        if (displayDescription.length > 70) {
          displayDescription = '${displayDescription.substring(0, 70)}...';
        }

        return DataRow(
          cells: [
            // Organization name + logo/badge
          DataCell(
  SizedBox(
    width: double.infinity,
    child: Row(
      children: [
        _buildOrganizationLogo(org, colorScheme),
        const SizedBox(width: 12),
        
        Expanded( // <-- important
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Text(
                org.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              
              if (org.description.isNotEmpty)
                Text(
                  displayDescription,
                  maxLines: 1, // or 2
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  ),
),

            // Code badge
            DataCell(
              BadgeChip(
                label: org.code,
                type: ChipType.status,
                statusKey: 'code',
                statusColorFunc: (_) => colorScheme.secondaryContainer,
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

            // Created by with enhanced fallback and missing data indicator
            DataCell(
              Row(
                children: [
                  Expanded(
                    child: Text(
                      org.createdByDisplay,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: org.isMissingCreatedBy 
                            ? colorScheme.onSurface.withValues(alpha: 0.5)
                            : colorScheme.onSurface,
                        fontStyle: org.isMissingCreatedBy 
                            ? FontStyle.italic 
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  if (org.isMissingCreatedBy)
                    Tooltip(
                      message: 'Creator information not available from API',
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
            ),

            // Created date
            DataCell(
              Text(
                '${org.createdAt.day}/${org.createdAt.month}/${org.createdAt
                    .year}',
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
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                    color: colorScheme.primary,
                    tooltip: 'View',
                    onPressed: () => _viewOrganization(org),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: colorScheme.tertiary,
                    tooltip: 'Edit',
                    onPressed: () => _editOrganization(org),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.tertiary.withValues(
                          alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      org.status == 'activated'
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      size: 20,
                    ),
                    color: org.status == 'activated' ? Colors.green : Colors
                        .orange,
                    tooltip: org.status == 'activated'
                        ? 'Deactivate'
                        : 'Activate',
                    onPressed: () => _toggleOrganizationStatus(org),
                    style: IconButton.styleFrom(
                      backgroundColor: org.status == 'activated'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                    ),
                  ),


                  // const SizedBox(width: 4),
                  // IconButton(
                  //   icon: const Icon(Icons.delete_outline, size: 20),
                  //   color: colorScheme.error,
                  //   tooltip: 'Delete',
                  //   onPressed: () => _deleteOrganization(org),
                  //   style: IconButton.styleFrom(
                  //     backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                  //   ),
                  // ),


                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
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
              child: _buildContent(context, theme, colorScheme),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}