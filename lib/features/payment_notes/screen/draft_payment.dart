import 'package:flutter/material.dart';
import 'package:ppv_components/features/payment_notes/screen/create_payment.dart';

class DraftPaymentScreen extends StatelessWidget {
  const DraftPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Themed Header Container with icon, heading, subheading
            Container(
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Draft Payment Notes',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and convert draft payment notes to active status.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Bar / Quick Actions Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  _buildAction(
                    context: context,
                    label: 'Convert All to Active',
                    color: colorScheme.primary,
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(width: 16),
                  _buildAction(
                    context: context,
                    label: 'Filter Auto-Created',
                    color: colorScheme.secondary,
                    icon: Icons.filter_alt,
                  ),
                  const SizedBox(width: 16),
                  _buildAction(
                    context: context,
                    label: 'Filter Manual',
                    color: colorScheme.tertiary,
                    icon: Icons.filter_list,
                  ),
                  const SizedBox(width: 16),
                  _buildAction(
                    context: context,
                    label: 'Clear Filters',
                    color: colorScheme.outline,
                    icon: Icons.clear,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Draft Payment Notes List Section (empty state example)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 56,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Draft Payment Notes Found',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Draft payment notes will appear here when green notes are approved or when manually created.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Payment Note'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreatePaymentScreen(),
                            ),
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          minimumSize: const Size(0, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('View Green Notes'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Draft Statistics Section inside a bordered "box" container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Draft Statistics',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBox(
                        context: context,
                        color: colorScheme.primary,
                        label: 'Total Drafts',
                        value: '0',
                        textColor: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 16),
                      _buildStatBox(
                        context: context,
                        color: colorScheme.secondary,
                        label: 'Auto Created',
                        value: '0',
                        textColor: colorScheme.onSecondary,
                      ),
                      const SizedBox(width: 16),
                      _buildStatBox(
                        context: context,
                        color: colorScheme.tertiary,
                        label: 'Manual Created',
                        value: '0',
                        textColor: colorScheme.onTertiary,
                      ),
                      const SizedBox(width: 16),
                      _buildStatBox(
                        context: context,
                        color: colorScheme.primaryContainer,
                        label: 'Today\'s Drafts',
                        value: '0',
                        textColor: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({
    required BuildContext context,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          textStyle: textTheme.bodyMedium,
          padding: const EdgeInsets.symmetric(vertical: 18),
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }

  Widget _buildStatBox({
    required BuildContext context,
    required Color color,
    required String label,
    required String value,
    required Color textColor,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: textColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
