import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/badge.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/core/accessibility/accessible_widgets.dart';
import 'package:ppv_components/core/accessibility/accessibility_utils.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart' as api;
import 'package:ppv_components/features/organization/model/organization_model.dart' as legacy;
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
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  bool _isLoading = false;
  String? _error;
  final FocusNode _skipNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _tableKey = GlobalKey();
  String _searchQuery = '';
  bool _isSkipLinkVisible = false;

  // Convert OrganizationModel to Organization for legacy screens
  legacy.Organization _convertToLegacyOrganization(api.OrganizationModel orgModel) {
    return legacy.Organization(
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
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrganizations();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _skipNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _skipToMainContent() {
    if (_tableKey.currentContext != null) {
      Scrollable.ensureVisible(
        _tableKey.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
      AccessibilityUtils.announceToScreenReader(
        context,
        'Focused on organizations table',
      );
    }
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orgService = context.read<OrganizationsApiService>();
      final result = await orgService.loadOrganizations();

      if (result.success) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.message ?? 'Failed to load organizations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading organizations: $e';
        _isLoading = false;
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

  Future<void> _editOrganization(api.OrganizationModel org) async {
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

  Future<void> _viewOrganization(api.OrganizationModel org) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewOrganizationScreen(
          orgId: org.orgId,
          initialOrganization: org,
        ),
      ),
    );
  }

  Future<void> _toggleOrganizationStatus(api.OrganizationModel org) async {
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
        final updateRequest = api.UpdateOrganizationRequest(
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

  Widget _buildOrganizationLogo(api.OrganizationModel org, ColorScheme colorScheme) {
    // If logo URL exists, show the network image
    if (org.logo.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
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

  Widget _buildInitialsBadge(api.OrganizationModel org, ColorScheme colorScheme) {
    final nameParts = org.name.split(' ');
    final badgeText = nameParts.length >= 2
        ? nameParts[0][0] + nameParts[1][0]
        : org.name.substring(0, 2);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha:0.7),
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

  List<api.OrganizationModel> _filterOrganizations(
    List<api.OrganizationModel> organizations,
    String query,
  ) {
    if (query.isEmpty) return organizations;
    final lowerQuery = query.toLowerCase();
    return organizations.where((org) {
      final createdBy = org.createdByDisplay.toLowerCase();
      final status = org.status.toLowerCase();
      return org.name.toLowerCase().contains(lowerQuery) ||
          org.code.toLowerCase().contains(lowerQuery) ||
          createdBy.contains(lowerQuery) ||
          status.contains(lowerQuery);
    }).toList();
  }

  void _handleSearchChanged(String value) {
    final query = value.trim();
    setState(() => _searchQuery = query);
    final orgService = context.read<OrganizationsApiService>();
    final results = _filterOrganizations(orgService.organizations, query);
    AccessibilityUtils.announceToScreenReader(
      context,
      results.isEmpty
          ? 'No organizations match $query.'
          : '${results.length} organizations shown for $query.',
      assertive: true,
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    List<api.OrganizationModel> allOrganizations,
    List<api.OrganizationModel> displayedOrganizations,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrganizations,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (allOrganizations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No Organizations Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first organization to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createOrganization,
              icon: Icon(Icons.add),
              label: Text('Create Organization'),
            ),
          ],
        ),
      );
    }

    if (displayedOrganizations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'No organizations match "$_searchQuery"',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search terms.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: 'Organizations data table',
      container: true,
      child: CustomTable(
        minTableWidth: 900,
        
        columns: [
          DataColumn(label: Semantics(header: true, child: Text('ORGANIZATION'))),
          DataColumn(label: Semantics(header: true, child: Text('CODE'))),
          DataColumn(label: Semantics(header: true, child: Text('STATUS'))),
          DataColumn(label: Semantics(header: true, child: Text('CREATED BY'))),
          DataColumn(label: Semantics(header: true, child: Text('CREATED'))),
          DataColumn(label: Semantics(header: true, child: Text('ACTIONS'))),
        ],
        rows: displayedOrganizations.map((org) {
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

                      Expanded(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
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
                Semantics(
                  label: 'Organization code ${org.code}',
                  child: BadgeChip(
                    label: org.code,
                    type: ChipType.status,
                    statusKey: 'code',
                    statusColorFunc: (_) => colorScheme.secondaryContainer,
                  ),
                ),
              ),

              // Status badge
              DataCell(
                Semantics(
                  label: 'Status ${org.status}',
                  child: BadgeChip(
                    label: org.status,
                    type: ChipType.status,
                    statusKey: org.status,
                    statusColorFunc: _getStatusColor,
                    textColor: colorScheme.surface,
                  ),
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
                              ? colorScheme.onSurface.withOpacity(0.5)
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
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),

              // Created date
              DataCell(
                Semantics(
                  label: 'Created on ${org.createdAt.day}/${org.createdAt.month}/${org.createdAt.year}',
                  child: Text(
                    '${org.createdAt.day}/${org.createdAt.month}/${org.createdAt.year}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Action buttons
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccessibleIconButton(
                      icon: Icons.visibility_outlined,
                      semanticLabel: 'View organization ${org.name}',
                      tooltip: 'View organization details',
                      onPressed: () => _viewOrganization(org),
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                    ),
                    const SizedBox(width: 4),
                    AccessibleIconButton(
                      icon: Icons.edit_outlined,
                      semanticLabel: 'Edit organization ${org.name}',
                      tooltip: 'Edit organization',
                      onPressed: () => _editOrganization(org),
                      color: colorScheme.tertiary,
                      backgroundColor: colorScheme.tertiary.withOpacity(0.1),
                    ),
                    const SizedBox(width: 4),
                    AccessibleIconButton(
                      icon: org.status == 'activated'
                          ? Icons.toggle_on_outlined
                          : Icons.toggle_off_outlined,
                      semanticLabel: org.status == 'activated'
                          ? 'Deactivate organization ${org.name}'
                          : 'Activate organization ${org.name}',
                      tooltip: org.status == 'activated' ? 'Deactivate' : 'Activate',
                      onPressed: () => _toggleOrganizationStatus(org),
                      color: org.status == 'activated' ? Colors.green : Colors.orange,
                      backgroundColor: (org.status == 'activated'
                              ? Colors.green
                              : Colors.orange)
                          .withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final orgService = context.watch<OrganizationsApiService>();
    final organizations = orgService.organizations;
    final filteredOrganizations = _filterOrganizations(organizations, _searchQuery);

    return Semantics(
      label: 'Organizations management page',
      explicitChildNodes: true,
      child: Scaffold(
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
                    color: colorScheme.outline.withOpacity(0.2),
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
                                color: colorScheme.onSurface.withOpacity(0.6),
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
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Focus(
                        focusNode: _skipNode,
                        onFocusChange: (hasFocus) {
                          setState(() => _isSkipLinkVisible = hasFocus);
                        },
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              (event.logicalKey == LogicalKeyboardKey.enter ||
                                  event.logicalKey == LogicalKeyboardKey.space)) {
                            _skipToMainContent();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: _isSkipLinkVisible ? 1 : 0,
                          child: Semantics(
                            button: true,
                            label: 'Skip to organizations table',
                            child: ElevatedButton(
                              onPressed: _skipToMainContent,
                              child: const Text('Skip to main content'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 300,
                        child: Semantics(
                          textField: true,
                          label: 'Search organizations by name, code, email or status',
                          child: Focus(
                            focusNode: _searchFocusNode,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                hintText: 'Search organizations',
                                labelText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline,
                                    width: 0.25,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                isDense: true,
                              ),
                              onChanged: _handleSearchChanged,
                              onSubmitted: _handleSearchChanged,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      key: _tableKey,
                      child: _buildContent(
                        context,
                        theme,
                        colorScheme,
                        organizations,
                        filteredOrganizations,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}