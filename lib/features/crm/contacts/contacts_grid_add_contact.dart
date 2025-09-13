import 'package:flutter/material.dart';

class ContactsGridAddContact extends StatelessWidget {
  final Map<String, dynamic> contact;
  const ContactsGridAddContact({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Contact")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(initialValue: contact["name"], decoration: const InputDecoration(labelText: "Name")),
            TextFormField(initialValue: contact["company"], decoration: const InputDecoration(labelText: "Company")),
            TextFormField(initialValue: contact["email"], decoration: const InputDecoration(labelText: "Email")),
            TextFormField(initialValue: contact["phone"], decoration: const InputDecoration(labelText: "Phone")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}
