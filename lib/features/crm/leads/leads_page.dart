import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';
import 'leads_table.dart';
import 'leads_grid.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  bool isTableView = true;

  /// ✅ Add Lead Dialog
  void _addLeadDialog() {
    final nameController = TextEditingController();
    final companyController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Lead"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name")),
                TextField(
                    controller: companyController,
                    decoration: const InputDecoration(labelText: "Company")),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email")),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: "Phone")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  leadsDummyData.add({
                    "name": nameController.text,
                    "company": companyController.text,
                    "email": emailController.text,
                    "phone": phoneController.text,
                    "source": "Manual Entry",
                    "status": "New"
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ✅ Top Controls (Responsive)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            spacing: 10,
            children: [
              // ✅ Toggle Buttons
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                      isTableView ? Colors.white : Colors.transparent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => setState(() => isTableView = true),
                    child: const Text("Table View"),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                      !isTableView ? Colors.white : Colors.transparent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => setState(() => isTableView = false),
                    child: const Text("Grid View"),
                  ),
                ],
              ),

              // ✅ Right side buttons
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Exported successfully!"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Export"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _addLeadDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("New Lead"),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// ✅ Body (Table / Grid View)
        Expanded(
          child: isTableView ? const LeadsTable() : const LeadsGrid(),
        ),
      ],
    );
  }
}
