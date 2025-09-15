import 'package:flutter/material.dart';

class ActivityWidget extends StatelessWidget {
  const ActivityWidget({super.key,  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha:0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activity Widget",
            style: text.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _ActivityItem(
            description: "Invoice created",
            timestamp: "2023-04-05 10:23",
            theme: theme,
          ),
          _ActivityItem(
            description: "Invoice sent to client",
            timestamp: "2023-04-05 12:00",
            theme: theme,
          ),
          _ActivityItem(
            description: "Payment received",
            timestamp: "2023-04-15 09:45",
            theme: theme,
          ),
        ],
      ),
    );
  }
}
class _ActivityItem extends StatelessWidget {
  final String description;
  final String timestamp;
  final ThemeData theme;

  const _ActivityItem({
    required this.description,
    required this.timestamp,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final text = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: cs.onSurface), // now uses onSurface
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: text.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
          ),
          Text(
            timestamp,
            style: text.bodySmall?.copyWith(
              color: cs.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
