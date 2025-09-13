import 'package:flutter/material.dart';

class LeadNameTasks extends StatelessWidget {
  final Map<String, dynamic> lead;
  const LeadNameTasks({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text("Follow up with client")),
        ListTile(title: Text("Prepare proposal")),
      ],
    );
  }
}
