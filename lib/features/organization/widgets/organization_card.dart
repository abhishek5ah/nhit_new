import 'package:flutter/material.dart';
import 'package:ppv_components/features/organization/data/models/organization_model.dart';

class OrganizationCard extends StatelessWidget {
  final OrganizationModel organization;
  final bool isCurrentOrganization;
  final VoidCallback onSwitch;
  final VoidCallback onEdit;

  const OrganizationCard({
    super.key,
    required this.organization,
    required this.isCurrentOrganization,
    required this.onSwitch,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isCurrentOrganization ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrentOrganization 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isCurrentOrganization ? 2 : 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isCurrentOrganization
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.surface,
                  ],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status badge
            Row(
              children: [
                // Organization Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isCurrentOrganization 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.business,
                    color: isCurrentOrganization 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Current organization badge
                if (isCurrentOrganization)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'CURRENT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Status indicator
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: organization.isActive 
                        ? Colors.green 
                        : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Organization Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Organization Name
                  Text(
                    organization.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Organization Code
                  Text(
                    'Code: ${organization.code}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  Expanded(
                    child: Text(
                      organization.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Status and Database Info
                  Row(
                    children: [
                      Icon(
                        organization.isActive ? Icons.check_circle : Icons.pause_circle,
                        size: 16,
                        color: organization.isActive ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        organization.isActive ? 'Active' : 'Inactive',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: organization.isActive ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'DB: ${organization.databaseName}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Switch Button (only show if not current)
                if (!isCurrentOrganization)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSwitch,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Switch'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                
                // Current organization indicator
                if (isCurrentOrganization)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Current',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(width: 8),
                
                // Edit Button
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Edit Organization',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
