import 'package:flutter/material.dart';


class GstPage extends StatelessWidget {
  const GstPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Gst Page",
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

