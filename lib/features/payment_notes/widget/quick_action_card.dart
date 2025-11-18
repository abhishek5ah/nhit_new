import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(left: 8, right: 8, top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Edit Payment Note button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Edit Payment Note',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
