import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ppv_components/common_widgets/button/outlined_button.dart';
import 'package:ppv_components/common_widgets/button/primary_button.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart'
    as api;
import 'package:ppv_components/features/organization/model/organization_model.dart'
    as legacy_org;
import 'package:ppv_components/features/organization/screens/edit_organization.dart';
import 'package:ppv_components/features/organization/services/organizations_api_service.dart';

class ViewOrganizationScreen extends StatefulWidget {
  final String orgId;
  final api.OrganizationModel? initialOrganization;

  const ViewOrganizationScreen({
    super.key,
    required this.orgId,
    this.initialOrganization,
  });

  @override
  State<ViewOrganizationScreen> createState() => _ViewOrganizationScreenState();
}

class _ViewOrganizationScreenState extends State<ViewOrganizationScreen> {
  api.OrganizationModel? _organization;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _organization = widget.initialOrganization;
    _isLoading = _organization == null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOrganization());
  }

  Future<void> _fetchOrganization() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final orgService = context.read<OrganizationsApiService>();
    final result = await orgService.getOrganizationById(widget.orgId);

    if (!mounted) return;

    if (result.success && result.organization != null) {
      setState(() {
        _organization = result.organization;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.message ?? 'Unable to load organization details.';
        _isLoading = false;
      });
    }
  }

  legacy_org.Organization? _convertToLegacyOrganization(api.OrganizationModel org) {
    return legacy_org.Organization(
      id: org.orgId.hashCode,
      name: org.name,
      code: org.code,
      status: org.status == 'activated' ? 'Active' : 'Inactive',
      createdBy: org.createdByDisplay,
      createdDate:
          '${org.createdAt.day}/${org.createdAt.month}/${org.createdAt.year}',
      description: org.description,
      logoPath: org.logo,
      projects: org.initialProjects,
    );
  }

  Widget _buildOrganizationLogo(BuildContext context, api.OrganizationModel org) {
    final colorScheme = Theme.of(context).colorScheme;
    final nameParts = org.name.split(' ');
    final badgeText = nameParts.length >= 2
        ? nameParts[0][0] + nameParts[1][0]
        : org.name.substring(0, 2.clamp(0, org.name.length));

    if (org.logo.isNotEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            org.logo,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialsBadge(badgeText, colorScheme),
          ),
        ),
      );
    }

    return _buildInitialsBadge(badgeText, colorScheme);
  }

  Widget _buildInitialsBadge(String text, ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }

  String _formatStatus(api.OrganizationModel org) {
    return org.status == 'activated' ? 'Active' : 'Inactive';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildBody() {
      if (_isLoading && _organization == null) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_error != null && _organization == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                onPressed: _fetchOrganization,
                label: 'Retry',
                icon: Icons.refresh,
              ),
            ],
          ),
        );
      }

      final org = _organization!;
      final statusText = _formatStatus(org);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                children: [
                  _buildOrganizationLogo(context, org),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          org.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                org.code.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    statusText == 'Active' ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      PrimaryButton(
                        onPressed: () {
                          final legacy = _convertToLegacyOrganization(org);
                          if (legacy == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOrganizationScreen(
                                organization: legacy,
                              ),
                            ),
                          );
                        },
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                      ),
                      const SizedBox(width: 8),
                      SecondaryButton(
                        label: 'Back',
                        onPressed: () => Navigator.pop(context),
                        icon: Icons.arrow_back,
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildInfoCard(context, org, statusText),
                      const SizedBox(height: 24),
                      _buildStatisticsCard(context, org, statusText),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildProjectsCard(context, org),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: buildBody(),
    );
  }

  Widget _buildInfoCard(BuildContext context, api.OrganizationModel organization, String statusText) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Basic Information',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(context, 'Organization Name:', organization.name),
          _buildInfoRow(context, 'Code:', organization.code.toUpperCase()),
          _buildInfoRow(context, 'Status:', statusText),
          _buildInfoRow(context, 'Created By:', organization.createdByDisplay),
          _buildInfoRow(context, 'Created At:', _formatDate(organization.createdAt)),
          _buildInfoRow(context, 'Last Updated:', _formatDate(organization.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsCard(BuildContext context, api.OrganizationModel organization) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final List<String> projects = organization.initialProjects;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.folder_outlined,
                      size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Projects',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            
            ],
          ),
          const SizedBox(height: 24),

      
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: projects.map((project) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          24 /*page padding left*/ -
                          24 /*page padding right*/ -
                          24 /*gap between columns*/ -
                          24 /*card padding left+right*/) /
                      2,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            project,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, api.OrganizationModel organization, String statusText) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_outlined,
                  size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Statistics',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.people_outline,
                  label: 'Users',
                  value: '0',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.folder_outlined,
                  label: 'Projects',
                  value: organization.initialProjects.length.toString(),
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Days Active',
                  value: DateTime.now().difference(organization.createdAt).inDays.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  context: context,
                  icon: Icons.check_circle_outline,
                  label: 'Status',
                  value: statusText,
                  color: statusText == 'Active' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
