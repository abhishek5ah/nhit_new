import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/sidebar.dart';

class LayoutPage extends StatefulWidget {
  final Widget child;

  const LayoutPage({super.key, required this.child});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  String currentRoute = "/dashboard";

  void _onItemSelected(String route) {
    setState(() {
      currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            onItemSelected: (route) {
              _onItemSelected(route as String);
            },
          ),

          // Main content takes remaining space
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
