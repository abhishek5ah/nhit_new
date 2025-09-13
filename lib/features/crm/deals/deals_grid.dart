import 'package:flutter/material.dart';

class DealsGrid extends StatelessWidget {
  const DealsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: const [
        Card(child: Center(child: Text("Deal 1 - Open"))),
        Card(child: Center(child: Text("Deal 2 - Closed"))),
      ],
    );
  }
}
