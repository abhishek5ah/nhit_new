import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';
import 'contacts_table_view.dart';

class ContactsTable extends StatelessWidget {
  const ContactsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateColor.resolveWith(
              (states) => Colors.black26,
        ),
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Company")),
          DataColumn(label: Text("Email")),
          DataColumn(label: Text("Phone")),
          DataColumn(label: Text("Actions")),
        ],
        rows: leadsDummyData.map((contact) {
          return DataRow(
            cells: [
              DataCell(Text(contact["name"])),
              DataCell(Text(contact["company"])),
              DataCell(Text(contact["email"])),
              DataCell(Text(contact["phone"])),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContactsTableView(contact: contact),
                      ),
                    );
                  },
                  child: const Text("View"),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
