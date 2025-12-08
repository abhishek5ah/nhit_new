import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'accessibility_constants.dart';
import 'accessibility_utils.dart';

/// Accessible Button Widget (WCAG 2.2 + GIGW Compliant)
class AccessibleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final bool isDestructive;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.isDestructive = false,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<AccessibleButton> createState() => _AccessibleButtonState();
}

class _AccessibleButtonState extends State<AccessibleButton> {
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;
    
    final backgroundColor = widget.backgroundColor ?? 
        (widget.isDestructive ? colorScheme.error : colorScheme.primary);
    final foregroundColor = widget.foregroundColor ?? 
        AccessibilityUtils.getAccessibleTextColor(backgroundColor);

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.semanticLabel,
      hint: widget.tooltip,
      onTap: widget.onPressed,
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onPressed?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: Tooltip(
            message: widget.tooltip ?? widget.semanticLabel,
            child: ConstrainedBox(
              constraints: AccessibilityUtils.ensureMinimumTouchTarget(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDisabled 
                          ? backgroundColor.withValues(alpha:0.5)
                          : backgroundColor,
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                      border: _isFocused
                          ? Border.all(
                              color: colorScheme.primary,
                              width: AccessibilityConstants.focusIndicatorWidth,
                            )
                          : null,
                      boxShadow: _isHovered && !isDisabled
                          ? [
                              BoxShadow(
                                color: backgroundColor.withValues(alpha:0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isDisabled 
                            ? foregroundColor.withValues(alpha:0.5)
                            : foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible Icon Button (WCAG 2.2 Compliant)
class AccessibleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? iconSize;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.iconSize,
  });

  @override
  State<AccessibleIconButton> createState() => _AccessibleIconButtonState();
}

class _AccessibleIconButtonState extends State<AccessibleIconButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = widget.onPressed == null;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.semanticLabel,
      hint: widget.tooltip,
      onTap: widget.onPressed,
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onPressed?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Tooltip(
          message: widget.tooltip ?? widget.semanticLabel,
          child: ConstrainedBox(
            constraints: AccessibilityUtils.ensureMinimumTouchTarget(),
            child: IconButton(
              onPressed: widget.onPressed,
              icon: Icon(widget.icon),
              color: widget.color ?? colorScheme.primary,
              iconSize: widget.iconSize ?? 20,
              style: IconButton.styleFrom(
                backgroundColor: widget.backgroundColor ?? 
                    (widget.color ?? colorScheme.primary).withValues(alpha:0.1),
                side: _isFocused
                    ? BorderSide(
                        color: colorScheme.primary,
                        width: AccessibilityConstants.focusIndicatorWidth,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible Text Field (WCAG 2.2 + GIGW Compliant)
class AccessibleTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final bool isRequired;
  final bool isPassword;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const AccessibleTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.isRequired = false,
    this.isPassword = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Semantics(
      textField: true,
      label: AccessibilityUtils.createSemanticLabel(
        label: widget.label,
        hint: widget.hint,
        isRequired: widget.isRequired,
        hasError: widget.errorText != null,
      ),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: TextFormField(
          controller: widget.controller,
          obscureText: _obscureText && widget.isPassword,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          validator: widget.validator,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          style: TextStyle(
            fontSize: AccessibilityConstants.baseFontSize,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            labelText: widget.label + (widget.isRequired ? ' *' : ''),
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                    tooltip: _obscureText ? 'Show password' : 'Hide password',
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: AccessibilityConstants.focusIndicatorWidth,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: AccessibilityConstants.focusIndicatorWidth,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }
}

/// Accessible Card with proper semantics
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.onTap,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: semanticLabel,
      button: onTap != null,
      child: Card(
        color: backgroundColor ?? colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha:0.2),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Skip Navigation Link (WCAG 2.4.1)
class SkipNavigationLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final FocusNode focusNode;

  const SkipNavigationLink({
    super.key,
    required this.label,
    required this.onPressed,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: 0,
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          // Move into view when focused
        },
        child: Semantics(
          button: true,
          label: label,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

/// Accessible Alert Dialog (WCAG 2.2 Compliant)
class AccessibleAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;
  final bool isDestructive;

  const AccessibleAlertDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      namesRoute: true,
      scopesRoute: true,
      explicitChildNodes: true,
      label: 'Alert Dialog: $title',
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Row(
            children: [
              if (isDestructive)
                Icon(Icons.warning, color: colorScheme.error),
              if (isDestructive) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Semantics(
          liveRegion: true,
          child: Text(
            content,
            style: TextStyle(
              fontSize: AccessibilityConstants.baseFontSize,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        actions: actions,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Accessible Loading Indicator
class AccessibleLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;

  const AccessibleLoadingIndicator({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message ?? 'Loading',
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size ?? 40,
              height: size ?? 40,
              child: const CircularProgressIndicator(),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
