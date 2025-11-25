import 'package:flutter/material.dart';

class PaymentHeader extends StatelessWidget {
  const PaymentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    const _HeaderData header = _HeaderData(
      title: 'Payments',
      subtitle: 'Manage your payment notes here',
      icon: Icons.payment,
    );

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
        children: [
          // Icon Container - matching the organizations page style
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              header.icon,
              color: colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Text Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                header.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
