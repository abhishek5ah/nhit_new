import 'package:flutter/material.dart';

class ContactsTableView extends StatelessWidget {
  final Map<String, dynamic> contact;
  const ContactsTableView({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact["name"])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Company: ${contact["company"]}"),
            Text("Email: ${contact["email"]}"),
            Text("Phone: ${contact["phone"]}"),
          ],
        ),
      ),
    );
  }
}
