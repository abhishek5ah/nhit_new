import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double spacing;
  final TextStyle? textStyle;
  final Color? dividerColor;

  const DividerWithText({
    super.key,
    required this.text,
    this.spacing = 16,
    this.textStyle,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: dividerColor ?? theme.colorScheme.outline,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Text(
            text,
            style: textStyle ?? 
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: dividerColor ?? theme.colorScheme.outline,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
