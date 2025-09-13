import 'package:flutter/material.dart';
import 'package:ppv_components/features/finance/model/expense.dart';

class AttachmentsSection extends StatelessWidget {
  final List<Attachment> attachments;

  const AttachmentsSection({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.error; // Theme border color

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 40),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attachments', style: theme.textTheme.titleMedium),
              ...attachments.map(
                (a) => ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(a.filename),
                  subtitle: Text(
                    'Added on ${a.addedOn.toLocal().toString().split(' ')[0]}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {}, // mock download
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.attach_file),
                label: const Text('Add Attachment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
