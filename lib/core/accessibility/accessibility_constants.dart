/// WCAG 2.2 and GIGW (Guidelines for Indian Government Websites) Accessibility Constants
/// 
/// This file contains constants and guidelines for implementing accessible applications
/// that comply with WCAG 2.2 Level AAA and GIGW standards.

class AccessibilityConstants {
  // WCAG 2.2 Contrast Ratios
  static const double contrastRatioAAA = 7.0; // For normal text
  static const double contrastRatioAAALarge = 4.5; // For large text (18pt+)
  static const double contrastRatioAA = 4.5; // For normal text
  static const double contrastRatioAALarge = 3.0; // For large text

  // Touch Target Sizes (WCAG 2.2.5.8 - Target Size Enhanced)
  static const double minTouchTargetSize = 44.0; // Minimum 44x44 dp
  static const double recommendedTouchTargetSize = 48.0; // Recommended 48x48 dp
  static const double minSpacingBetweenTargets = 8.0; // Minimum spacing

  // Text Sizing (WCAG 1.4.4 - Resize Text)
  static const double minFontSize = 14.0; // Minimum readable font size
  static const double baseFontSize = 16.0; // Base body text
  static const double largeFontSize = 18.0; // Large text threshold
  static const double maxTextScaleFactor = 2.0; // Support up to 200% scaling

  // Focus Indicators (WCAG 2.4.7 - Focus Visible)
  static const double focusIndicatorWidth = 3.0;
  static const double focusIndicatorOffset = 2.0;

  // Animation & Motion (WCAG 2.3.3 - Animation from Interactions)
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);
  static const Duration reducedMotionDuration = Duration(milliseconds: 0);
  static const Duration maxAnimationDuration = Duration(seconds: 5);

  // Timeouts (WCAG 2.2.1 - Timing Adjustable)
  static const Duration minTimeoutDuration = Duration(seconds: 20);
  static const Duration sessionTimeoutWarning = Duration(minutes: 2);

  // Language Support (GIGW Requirement)
  static const List<String> supportedLanguages = [
    'en', // English
    'hi', // Hindi
    'ta', // Tamil
    'te', // Telugu
    'bn', // Bengali
    'mr', // Marathi
    'gu', // Gujarati
    'kn', // Kannada
    'ml', // Malayalam
    'pa', // Punjabi
    'or', // Odia
    'as', // Assamese
  ];

  // Semantic Labels
  static const String skipToMainContent = 'Skip to main content';
  static const String skipToNavigation = 'Skip to navigation';
  static const String skipToFooter = 'Skip to footer';
  static const String openMenu = 'Open menu';
  static const String closeMenu = 'Close menu';
  static const String searchLabel = 'Search';
  static const String requiredFieldLabel = 'Required field';
  static const String errorLabel = 'Error';
  static const String warningLabel = 'Warning';
  static const String successLabel = 'Success';
  static const String infoLabel = 'Information';

  // ARIA Live Region Politeness
  static const String liveRegionPolite = 'polite';
  static const String liveRegionAssertive = 'assertive';
  static const String liveRegionOff = 'off';

  // Keyboard Navigation Keys
  static const String keyEnter = 'Enter';
  static const String keySpace = 'Space';
  static const String keyEscape = 'Escape';
  static const String keyTab = 'Tab';
  static const String keyArrowUp = 'ArrowUp';
  static const String keyArrowDown = 'ArrowDown';
  static const String keyArrowLeft = 'ArrowLeft';
  static const String keyArrowRight = 'ArrowRight';
  static const String keyHome = 'Home';
  static const String keyEnd = 'End';

  // GIGW Specific Requirements
  static const bool requireBilingualContent = true; // Hindi + English
  static const bool requireTextToSpeech = true;
  static const bool requireHighContrastMode = true;
  static const bool requireScreenReaderSupport = true;
  static const bool requireKeyboardNavigation = true;
  static const bool requireAccessibilityStatement = true;

  // Error Prevention (WCAG 3.3.4 - Error Prevention)
  static const bool requireConfirmationForDelete = true;
  static const bool requireConfirmationForSubmit = true;
  static const bool allowUndo = true;

  // Help & Documentation (WCAG 3.3.5 - Help)
  static const bool provideContextualHelp = true;
  static const bool provideInstructions = true;
  static const bool provideErrorSuggestions = true;
}

/// Accessibility Roles for Semantic Widgets
enum AccessibilityRole {
  button,
  link,
  header,
  navigation,
  main,
  complementary,
  contentInfo,
  form,
  search,
  region,
  article,
  list,
  listItem,
  table,
  row,
  cell,
  dialog,
  alert,
  status,
  progressBar,
  tab,
  tabPanel,
  menu,
  menuItem,
  checkbox,
  radio,
  textField,
  comboBox,
}

/// Accessibility States
enum AccessibilityState {
  enabled,
  disabled,
  selected,
  checked,
  unchecked,
  expanded,
  collapsed,
  pressed,
  focused,
  busy,
  invalid,
  required,
}

/// WCAG Success Criteria Levels
enum WCAGLevel {
  a, // Level A (minimum)
  aa, // Level AA (mid-range)
  aaa, // Level AAA (highest)
}

/// GIGW Compliance Levels
enum GIGWLevel {
  basic, // Basic compliance
  intermediate, // Intermediate compliance
  advanced, // Advanced compliance
}
