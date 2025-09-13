import 'package:flutter/material.dart';

class OutlineButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  const OutlineButton({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline,
        width: 1.2,
      ),
      foregroundColor: Theme.of(context).colorScheme.outline,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      minimumSize: const Size(0, 48),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
        style: style,
      );
    } else {
      return OutlinedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label),
      );
    }
  }
}
