import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/model/expense.dart';
import 'package:ppv_components/features/finance/screens/expenses/widgets/status_badge.dart';

class ExpenseInformationCard extends StatelessWidget {
  final Expense expense;
  const ExpenseInformationCard({super.key, required this.expense});

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
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 0.25,
          ),
        ),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expense Information', style: headingStyle),
            const SizedBox(height: 3),
            Text('Details and information', style: subtitleStyle),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue('Vendor', expense.vendor, labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      _labelValue('Date', '${expense.date.toLocal()}'.split(' ')[0], labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      Text('Status', style: labelStyle),
                      const SizedBox(height: 4),
                      StatusBadge(status: expense.status), // Custom badge widget
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _labelValue('Category', expense.category, labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      _labelValue('Amount', '\$${expense.amount.toStringAsFixed(2)}', labelStyle, valueStyle),
                      const SizedBox(height: 16),
                      _labelValue('Payment Method', expense.paymentMethod, labelStyle, valueStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Description', style: labelStyle),
            const SizedBox(height: 4),
            Text(expense.description, style: valueStyle),
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
