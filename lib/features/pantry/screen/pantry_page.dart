import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  const PantryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Pantry Page",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

