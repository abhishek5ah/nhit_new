import 'package:flutter/material.dart';
import 'package:ppv_components/core/accessibility/accessibility_constants.dart';
import 'package:ppv_components/core/accessibility/accessibility_utils.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Ensure WCAG AAA contrast compliance
    final backgroundColor = colorScheme.surface;
    final primaryColor = colorScheme.primary;
    final textColor = colorScheme.onSurface;
    final subtitleColor = colorScheme.onSurface.withValues(alpha:0.7);

    // Verify contrast ratios
    final contrastRatio = AccessibilityUtils.calculateContrastRatio(textColor, backgroundColor);
    final meetsWCAG = AccessibilityUtils.meetsWCAGAAA(textColor, backgroundColor);

    return Semantics(
      container: true,
      label: 'User Management Section Header',
      header: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha:0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon Container with Semantic Label
            Semantics(
              label: 'Users icon',
              image: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: AccessibilityUtils.getAccessibleTextColor(primaryColor),
                  size: 24,
                  semanticLabel: 'Users',
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Text Content with Proper Semantics
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    label: 'Page title: User',
                    child: Text(
                      'User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: AccessibilityUtils.getScaledFontSize(
                          context,
                          24.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    label: 'Page description: Manage your user list here',
                    child: Text(
                      'Manage your user list here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: subtitleColor,
                        fontSize: AccessibilityUtils.getScaledFontSize(
                          context,
                          AccessibilityConstants.baseFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
