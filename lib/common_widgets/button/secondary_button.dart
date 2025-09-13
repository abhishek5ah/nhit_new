import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
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
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          minimumSize: const Size(0, 54),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha:0.5),
            width: 1.2,
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            final baseColor =
                backgroundColor ??
                Theme.of(context).colorScheme.secondaryContainer;
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
            Theme.of(context).colorScheme.onSecondaryContainer,
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
            Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      );
    } else {
      childContent = Text(label);
    }

    return FilledButton.tonal(
      onPressed: effectiveOnPressed,
      style: style,
      child: childContent,
    );
  }
}
