import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';
import 'contacts_grid_add_contact.dart';

class ContactsGrid extends StatelessWidget {
  const ContactsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: leadsDummyData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final contact = leadsDummyData[index];
        return Card(
          child: ListTile(
            title: Text(contact["name"]),
            subtitle: Text(contact["company"]),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContactsGridAddContact(contact: contact),
                  ),
                );
              },
              child: const Text("View"),
            ),
          ),
        );
      },
    );
  }
}
