import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';

class CompaniesGrid extends StatelessWidget {
  const CompaniesGrid({super.key});

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
        final company = leadsDummyData[index];
        return Card(
          child: Center(child: Text(company["company"])),
        );
      },
    );
  }
}
