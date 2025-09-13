import 'package:flutter/material.dart';

class LeadNameEmails extends StatelessWidget {
  final Map<String, dynamic> lead;
  const LeadNameEmails({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          title: Text("Welcome Email"),
          subtitle: Text("Sent on 2025-09-01"),
        ),
        ListTile(
          title: Text("Follow-up Email"),
          subtitle: Text("Sent on 2025-09-02"),
        ),
      ],
    );
  }
}
