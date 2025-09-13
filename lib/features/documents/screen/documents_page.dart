import 'package:flutter/material.dart';


class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Documents Page",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

