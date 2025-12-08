# Accessibility Implementation Guide
## Quick Start Guide for Developers

This guide shows you how to implement WCAG 2.2 AAA and GIGW accessibility features in your Flutter ERP application.

---

## 📚 Table of Contents

1. [Quick Start](#quick-start)
2. [Using Accessible Widgets](#using-accessible-widgets)
3. [Common Patterns](#common-patterns)
4. [Best Practices](#best-practices)
5. [Code Examples](#code-examples)
6. [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Import Accessibility Utilities

```dart
import 'package:ppv_components/core/accessibility/accessibility_constants.dart';
import 'package:ppv_components/core/accessibility/accessibility_utils.dart';
import 'package:ppv_components/core/accessibility/accessible_widgets.dart';
```

### 2. Basic Page Structure

```dart
class MyAccessiblePage extends StatefulWidget {
  @override
  State<MyAccessiblePage> createState() => _MyAccessiblePageState();
}

class _MyAccessiblePageState extends State<MyAccessiblePage> {
  final FocusNode _skipToMainFocusNode = FocusNode();
  final GlobalKey _mainContentKey = GlobalKey();

  @override
  void dispose() {
    _skipToMainFocusNode.dispose();
    super.dispose();
  }

  void _skipToMainContent() {
    Scrollable.ensureVisible(
      _mainContentKey.currentContext!,
      duration: const Duration(milliseconds: 300),
    );
    AccessibilityUtils.announceToScreenReader(
      context,
      'Navigated to main content',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'My Page',
      container: true,
      child: Scaffold(
        body: Column(
          children: [
            // Skip Navigation Link
            SkipNavigationLink(
              label: AccessibilityConstants.skipToMainContent,
              onPressed: _skipToMainContent,
              focusNode: _skipToMainFocusNode,
            ),
            // Main Content
            Expanded(
              child: Container(
                key: _mainContentKey,
                child: YourMainContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Using Accessible Widgets

### AccessibleButton

✅ **Minimum 48x48dp touch target**  
✅ **3px focus indicator**  
✅ **Keyboard support (Enter/Space)**  
✅ **Screen reader labels**  
✅ **Automatic color contrast**

```dart
AccessibleButton(
  semanticLabel: 'Save user',
  tooltip: 'Save the user information',
  onPressed: () => saveUser(),
  child: Text('Save'),
)

// Destructive action
AccessibleButton(
  semanticLabel: 'Delete user',
  tooltip: 'Permanently delete this user',
  isDestructive: true,
  onPressed: () => deleteUser(),
  child: Text('Delete'),
)
```

### AccessibleIconButton

✅ **Semantic labels for icons**  
✅ **Minimum touch target**  
✅ **Keyboard navigation**  
✅ **Tooltips**

```dart
AccessibleIconButton(
  icon: Icons.edit,
  semanticLabel: 'Edit user',
  tooltip: 'Edit user details',
  onPressed: () => editUser(),
  color: colorScheme.primary,
)

AccessibleIconButton(
  icon: Icons.delete,
  semanticLabel: 'Delete user',
  tooltip: 'Delete this user',
  onPressed: () => deleteUser(),
  color: colorScheme.error,
)
```

### AccessibleTextField

✅ **Semantic labels**  
✅ **Error announcements**  
✅ **Required field indicators**  
✅ **Password visibility toggle**  
✅ **Focus management**

```dart
AccessibleTextField(
  controller: emailController,
  label: 'Email',
  hint: 'Enter your email address',
  isRequired: true,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  },
)

// Password field
AccessibleTextField(
  controller: passwordController,
  label: 'Password',
  isRequired: true,
  isPassword: true,
  hint: 'Enter your password',
)
```

### AccessibleAlertDialog

✅ **Proper ARIA roles**  
✅ **Keyboard trap management**  
✅ **Focus restoration**  
✅ **Screen reader announcements**

```dart
showDialog(
  context: context,
  builder: (context) => AccessibleAlertDialog(
    title: 'Confirm Delete',
    content: 'Are you sure you want to delete this user? This action cannot be undone.',
    isDestructive: true,
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('Delete'),
      ),
    ],
  ),
);
```

---

## Common Patterns

### 1. Semantic Headers

```dart
Semantics(
  header: true,
  label: 'User Management Section',
  child: Text(
    'Users',
    style: TextStyle(
      fontSize: AccessibilityUtils.getScaledFontSize(context, 24.0),
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

### 2. Search with Live Announcements

```dart
void updateSearch(String query) {
  setState(() {
    filteredItems = allItems.where((item) => 
      item.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  });
  
  // Announce results to screen reader
  final count = filteredItems.length;
  final announcement = count == 0
      ? 'No results found for "$query"'
      : 'Found $count ${count == 1 ? "result" : "results"} for "$query"';
  
  AccessibilityUtils.announceToScreenReader(context, announcement);
}
```

### 3. Data Tables with Accessibility

```dart
DataTable(
  columns: [
    AccessibilityUtils.createAccessibleDataColumn(
      label: 'Name',
      tooltip: 'User full name',
    ),
    AccessibilityUtils.createAccessibleDataColumn(
      label: 'Email',
      tooltip: 'User email address',
    ),
    AccessibilityUtils.createAccessibleDataColumn(
      label: 'Actions',
      tooltip: 'Available actions for this user',
    ),
  ],
  rows: users.map((user) => DataRow(
    cells: [
      DataCell(
        Semantics(
          label: 'Name: ${user.name}',
          child: Text(user.name),
        ),
      ),
      DataCell(
        Semantics(
          label: 'Email: ${user.email}',
          child: Text(user.email),
        ),
      ),
      DataCell(
        Row(
          children: [
            AccessibleIconButton(
              icon: Icons.edit,
              semanticLabel: 'Edit ${user.name}',
              onPressed: () => editUser(user),
            ),
            AccessibleIconButton(
              icon: Icons.delete,
              semanticLabel: 'Delete ${user.name}',
              onPressed: () => deleteUser(user),
            ),
          ],
        ),
      ),
    ],
  )).toList(),
)
```

### 4. Loading States

```dart
if (isLoading)
  AccessibleLoadingIndicator(
    message: 'Loading users...',
  )
else
  YourContent()
```

### 5. Empty States

```dart
if (users.isEmpty)
  Semantics(
    label: 'No users found',
    liveRegion: true,
    child: Center(
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 64),
          SizedBox(height: 16),
          Text('No users found'),
          SizedBox(height: 8),
          AccessibleButton(
            semanticLabel: 'Create new user',
            onPressed: () => createUser(),
            child: Text('Create User'),
          ),
        ],
      ),
    ),
  )
```

---

## Best Practices

### 1. Color Contrast

✅ **Always check contrast ratios**

```dart
// Check if colors meet WCAG AAA
final meetsAAA = AccessibilityUtils.meetsWCAGAAA(
  textColor,
  backgroundColor,
);

// Get accessible text color automatically
final textColor = AccessibilityUtils.getAccessibleTextColor(backgroundColor);
```

### 2. Touch Targets

✅ **Ensure minimum 48x48dp**

```dart
// Wrap all interactive elements
ConstrainedBox(
  constraints: AccessibilityUtils.ensureMinimumTouchTarget(),
  child: IconButton(...),
)
```

### 3. Focus Indicators

✅ **Always show 3px focus border**

```dart
TextField(
  decoration: InputDecoration(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: AccessibilityConstants.focusIndicatorWidth, // 3px
      ),
    ),
  ),
)
```

### 4. Keyboard Navigation

✅ **Support Enter and Space for buttons**

```dart
Focus(
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
         event.logicalKey == LogicalKeyboardKey.space)) {
      onPressed?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: widget,
)
```

### 5. Reduced Motion

✅ **Respect motion preferences**

```dart
final duration = AccessibilityUtils.getAnimationDuration(
  context,
  defaultDuration: Duration(milliseconds: 300),
);

AnimatedContainer(
  duration: duration,
  // ...
)
```

### 6. Text Scaling

✅ **Support up to 200% scaling**

```dart
Text(
  'Hello',
  style: TextStyle(
    fontSize: AccessibilityUtils.getScaledFontSize(
      context,
      AccessibilityConstants.baseFontSize,
    ),
  ),
)
```

---

## Code Examples

### Complete Accessible Form

```dart
class AccessibleUserForm extends StatefulWidget {
  @override
  State<AccessibleUserForm> createState() => _AccessibleUserFormState();
}

class _AccessibleUserFormState extends State<AccessibleUserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Show confirmation
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AccessibleAlertDialog(
          title: 'Confirm Submission',
          content: 'Are you sure you want to create this user?',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Submit form
        AccessibilityUtils.announceToScreenReader(
          context,
          'User created successfully',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'User creation form',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Name field
            AccessibleTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter user full name',
              isRequired: true,
              validator: (value) => AccessibilityUtils.validateAccessibleFormField(
                value: value,
                fieldName: 'Full Name',
                isRequired: true,
                minLength: 2,
              ),
            ),
            SizedBox(height: 16),

            // Email field
            AccessibleTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter email address',
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final error = AccessibilityUtils.validateAccessibleFormField(
                  value: value,
                  fieldName: 'Email',
                  isRequired: true,
                  pattern: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                );
                if (error != null) return error;
                return null;
              },
            ),
            SizedBox(height: 16),

            // Phone field
            AccessibleTextField(
              controller: _phoneController,
              label: 'Phone',
              hint: 'Enter 10-digit phone number',
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value) => AccessibilityUtils.validateAccessibleFormField(
                value: value,
                fieldName: 'Phone',
                minLength: 10,
                maxLength: 10,
              ),
            ),
            SizedBox(height: 24),

            // Submit button
            AccessibleButton(
              semanticLabel: 'Create user',
              tooltip: 'Submit form to create new user',
              onPressed: _submitForm,
              child: Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Accessible List with Actions

```dart
class AccessibleUserList extends StatelessWidget {
  final List<User> users;
  final Function(User) onEdit;
  final Function(User) onDelete;

  const AccessibleUserList({
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'User list with ${users.length} users',
      list: true,
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Semantics(
            label: 'User ${index + 1} of ${users.length}: ${user.name}',
            child: AccessibleCard(
              semanticLabel: 'User card for ${user.name}',
              child: ListTile(
                leading: Semantics(
                  label: 'User avatar',
                  image: true,
                  child: CircleAvatar(
                    child: Text(user.name[0]),
                  ),
                ),
                title: Semantics(
                  label: 'Name: ${user.name}',
                  child: Text(user.name),
                ),
                subtitle: Semantics(
                  label: 'Email: ${user.email}',
                  child: Text(user.email),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AccessibleIconButton(
                      icon: Icons.edit,
                      semanticLabel: 'Edit ${user.name}',
                      tooltip: 'Edit user details',
                      onPressed: () => onEdit(user),
                    ),
                    SizedBox(width: 8),
                    AccessibleIconButton(
                      icon: Icons.delete,
                      semanticLabel: 'Delete ${user.name}',
                      tooltip: 'Delete this user',
                      onPressed: () => onDelete(user),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## Troubleshooting

### Issue: Focus indicator not visible

**Solution:**
```dart
// Ensure focus border has sufficient width and contrast
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: colorScheme.primary,
    width: AccessibilityConstants.focusIndicatorWidth, // 3px
  ),
)
```

### Issue: Screen reader not announcing changes

**Solution:**
```dart
// Use live regions for dynamic content
Semantics(
  liveRegion: true,
  child: Text('5 results found'),
)

// Or announce explicitly
AccessibilityUtils.announceToScreenReader(
  context,
  'Search completed: 5 results found',
);
```

### Issue: Touch targets too small

**Solution:**
```dart
// Wrap in ConstrainedBox
ConstrainedBox(
  constraints: AccessibilityUtils.ensureMinimumTouchTarget(
    minWidth: 48.0,
    minHeight: 48.0,
  ),
  child: IconButton(...),
)
```

### Issue: Poor color contrast

**Solution:**
```dart
// Check contrast before using
final meetsWCAG = AccessibilityUtils.meetsWCAGAAA(
  foreground,
  background,
);

if (!meetsWCAG) {
  // Use accessible color
  foreground = AccessibilityUtils.getAccessibleTextColor(background);
}
```

### Issue: Keyboard trap in dialog

**Solution:**
```dart
// Ensure dialog can be closed with Escape
Focus(
  onKeyEvent: (node, event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  },
  child: AlertDialog(...),
)
```

---

## Checklist for New Features

When implementing a new feature, ensure:

- [ ] All interactive elements have semantic labels
- [ ] Touch targets are ≥ 48x48dp
- [ ] Focus indicators are visible (3px border)
- [ ] Keyboard navigation works (Tab, Enter, Space, Escape)
- [ ] Color contrast meets WCAG AAA (7:1)
- [ ] Text can scale to 200%
- [ ] Screen reader announces all content
- [ ] Forms have proper validation and error messages
- [ ] Destructive actions require confirmation
- [ ] Loading states are announced
- [ ] Empty states are accessible
- [ ] Animations respect reduced motion
- [ ] Skip navigation is available on pages
- [ ] Help text is available where needed

---

## Resources

### Documentation
- [WCAG 2.2 Guidelines](https://www.w3.org/WAI/WCAG22/quickref/)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [GIGW Guidelines](https://guidelines.india.gov.in/)

### Tools
- Contrast Checker: https://webaim.org/resources/contrastchecker/
- Screen Readers: NVDA, JAWS, TalkBack, VoiceOver
- Flutter DevTools: Accessibility Inspector

### Support
- Email: accessibility@yourcompany.com
- Slack: #accessibility
- Wiki: https://wiki.yourcompany.com/accessibility

---

**Last Updated**: January 4, 2025  
**Version**: 1.0.0  
**Compliance**: WCAG 2.2 AAA + GIGW Advanced
