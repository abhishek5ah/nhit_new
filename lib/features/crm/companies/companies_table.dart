import 'package:flutter/material.dart';
import 'package:ppv_components/features/crm/data/dummy_data.dart';

class CompaniesTable extends StatelessWidget {
  const CompaniesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: leadsDummyData.length,
      itemBuilder: (context, index) {
        final company = leadsDummyData[index];
        return ListTile(
          title: Text(company["company"]),
          subtitle: Text(company["name"]),
        );
      },
    );
  }
}
