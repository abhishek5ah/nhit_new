import 'package:flutter/material.dart';


class InvoiceFooter extends StatelessWidget {
  const InvoiceFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        const Text(
          "Thank you for your business. Payment is due within 30 days.",
          style: TextStyle(fontSize: 15),
        ),
        const SizedBox(height: 12),
        const Text(
          "Terms & Conditions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height:4),
        const Text(
          "1. Payment should be made within the due date.\n"
              "2. All disputes are subject to local jurisdiction.\n"
              "3. This is a computer-generated invoice and does not require a signature.",
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}