import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final ButtonStyle? style;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.style,
    this.backgroundColor,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,

  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    final ButtonStyle style =
    FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      minimumSize: const Size(0, 54),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        final baseColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
        if (states.contains(WidgetState.disabled)) {
          return baseColor.withValues(alpha:0.4);
        } else if (states.contains(WidgetState.pressed)) {
          return baseColor.withValues(alpha:0.7);
        } else if (states.contains(WidgetState.hovered)) {
          return baseColor.withValues(alpha:0.9);
        }
        return baseColor;
      }),
      foregroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.onPrimary,
      ),
    );


    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );
    } else {
      childContent = Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      );
    }

    return FilledButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: childContent,
    );
  }
}
