import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';
import 'leads_grid_view.dart';

class LeadsGrid extends StatelessWidget {
  const LeadsGrid({super.key});

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
        final lead = leadsDummyData[index];
        return Card(
          child: ListTile(
            title: Text(lead["name"]),
            subtitle: Text(lead["company"]),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LeadsGridView(lead: lead),
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
