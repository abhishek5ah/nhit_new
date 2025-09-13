import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Reports Page",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

