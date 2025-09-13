import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';
import 'leads_view.dart';

class LeadsTable extends StatelessWidget {
  const LeadsTable({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case "New":
        return Colors.orange;
      case "Completed":
        return Colors.blue;
      case "Qualified":
        return Colors.teal;
      case "Negotiation":
        return Colors.purple;
      case "Lost":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, width: 1), // ✅ outer border
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: screenHeight * 0.6, //
          width: screenWidth,         //
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // horizontal scroll agar zarurat ho
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: screenWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.black26,
                  ),
                  border: TableBorder.symmetric(
                    inside: const BorderSide(color: Colors.black26, width: 1),
                  ),
                  columnSpacing: screenWidth < 600 ? 12 : 24, // responsive spacing
                  columns: const [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Company")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Phone")),
                    DataColumn(label: Text("Source")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Actions")),
                  ],
                  rows: leadsDummyData.map((lead) {
                    return DataRow(
                      cells: [
                        DataCell(Text(lead["name"])),
                        DataCell(Text(lead["company"])),
                        DataCell(Text(lead["email"])),
                        DataCell(Text(lead["phone"])),
                        DataCell(Text(lead["source"])),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(lead["status"]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              lead["status"],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LeadsView(lead: lead),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
