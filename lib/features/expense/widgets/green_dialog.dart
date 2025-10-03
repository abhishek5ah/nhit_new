import 'package:flutter/material.dart';

class GreenNoteDialog {
  /// 🔹 Common Dialog for Add/Edit/View
  static Future<bool?> show(
      BuildContext context, {
        required String title,
        Widget? formContent,
        List<Widget>? contentWidgets,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (formContent != null) formContent,        // Add/Edit
              if (contentWidgets != null) ...contentWidgets, // View
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          if (formContent != null)
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () => Navigator.pop(context, true),
            ),
        ],
      ),
    );
  }
}
