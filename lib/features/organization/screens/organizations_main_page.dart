import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/features/organization/services/organization_service.dart';
import 'package:ppv_components/features/organization/data/models/organization_model.dart';
import 'package:ppv_components/features/organization/widgets/organization_card.dart';
import 'package:ppv_components/features/organization/widgets/add_organization_dialog.dart';

class OrganizationsMainPage extends StatefulWidget {
  const OrganizationsMainPage({super.key});

  @override
  State<OrganizationsMainPage> createState() => _OrganizationsMainPageState();
}

class _OrganizationsMainPageState extends State<OrganizationsMainPage> {
  @override
  void initState() {
    super.initState();
    // Load organizations when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizationService>().loadOrganizations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Organizations',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your organizations and switch between them',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add Organization Button
                    ElevatedButton.icon(
                      onPressed: () => _showAddOrganizationDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text(isDesktop ? 'Add Organization' : 'Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Organizations List
              Expanded(
                child: Consumer<OrganizationService>(
                  builder: (context, organizationService, child) {
                    if (organizationService.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (organizationService.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading organizations',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              organizationService.error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => organizationService.loadOrganizations(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (organizationService.organizations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Organizations Found',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first organization to get started',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddOrganizationDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Organization'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Organizations Grid
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : (screenWidth > 600 ? 2 : 1),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isDesktop ? 1.2 : 1.1,
                      ),
                      itemCount: organizationService.organizations.length,
                      itemBuilder: (context, index) {
                        final organization = organizationService.organizations[index];
                        final isCurrentOrg = organizationService.currentOrganization?.orgId == organization.orgId;
                        
                        return OrganizationCard(
                          organization: organization,
                          isCurrentOrganization: isCurrentOrg,
                          onSwitch: () => _switchOrganization(context, organization),
                          onEdit: () => _editOrganization(context, organization),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddOrganizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddOrganizationDialog(),
    );
  }

  void _switchOrganization(BuildContext context, OrganizationModel organization) async {
    final organizationService = context.read<OrganizationService>();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await organizationService.switchOrganization(organization);
    
    // Close loading indicator
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    if (result.success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Organization switched successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        // Navigate to dashboard after switching
        context.go('/dashboard');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Failed to switch organization'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _editOrganization(BuildContext context, OrganizationModel organization) {
    // TODO: Implement edit organization dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit organization feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
