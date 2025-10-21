import 'package:flutter/material.dart';

class PaymentDetailPageHeader extends StatelessWidget {
  final int tabIndex;

  const PaymentDetailPageHeader({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<_HeaderData> headerData = [
      _HeaderData(
        title: 'View Payment Note',
      ),
    ];

    final header = headerData[tabIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  header.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderData {
  final String title;

  _HeaderData({required this.title});
}
