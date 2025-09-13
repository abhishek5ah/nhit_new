import 'package:flutter/material.dart';

class LeadName extends StatelessWidget {
  final Map<String, dynamic> lead;
  const LeadName({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Lead Summary: ${lead["name"]} from ${lead["company"]}",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
