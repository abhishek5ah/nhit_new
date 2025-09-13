import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/secondary_button.dart';
import 'package:ppv_components/features/finance/model/expense.dart';

class AttachmentsCard extends StatelessWidget {
  final List<Attachment> attachments;
  const AttachmentsCard({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );
    final filenameStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    final addedOnStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
    );

    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attachments', style: headingStyle),
            const SizedBox(height: 4),
            Text('Receipts and supporting documents', style: subtitleStyle),
            const SizedBox(height: 16),
            Column(
              children: attachments
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            size: 28,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.filename, style: filenameStyle),
                                Text(
                                  "Added on ${a.addedOn.toLocal().toIso8601String().split('T')}",
                                  style: addedOnStyle,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.download,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tooltip: 'Download',
                            onPressed: () {},
                          ),
                          Text(
                            'Download',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              onPressed: () {},
              icon: Icons.attach_file,
              label: 'Add Attachment',
            ),
          ],
        ),
      ),
    );
  }
}
