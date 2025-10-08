import 'package:flutter/material.dart';

class RoleHeader extends StatelessWidget {
  final int tabIndex;

  const RoleHeader({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<_HeaderData> headerData = [
      _HeaderData(
        title: 'Roles',
        subtitle: 'Manage the roles and permissions here',
      ),
      _HeaderData(
        title: 'Add Role',
        subtitle: 'Add a new role',
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
              color: colorScheme.onSurface.withAlpha(204),
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
