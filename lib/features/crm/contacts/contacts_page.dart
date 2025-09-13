import 'package:flutter/material.dart';
import 'contacts_table.dart';
import 'contacts_grid.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool isTableView = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => setState(() => isTableView = true),
              child: const Text("Table View"),
            ),
            TextButton(
              onPressed: () => setState(() => isTableView = false),
              child: const Text("Grid View"),
            ),
          ],
        ),
        Expanded(
          child: isTableView ? const ContactsTable() : const ContactsGrid(),
        ),
      ],
    );
  }
}
