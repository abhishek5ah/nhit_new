import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'dart:math' as math;
import 'accessibility_constants.dart';

/// Utility class for accessibility-related functions
/// Implements WCAG 2.2 and GIGW guidelines
class AccessibilityUtils {
  /// Calculate relative luminance of a color (WCAG formula)
  static double _calculateLuminance(Color color) {
    final r = _adjustColorComponent(color.red / 255.0);
    final g = _adjustColorComponent(color.green / 255.0);
    final b = _adjustColorComponent(color.blue / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Adjust color component for luminance calculation
  static double _adjustColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    }
    return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Calculate contrast ratio between two colors (WCAG 2.2)
  /// Returns a value between 1 and 21
  static double calculateContrastRatio(Color foreground, Color background) {
    final luminance1 = _calculateLuminance(foreground);
    final luminance2 = _calculateLuminance(background);
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if color combination meets WCAG AAA standards (7:1)
  static bool meetsWCAGAAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    final requiredRatio = isLargeText 
        ? AccessibilityConstants.contrastRatioAAALarge 
        : AccessibilityConstants.contrastRatioAAA;
    return ratio >= requiredRatio;
  }

  /// Check if color combination meets WCAG AA standards (4.5:1)
  static bool meetsWCAGAA(Color foreground, Color background, {bool isLargeText = false}) {
    final ratio = calculateContrastRatio(foreground, background);
    final requiredRatio = isLargeText 
        ? AccessibilityConstants.contrastRatioAALarge 
        : AccessibilityConstants.contrastRatioAA;
    return ratio >= requiredRatio;
  }

  /// Get accessible text color for a given background
  /// Returns either white or black based on contrast
  static Color getAccessibleTextColor(Color background) {
    final whiteContrast = calculateContrastRatio(Colors.white, background);
    final blackContrast = calculateContrastRatio(Colors.black, background);
    return whiteContrast > blackContrast ? Colors.white : Colors.black;
  }

  /// Ensure minimum touch target size (WCAG 2.5.8)
  static BoxConstraints ensureMinimumTouchTarget({
    double minWidth = AccessibilityConstants.minTouchTargetSize,
    double minHeight = AccessibilityConstants.minTouchTargetSize,
  }) {
    return BoxConstraints(
      minWidth: minWidth,
      minHeight: minHeight,
    );
  }

  /// Create focus border for keyboard navigation (WCAG 2.4.7)
  static BoxDecoration createFocusBorder(Color focusColor, {bool hasFocus = false}) {
    if (!hasFocus) return const BoxDecoration();
    
    return BoxDecoration(
      border: Border.all(
        color: focusColor,
        width: AccessibilityConstants.focusIndicatorWidth,
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }

  /// Create semantic label for screen readers
  static String createSemanticLabel({
    required String label,
    String? hint,
    String? value,
    bool isRequired = false,
    bool isDisabled = false,
    bool hasError = false,
  }) {
    final parts = <String>[label];
    
    if (value != null && value.isNotEmpty) {
      parts.add(value);
    }
    
    if (isRequired) {
      parts.add(AccessibilityConstants.requiredFieldLabel);
    }
    
    if (isDisabled) {
      parts.add('Disabled');
    }
    
    if (hasError) {
      parts.add(AccessibilityConstants.errorLabel);
    }
    
    if (hint != null && hint.isNotEmpty) {
      parts.add(hint);
    }
    
    return parts.join(', ');
  }

  /// Format number for screen readers (Indian numbering system for GIGW)
  static String formatNumberForScreenReader(int number, {bool useIndianSystem = true}) {
    if (!useIndianSystem || number < 1000) {
      return number.toString();
    }
    
    // Indian numbering system: Lakhs and Crores
    if (number >= 10000000) {
      final crores = (number / 10000000).toStringAsFixed(2);
      return '$crores Crore';
    } else if (number >= 100000) {
      final lakhs = (number / 100000).toStringAsFixed(2);
      return '$lakhs Lakh';
    } else if (number >= 1000) {
      final thousands = (number / 1000).toStringAsFixed(2);
      return '$thousands Thousand';
    }
    
    return number.toString();
  }

  /// Check if reduced motion is preferred (WCAG 2.3.3)
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get appropriate animation duration based on motion preferences
  static Duration getAnimationDuration(BuildContext context, {Duration? defaultDuration}) {
    if (shouldReduceMotion(context)) {
      return AccessibilityConstants.reducedMotionDuration;
    }
    return defaultDuration ?? AccessibilityConstants.defaultAnimationDuration;
  }

  /// Check if text scaling is within acceptable limits
  static bool isTextScaleAcceptable(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return textScaleFactor <= AccessibilityConstants.maxTextScaleFactor;
  }

  /// Get scaled font size with maximum limit
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final scaledSize = baseFontSize * textScaleFactor;
    final maxSize = baseFontSize * AccessibilityConstants.maxTextScaleFactor;
    return math.min(scaledSize, maxSize);
  }

  /// Create accessible button with proper semantics
  static Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? tooltip,
    bool isDestructive = false,
    bool isDisabled = false,
  }) {
    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel,
      hint: tooltip,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: ConstrainedBox(
          constraints: AccessibilityUtils.ensureMinimumTouchTarget(),
          child: child,
        ),
      ),
    );
  }

  /// Create accessible text field with proper semantics
  static Widget createAccessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? errorText,
    bool isRequired = false,
    bool isPassword = false,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Semantics(
      textField: true,
      label: createSemanticLabel(
        label: label,
        hint: hint,
        isRequired: isRequired,
        hasError: errorText != null,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          suffixIcon: isRequired 
              ? const Icon(Icons.star, size: 8, color: Colors.red)
              : null,
        ),
      ),
    );
  }

  /// Announce message to screen readers (Live Region)
  static void announceToScreenReader(BuildContext context, String message, {bool assertive = false}) {
    // Use SemanticsService to announce
    SemanticsService.announce(
      message,
      assertive ? TextDirection.ltr : TextDirection.ltr,
    );
  }

  /// Create skip link for keyboard navigation (WCAG 2.4.1)
  static Widget createSkipLink({
    required String label,
    required VoidCallback onPressed,
    required FocusNode focusNode,
  }) {
    return Focus(
      focusNode: focusNode,
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  /// Validate form field for accessibility
  static String? validateAccessibleFormField({
    required String? value,
    required String fieldName,
    bool isRequired = false,
    int? minLength,
    int? maxLength,
    String? pattern,
  }) {
    if (isRequired && (value == null || value.isEmpty)) {
      return '$fieldName is required';
    }
    
    if (value != null && value.isNotEmpty) {
      if (minLength != null && value.length < minLength) {
        return '$fieldName must be at least $minLength characters';
      }
      
      if (maxLength != null && value.length > maxLength) {
        return '$fieldName must not exceed $maxLength characters';
      }
      
      if (pattern != null && !RegExp(pattern).hasMatch(value)) {
        return '$fieldName format is invalid';
      }
    }
    
    return null;
  }

  /// Create accessible data table header
  static DataColumn createAccessibleDataColumn({
    required String label,
    String? tooltip,
    bool numeric = false,
  }) {
    return DataColumn(
      label: Semantics(
        header: true,
        label: label,
        child: Tooltip(
          message: tooltip ?? label,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      numeric: numeric,
    );
  }

  /// Create accessible icon with semantic label
  static Widget createAccessibleIcon({
    required IconData icon,
    required String semanticLabel,
    Color? color,
    double? size,
  }) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }

  /// Check if device supports high contrast mode (GIGW requirement)
  static bool isHighContrastMode(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  /// Get high contrast colors if enabled
  static ColorScheme getHighContrastColors(BuildContext context, ColorScheme baseScheme) {
    if (!isHighContrastMode(context)) {
      return baseScheme;
    }
    
    // Return high contrast color scheme
    return ColorScheme.highContrastLight(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      error: Colors.red.shade900,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    );
  }
}
