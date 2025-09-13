import 'package:flutter/material.dart';
import 'companies_table.dart';
import 'companies_grid.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
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
          child: isTableView ? const CompaniesTable() : const CompaniesGrid(),
        ),
      ],
    );
  }
}
