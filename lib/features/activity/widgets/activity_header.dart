import 'package:flutter/material.dart';

class ActivityHeader extends StatelessWidget {
  final IconData? actionButtonIcon;

  const ActivityHeader({
    super.key,
    this.actionButtonIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
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
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Logs Management',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and monitor system activities and user actions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
