import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/model/accounting_detail.dart';

class AccountingCard extends StatelessWidget {
  final AccountingDetail detail;
  const AccountingCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
      fontWeight: FontWeight.w500,
    );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.normal,
    );
    final headingStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
    );

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.25,
          ),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accounting Details', style: headingStyle),
            const SizedBox(height: 3),
            Text('Financial categorization', style: subtitleStyle),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue('Account', detail.account, labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      _labelValue('Tax Amount', '\$${detail.taxAmount.toStringAsFixed(2)}', labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      _labelValue('Cost Center', detail.costCenter, labelStyle, valueStyle),
                    ],
                  ),
                ),
                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue('Tax Code', detail.taxCode, labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      _labelValue('Net Amount', '\$${detail.netAmount.toStringAsFixed(2)}', labelStyle, valueStyle),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value, TextStyle? labelStyle, TextStyle? valueStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Text(value, style: valueStyle),
      ],
    );
  }
}
