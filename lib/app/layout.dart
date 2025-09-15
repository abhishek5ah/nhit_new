import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/breadcrumb_item.dart';
import 'package:ppv_components/common_widgets/sidebar.dart';
import 'package:ppv_components/features/components/navbar.dart';

class LayoutPage extends StatefulWidget {
  final Widget child;

  const LayoutPage({super.key, required this.child});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            onItemSelected: (route) {
              context.go(route);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Navbar(userName: 'Abhishek'),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
