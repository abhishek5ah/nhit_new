import 'package:flutter/material.dart';

class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Vendors Page",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

