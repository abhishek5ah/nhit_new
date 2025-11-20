import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/core/theme/theme_notifier.dart';
import 'package:ppv_components/common_widgets/breadcrumb_item.dart';
import 'package:ppv_components/core/services/auth_service.dart';

class Navbar extends StatelessWidget {
  final String? currentLocation;
  final String userName;
  final String? avatarUrl;

  const Navbar({
    super.key,
    this.currentLocation,
    required this.userName,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline,
            width: .5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: breadcrumbs
          Expanded(
            child: Row(
              children: [
                const SizedBox(width: 14),
                Breadcrumbs(
                  currentLocation: currentLocation,
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // Right Side Button - Theme Toggle, Help, Notification, User
          Row(
            children: [
              // Theme toggle button
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
                onPressed: () {
                  themeNotifier.toggleTheme();
                },
              ),
              // IconButton(
              //   icon: Icon(Icons.help_outline, color: colorScheme.onSurfaceVariant),
              //   onPressed: () {}, // Help action
              //   tooltip: "Help",
              // ),
              // IconButton(
              //   icon: Icon(Icons.notifications_none, color: colorScheme.onSurfaceVariant),
              //   onPressed: () {}, // Notification action
              //   tooltip: "Notifications",
              // ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primary,
                backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                  userName
                      .split(" ")
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .join()
                      .toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                userName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              // Logout button
              IconButton(
                icon: Icon(Icons.logout_outlined, color: colorScheme.onSurfaceVariant),
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldLogout == true) {
                    // Call logout and navigate to login
                    await authService.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                tooltip: "Logout",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
