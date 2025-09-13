import 'package:flutter/material.dart';

class LeadsGridView extends StatelessWidget {
  final Map<String, dynamic> lead;
  const LeadsGridView({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lead["name"])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Company: ${lead["company"]}"),
            Text("Email: ${lead["email"]}"),
            Text("Phone: ${lead["phone"]}"),
            Text("Source: ${lead["source"]}"),
            Text("Status: ${lead["status"]}"),
          ],
        ),
      ),
    );
  }
}
