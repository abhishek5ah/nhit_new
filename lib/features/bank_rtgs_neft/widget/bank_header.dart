
import 'package:flutter/material.dart';

class BankHeader extends StatelessWidget {
  final int tabIndex;

  const BankHeader({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<_HeaderData> headerData = [
      _HeaderData(
        title: 'Bank Details',
        subtitle: 'View and manage saved bank accounts',
      ),
      _HeaderData(
        title: 'Add Bank',
        subtitle: 'Add a new bank account',
      ),
      _HeaderData(
        title: 'Bank Rules',
        subtitle: 'Set rules and policies for bank accounts',
      ),
      _HeaderData(
        title: 'Bank Rules',
        subtitle: 'Set rules and policies for bank accounts',
      ),
      _HeaderData(
        title: 'Bank Rules',
        subtitle: 'Set rules and policies for bank accounts',
      ),
    ];

    final header = headerData[tabIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 16, 0, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            header.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderData {
  final String title;
  final String subtitle;

  _HeaderData({required this.title, required this.subtitle});
}
