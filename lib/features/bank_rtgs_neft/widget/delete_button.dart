import 'package:flutter/material.dart';
import 'package:ppv_components/features/bank_rtgs_neft/models/bank_models/bank_rtgs_neft_model.dart';

class DeleteRtgsFormPage extends StatelessWidget {
  final BankRtgsNeft record;
  final VoidCallback onDelete;

  const DeleteRtgsFormPage({
    super.key,
    required this.record,
    required this.onDelete,
  });

  static Future<void> show(
      BuildContext context, BankRtgsNeft record, VoidCallback onDelete) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DeleteRtgsFormPage(record: record, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text("Delete Record"),
      content: Row(
        children: [
          const Text("ID: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(record.id),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            onDelete(); // Call the delete callback
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}
