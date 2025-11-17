# UI Pages Documentation

## Overview
The authentication system includes 5 main UI pages that handle the complete user journey from registration to login.

## 1. Register Super Admin Page

### File: `lib/features/auth/presentation/pages/register_super_admin_page.dart`

**Route**: `/register-super-admin`

**Purpose**: Step 1 of 3-step flow - Create super admin account

**UI Elements**:
- Header: "Create Super Admin Account" with admin icon
- Name text field (person icon)
- Email text field (email icon) 
- Password field (lock icon + visibility toggle)
- "Continue" primary button
- Divider with "OR" text
- "Continue with Google" button
- "Continue with Microsoft" button (stub)
- "Already have an account? Login" link

**Validation**:
- Name: Required, non-empty
- Email: Required, valid email format (`^[^@]+@[^@]+\.[^@]+$`)
- Password: Required, minimum 6 characters

**Flow**:
1. User fills form and clicks Continue
2. Calls `authService.registerSuperAdmin()`
3. On success: Navigate to `/create-organization`
4. On error: Show error message

## 2. Create Organization Page

### File: `lib/features/auth/presentation/pages/create_organization_page.dart`

**Route**: `/create-organization`

**Purpose**: Step 2 of 3-step flow - Create organization and get tenant_id

**UI Elements**:
- Header: "Create Your Organization" with business icon
- Organization Details section:
  - Organization Name text field (business icon)
  - Organization Code text field (code icon)
  - Organization Description multiline field (description icon)
- Admin Details section:
  - Role display (read-only: "Super Admin")
  - Name text field (read-only, auto-filled)
  - Email text field (read-only, auto-filled)
- "Create Organization" primary button
- "Back" secondary button

**Validation**:
- Organization Name: Required, non-empty
- Organization Code: Required, alphanumeric, uppercase
- Organization Description: Required, minimum 10 characters

**Auto-fill Logic**:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (authService.tempName != null) {
      _nameController.text = authService.tempName!;
    }
    if (authService.tempEmail != null) {
      _emailController.text = authService.tempEmail!;
    }
  });
}
```

**Flow**:
1. User fills organization details
2. Admin details auto-filled from Step 1
3. Calls `authService.createOrganization()`
4. On success: Navigate to `/payment-notes` (fully authenticated)
5. On error: Show error message

## 3. Login Page

### File: `lib/features/auth/presentation/pages/login_page.dart`

**Route**: `/login`

**Purpose**: Step 3 - Login existing super admin

**UI Elements**:
- Header: "Welcome Back" with lock icon
- Email text field (email icon)
- Password field (lock icon + visibility toggle)
- "Login" primary button
- "Forgot password?" link
- Divider with "OR" text
- "Continue with Google" button
- "Continue with Microsoft" button (stub)
- "Don't have an account? Sign up" link (goes to `/register-super-admin`)

**Validation**:
- Email: Required, valid email format
- Password: Required, minimum 6 characters

**Flow**:
1. User enters credentials
2. Calls `authService.login()`
3. On success: Navigate to `/payment-notes`
4. On error: Show error message

## 4. Forgot Password Page

### File: `lib/features/auth/presentation/pages/forgot_password_page.dart`

**Route**: `/forgot-password`

**Purpose**: Password recovery flow

**UI Elements**:
- Header: "Forgot Password?" with lock reset icon
- Email text field
- "Send Reset Link" button
- Success state view after sending
- "Back to Sign In" link

**Flow**:
1. User enters email
2. Calls `authService.forgotPassword()`
3. Shows success message
4. User can resend or return to login

## 5. Verify Email Page

### File: `lib/features/auth/presentation/pages/verify_email_page.dart`

**Route**: `/verify-email`

**Purpose**: Email verification for users requiring verification

**UI Elements**:
- Header: "Verify Your Email" with email icon
- User's email display
- Instructions section
- "Send Verification Email" button
- "I've verified my email" button
- Help section for troubleshooting

**Flow**:
1. User sees verification instructions
2. Can resend verification email
3. Can check verification status
4. Auto-redirects when verified

## Common UI Components

### AuthTextField Widget
```dart
AuthTextField(
  controller: _controller,
  labelText: 'Field Label',
  hintText: 'Hint text',
  prefixIcon: Icons.icon_name,
  obscureText: false, // true for password fields
  validator: (value) => validation_logic,
)
```

### SocialLoginButton Widget
```dart
SocialLoginButton(
  text: 'Continue with Google',
  icon: Icons.g_mobiledata,
  onPressed: _handleGoogleLogin,
  isLoading: _isGoogleLoading,
)
```

### DividerWithText Widget
```dart
const DividerWithText(text: 'OR')
```

## Responsive Design

All pages are responsive with:
- **Mobile**: Full-width cards, 24px padding
- **Desktop**: Constrained width (400-500px), 32px padding, elevated cards
- **Breakpoint**: 900px screen width

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isDesktop = screenWidth > 900;

// Apply different styling based on screen size
ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: isDesktop ? 400 : double.infinity,
  ),
  child: Card(
    elevation: isDesktop ? 8 : 0,
    // ...
  ),
)
```

## Material Design 3

All pages follow Material Design 3 principles:
- Color scheme from `Theme.of(context).colorScheme`
- Typography from `theme.textTheme`
- Card-based layouts with rounded corners (16px radius)
- Consistent spacing (8px, 16px, 24px, 32px)
- Loading states with circular progress indicators
- Error states with colored snack bars

## State Management

Pages use local state for:
- Form controllers
- Loading states
- Validation states

Global state through `AuthService`:
- Authentication status
- Current user data
- Temporary registration data
- Organization data

## Navigation

All navigation uses GoRouter:
```dart
// Programmatic navigation
context.go('/target-route');

// Back navigation
context.go('/previous-route');
```

## Error Handling

Consistent error handling pattern:
```dart
final result = await authService.someMethod();

if (result.success) {
  // Handle success
  context.go('/next-page');
} else {
  // Show error
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message ?? 'Operation failed'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
```
