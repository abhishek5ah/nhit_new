import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final VoidCallback onView;
  final ColorScheme colorScheme;
  final Color background;
  final Color outline;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtext,
    required this.onView,
    required this.colorScheme,
    required this.background,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outline),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.onSurface, // Use primary or onPrimary text color
                fontWeight: FontWeight.bold,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: onView,
              child: const Text("View Reports"),
            ),
          ],
        ),
      ),
    );
  }
}
