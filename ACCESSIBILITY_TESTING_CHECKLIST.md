# Accessibility Testing Checklist
## WCAG 2.2 AAA & GIGW Compliance Verification

Use this checklist to verify accessibility compliance before deployment.

---

## 🎯 Quick Test Summary

| Category | Tests | Status |
|----------|-------|--------|
| Perceivable | 23 | ⬜ |
| Operable | 28 | ⬜ |
| Understandable | 17 | ⬜ |
| Robust | 5 | ⬜ |
| GIGW Specific | 12 | ⬜ |
| **Total** | **85** | **⬜** |

---

## 1. Perceivable Tests

### 1.1 Text Alternatives
- [ ] All images have alt text or semantic labels
- [ ] Decorative images are hidden from screen readers
- [ ] Icons have semantic labels
- [ ] Complex images have detailed descriptions
- [ ] Form buttons have accessible names

### 1.2 Time-based Media
- [ ] Videos have captions
- [ ] Audio has transcripts
- [ ] Media players are keyboard accessible
- [ ] Auto-play can be disabled

### 1.3 Adaptable
- [ ] Content structure is semantic (headers, lists, etc.)
- [ ] Reading order is logical
- [ ] Information doesn't rely on shape/color alone
- [ ] Works in portrait and landscape
- [ ] Form fields have proper autocomplete
- [ ] Relationships are programmatically determinable

### 1.4 Distinguishable
- [ ] **Contrast ratio ≥ 7:1 for normal text (AAA)**
- [ ] **Contrast ratio ≥ 4.5:1 for large text (AAA)**
- [ ] UI components have 3:1 contrast
- [ ] Color is not the only visual means of conveying information
- [ ] Text can be resized to 200% without loss of content
- [ ] Images of text are avoided (or have 7:1 contrast)
- [ ] Content reflows at 400% zoom without horizontal scrolling
- [ ] Text spacing can be adjusted
- [ ] Content on hover/focus is dismissible and persistent

**Test Tools:**
```bash
# Check contrast ratios
flutter run --profile
# Use accessibility_utils.dart:
AccessibilityUtils.calculateContrastRatio(foreground, background)
```

---

## 2. Operable Tests

### 2.1 Keyboard Accessible
- [ ] All functionality available via keyboard
- [ ] No keyboard traps
- [ ] Tab order is logical
- [ ] Enter/Space activates buttons
- [ ] Escape closes dialogs
- [ ] Arrow keys navigate lists/menus
- [ ] Shortcuts don't conflict with screen readers

**Keyboard Test Commands:**
```
Tab          - Move to next element
Shift+Tab    - Move to previous element
Enter        - Activate button/link
Space        - Activate button/checkbox
Escape       - Close dialog/cancel
Arrow Keys   - Navigate within component
Home/End     - Jump to start/end
```

### 2.2 Enough Time
- [ ] Time limits can be extended
- [ ] Auto-updating content can be paused
- [ ] No time limits on reading/interaction (AAA)
- [ ] Session timeout warnings appear 2 minutes before
- [ ] Users can save and continue later
- [ ] No automatic logouts without warning

### 2.3 Seizures and Physical Reactions
- [ ] No content flashes more than 3 times per second
- [ ] No flashing content at all (AAA)
- [ ] Animations respect `prefers-reduced-motion`
- [ ] Parallax effects can be disabled
- [ ] No sudden movements

**Test Reduced Motion:**
```dart
// Enable reduced motion in device settings
// Verify animations are disabled or reduced
AccessibilityUtils.shouldReduceMotion(context) // Should return true
```

### 2.4 Navigable
- [ ] **Skip navigation link present and functional**
- [ ] Page titles are descriptive
- [ ] Focus order follows visual order
- [ ] Link text is descriptive (not "click here")
- [ ] Multiple ways to navigate (menu, search, sitemap)
- [ ] Headings and labels are descriptive
- [ ] **Focus indicator is visible (3px border)**
- [ ] Current location is indicated
- [ ] Section headings organize content
- [ ] **Focus is not obscured by other content**
- [ ] **Focus indicator has 3:1 contrast ratio**

**Test Skip Navigation:**
```
1. Press Tab on page load
2. Verify "Skip to main content" appears
3. Press Enter
4. Verify focus moves to main content
```

### 2.5 Input Modalities
- [ ] All gestures have single-pointer alternative
- [ ] Touch actions can be cancelled
- [ ] Visible labels match accessible names
- [ ] Motion-based features have alternatives
- [ ] **Touch targets ≥ 48x48 dp (AAA)**
- [ ] **Touch targets ≥ 44x44 dp minimum**
- [ ] Spacing between targets ≥ 8dp
- [ ] Drag operations have click alternatives
- [ ] Works with mouse, touch, keyboard, and voice

**Measure Touch Targets:**
```dart
// All interactive elements should use:
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 48.0,  // AAA standard
    minHeight: 48.0,
  ),
  child: widget,
)
```

---

## 3. Understandable Tests

### 3.1 Readable
- [ ] Page language is set (en/hi)
- [ ] Language changes are marked
- [ ] Unusual words have definitions
- [ ] Abbreviations are expanded
- [ ] Reading level is appropriate (lower secondary)
- [ ] Pronunciation guides provided where needed

**Test Language:**
```dart
// Verify language support
MaterialApp(
  locale: Locale('en'), // or 'hi' for Hindi
  supportedLocales: [
    Locale('en'),
    Locale('hi'),
    // ... other Indian languages
  ],
)
```

### 3.2 Predictable
- [ ] Focus doesn't trigger unexpected changes
- [ ] Input doesn't cause unexpected changes
- [ ] Navigation is consistent across pages
- [ ] Components are identified consistently
- [ ] Changes only occur on user request (AAA)
- [ ] Help is in consistent location

### 3.3 Input Assistance
- [ ] Errors are clearly identified
- [ ] Labels or instructions are provided
- [ ] Error suggestions are provided
- [ ] Confirmation required for legal/financial actions
- [ ] Context-sensitive help is available (AAA)
- [ ] All submissions are confirmable (AAA)
- [ ] No redundant data entry
- [ ] No cognitive function tests for authentication
- [ ] Object recognition allowed for authentication

**Test Form Validation:**
```dart
// Required field validation
AccessibleTextField(
  label: 'Email',
  isRequired: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return null;
  },
)
```

---

## 4. Robust Tests

### 4.1 Compatible
- [ ] Valid Flutter widget structure
- [ ] All components have name, role, value
- [ ] Status messages use live regions
- [ ] Works with screen readers
- [ ] Works with voice control
- [ ] Compatible with assistive technologies

**Test Screen Readers:**
- Windows: NVDA, JAWS
- Android: TalkBack
- iOS: VoiceOver

---

## 5. GIGW Specific Tests

### 5.1 Bilingual Content
- [ ] All content available in Hindi
- [ ] All content available in English
- [ ] Language switcher is prominent
- [ ] Language preference is saved
- [ ] Fonts support Devanagari script

### 5.2 Indian Localization
- [ ] Numbers formatted in Indian system (Lakhs/Crores)
- [ ] Dates in DD/MM/YYYY format
- [ ] Currency in ₹ (Rupees)
- [ ] Phone numbers in Indian format
- [ ] Addresses support Indian format

**Test Number Formatting:**
```dart
AccessibilityUtils.formatNumberForScreenReader(1500000)
// Should announce: "15.00 Lakh"
```

### 5.3 Government Standards
- [ ] Accessibility statement page exists
- [ ] Contact information for accessibility issues
- [ ] Conformance level clearly stated
- [ ] Known limitations documented
- [ ] WCAG 2.2 AAA logo displayed
- [ ] Last updated date shown

### 5.4 Additional Requirements
- [ ] Works on low bandwidth (< 2G)
- [ ] Works on older devices
- [ ] Supports government ID authentication
- [ ] Data privacy compliant
- [ ] Secure (HTTPS)
- [ ] Mobile responsive

---

## 6. Automated Testing

### Run Flutter Accessibility Tests
```bash
# Run accessibility scanner
flutter test --coverage

# Check for accessibility issues
flutter analyze

# Run specific accessibility tests
flutter test test/accessibility_test.dart
```

### Use Accessibility Scanner
```dart
// In your test file
testWidgets('Accessibility test', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  // Check for minimum touch target size
  final SemanticsHandle handle = tester.ensureSemantics();
  await tester.pumpAndSettle();
  
  // Verify semantics
  expect(tester.getSemantics(find.byType(IconButton)), 
    matchesSemantics(
      label: 'Delete',
      isButton: true,
    ),
  );
  
  handle.dispose();
});
```

---

## 7. Manual Testing Procedures

### Screen Reader Testing

#### NVDA (Windows)
```
1. Install NVDA (free)
2. Start NVDA (Ctrl+Alt+N)
3. Navigate with Tab
4. Listen to announcements
5. Verify all content is read
6. Test forms and buttons
7. Verify live regions work
```

#### TalkBack (Android)
```
1. Enable TalkBack in Settings
2. Swipe right to navigate
3. Double-tap to activate
4. Verify all content is announced
5. Test gestures
6. Verify focus order
```

### Keyboard Testing
```
1. Unplug mouse
2. Navigate entire app with keyboard only
3. Verify all features accessible
4. Check focus indicators visible
5. Test all forms
6. Verify dialogs can be closed
7. Test skip navigation
```

### Zoom Testing
```
1. Set browser zoom to 200%
2. Verify no horizontal scrolling
3. Check all content visible
4. Test all interactions work
5. Verify text doesn't overlap
```

### High Contrast Testing
```
1. Enable high contrast mode in OS
2. Verify all content visible
3. Check focus indicators
4. Verify colors have sufficient contrast
5. Test all states (hover, focus, active)
```

---

## 8. Common Issues Checklist

### Critical Issues (Must Fix)
- [ ] Missing alt text on images
- [ ] Insufficient color contrast (< 7:1)
- [ ] Keyboard traps
- [ ] Missing focus indicators
- [ ] Touch targets too small (< 44dp)
- [ ] Missing form labels
- [ ] Inaccessible error messages
- [ ] No skip navigation

### Important Issues (Should Fix)
- [ ] Inconsistent navigation
- [ ] Unclear link text
- [ ] Missing headings
- [ ] Poor focus order
- [ ] No timeout warnings
- [ ] Missing ARIA labels
- [ ] Redundant data entry

### Minor Issues (Nice to Fix)
- [ ] Suboptimal heading hierarchy
- [ ] Missing tooltips
- [ ] Inconsistent terminology
- [ ] Missing help text

---

## 9. Browser/Device Testing Matrix

| Browser/Device | Version | Screen Reader | Status |
|----------------|---------|---------------|--------|
| Chrome Desktop | Latest | NVDA | ⬜ |
| Firefox Desktop | Latest | JAWS | ⬜ |
| Edge Desktop | Latest | Narrator | ⬜ |
| Safari Desktop | Latest | VoiceOver | ⬜ |
| Chrome Android | Latest | TalkBack | ⬜ |
| Safari iOS | Latest | VoiceOver | ⬜ |

---

## 10. Compliance Sign-off

### WCAG 2.2 Level AAA
- [ ] All Level A criteria passed (25/25)
- [ ] All Level AA criteria passed (20/20)
- [ ] All Level AAA criteria passed (28/28)
- [ ] Total: 73/73 success criteria

### GIGW Guidelines
- [ ] Bilingual content (Hindi + English)
- [ ] Screen reader compatible
- [ ] Keyboard accessible
- [ ] High contrast mode
- [ ] Text resizing (200%)
- [ ] Accessibility statement
- [ ] Indian localization

### Final Approval
- [ ] Accessibility lead approval
- [ ] Development team sign-off
- [ ] QA testing complete
- [ ] User testing with disabilities
- [ ] Legal compliance verified
- [ ] Documentation complete

---

## 11. Resources

### Testing Tools
- **Contrast Checker**: https://webaim.org/resources/contrastchecker/
- **WAVE**: https://wave.webaim.org/
- **axe DevTools**: Browser extension
- **Lighthouse**: Chrome DevTools
- **Screen Readers**: NVDA, JAWS, TalkBack, VoiceOver

### Documentation
- **WCAG 2.2**: https://www.w3.org/WAI/WCAG22/quickref/
- **GIGW**: https://guidelines.india.gov.in/
- **Flutter Accessibility**: https://docs.flutter.dev/development/accessibility-and-localization/accessibility

### Support
- **Email**: accessibility@yourcompany.com
- **Phone**: 1800-XXX-XXXX
- **Web**: https://yourcompany.com/accessibility

---

## 12. Testing Schedule

### Pre-Release
- [ ] Week 1: Automated testing
- [ ] Week 2: Manual keyboard testing
- [ ] Week 3: Screen reader testing
- [ ] Week 4: User testing with disabilities

### Post-Release
- [ ] Monthly: Automated scans
- [ ] Quarterly: Full manual audit
- [ ] Annually: Third-party audit
- [ ] Ongoing: User feedback monitoring

---

**Last Updated**: January 4, 2025  
**Next Review**: April 4, 2025  
**Compliance Target**: WCAG 2.2 Level AAA + GIGW Advanced
