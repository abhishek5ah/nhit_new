import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/common_widgets/sidebar.dart';
import 'package:ppv_components/common_widgets/navbar.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class LayoutPage extends StatefulWidget {
  final Widget child;

  const LayoutPage({super.key, required this.child});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser;
        
        return Scaffold(
          body: Row(
            children: [
              Sidebar(
                onItemSelected: (route) {
                  print('📍 [Layout] Received navigation request to: $route');
                  try {
                    context.go(route);
                    print('✅ [Layout] Successfully navigated to: $route');
                  } catch (e) {
                    print('❌ [Layout] Navigation failed: $e');
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Navbar(userName: user?.name ?? 'User'),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
