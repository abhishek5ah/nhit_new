import 'package:flutter/material.dart';

class DealsTable extends StatelessWidget {
  const DealsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text("Deal 1"), subtitle: Text("Status: Open")),
        ListTile(title: Text("Deal 2"), subtitle: Text("Status: Closed")),
      ],
    );
  }
}
