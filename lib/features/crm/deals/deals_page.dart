import 'package:flutter/material.dart';
import 'deals_table.dart';
import 'deals_grid.dart';

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
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
          child: isTableView ? const DealsTable() : const DealsGrid(),
        ),
      ],
    );
  }
}
