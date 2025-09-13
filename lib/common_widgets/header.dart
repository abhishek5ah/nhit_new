import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const Header({
    super.key,
    this.backgroundColor,
    this.textColor,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight + 18);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colors.surfaceContainer;
    final txtColor = textColor ?? colors.onSurface;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight + 18,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Finance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.2,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage your financial transactions and reports',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: txtColor.withValues(alpha:0.73),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
