# Router Configuration Documentation

## File: `lib/app/router.dart`

### Purpose
Manages navigation and route protection for the 3-step authentication flow with automatic redirects based on authentication state.

## Router Configuration

```dart
final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) async {
    // Authentication state checks
    final bool isLoggedIn = await JwtTokenManager.isAuthenticated();
    final bool isEmailVerified = await JwtTokenManager.isEmailVerified();
    final String? tenantId = await JwtTokenManager.getTenantId();
    
    // Route classification
    final bool isAuthRoute = /* auth route check */;

    // Redirect logic
    // ...
  },
  routes: [
    // Authentication routes
    // Protected routes
  ],
);
```

## Authentication State Logic

### 3-Level Authentication Check

1. **JWT Token Valid**: `JwtTokenManager.isAuthenticated()`
   - Checks if access token exists and is not expired
   - Uses `jwt_decoder` to validate token structure

2. **Tenant ID Exists**: `JwtTokenManager.getTenantId()`
   - Checks if user has completed organization setup
   - Required for full application access

3. **Email Verified**: `JwtTokenManager.isEmailVerified()`
   - Checks if email verification is complete (if required)
   - Optional step based on backend configuration

### Route Classification

```dart
final bool isAuthRoute = state.matchedLocation == '/login' ||
    state.matchedLocation == '/register-super-admin' ||
    state.matchedLocation == '/create-organization' ||
    state.matchedLocation == '/signup' ||
    state.matchedLocation == '/forgot-password' ||
    state.matchedLocation == '/verify-email';
```

## Redirect Logic Flow

### 1. Not Authenticated
```dart
if (!isLoggedIn && !isAuthRoute) return '/login';
```
- **Condition**: No valid JWT token
- **Action**: Redirect to login page
- **Applies to**: All protected routes

### 2. Authenticated but No Tenant
```dart
if (isLoggedIn && tenantId == null && state.matchedLocation != '/create-organization') {
  return '/create-organization';
}
```
- **Condition**: Valid JWT but no tenant_id
- **Action**: Redirect to organization creation
- **Use Case**: User completed Step 1 but not Step 2

### 3. Authenticated but Email Not Verified
```dart
if (isLoggedIn && tenantId != null && !isEmailVerified && 
    state.matchedLocation != '/verify-email') {
  return '/verify-email';
}
```
- **Condition**: Valid JWT and tenant_id but email not verified
- **Action**: Redirect to email verification
- **Use Case**: Organization created but email verification required

### 4. Fully Authenticated Accessing Auth Pages
```dart
if (isLoggedIn && tenantId != null && isEmailVerified && isAuthRoute) {
  return '/payment-notes';
}
```
- **Condition**: Complete authentication trying to access auth pages
- **Action**: Redirect to main dashboard
- **Use Case**: Logged-in user navigating to login/register pages

## Route Definitions

### Authentication Routes (No Layout)

```dart
// Step 1: Super Admin Registration
GoRoute(
  path: '/register-super-admin',
  builder: (context, state) => const RegisterSuperAdminPage(),
),

// Step 2: Organization Creation  
GoRoute(
  path: '/create-organization',
  builder: (context, state) => const CreateOrganizationPage(),
),

// Step 3: Login
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginPage(),
),

// Additional auth routes
GoRoute(
  path: '/forgot-password',
  builder: (context, state) => const ForgotPasswordPage(),
),
GoRoute(
  path: '/verify-email',
  builder: (context, state) => const VerifyEmailPage(),
),
```

### Protected Routes (With Layout)

```dart
ShellRoute(
  builder: (context, state, child) => LayoutPage(child: child),
  routes: [
    // Main dashboard
    GoRoute(
      path: '/payment-notes',
      builder: (context, state) => const PaymentMainPage(),
    ),
    
    // Other ERP features
    GoRoute(
      path: '/users',
      builder: (context, state) => const UserMainPage(),
    ),
    // ... more protected routes
  ],
),
```

## Layout Structure

### Authentication Pages
- **No Layout Wrapper**: Direct page rendering
- **Full Screen**: Auth pages take full viewport
- **No Navigation**: No side menu or app bar (except page-specific)

### Protected Pages
- **LayoutPage Wrapper**: Includes side navigation, app bar, etc.
- **Consistent UI**: All main app features share same layout
- **Navigation Menu**: Access to all ERP features

## Navigation Examples

### Programmatic Navigation
```dart
// In auth pages
if (result.success) {
  context.go('/create-organization'); // Step 1 → Step 2
  context.go('/payment-notes');       // Step 2 → Dashboard
}

// Error navigation
context.go('/login'); // Back to login on error
```

### Automatic Redirects
```dart
// Router automatically handles these scenarios:

// User tries to access /users without login
// → Redirects to /login

// User completes registration but no organization
// → Redirects to /create-organization

// User has token but needs email verification  
// → Redirects to /verify-email

// Logged-in user navigates to /login
// → Redirects to /payment-notes
```

## Error Handling

### Invalid Routes
- **404 Handling**: Redirects to appropriate page based on auth status
- **Protected Route Access**: Automatic redirect to login

### Auth State Changes
- **Token Expiry**: Interceptor handles automatic refresh or logout
- **Manual Logout**: Clears tokens and redirects to login
- **Session Validation**: Periodic auth status checks

## Development vs Production

### Development
```dart
initialLocation: '/login', // Always start with login for testing
```

### Production
```dart
initialLocation: '/login', // Can be changed based on requirements
```

## Testing Considerations

### Route Testing
```dart
// Test authentication redirects
await tester.pumpWidget(app);
expect(find.byType(LoginPage), findsOneWidget); // Not authenticated

// Mock authentication
await mockAuthentication();
await tester.pumpAndSettle();
expect(find.byType(PaymentMainPage), findsOneWidget); // Authenticated
```

### State Persistence
- Router maintains navigation stack
- Authentication state persists across app restarts
- Proper cleanup on logout ensures fresh state

## Performance Considerations

### Async Redirects
- All redirect logic is async to check stored tokens
- Minimal performance impact due to efficient storage access
- Caching of auth state where appropriate

### Route Rebuilding
- Router rebuilds only on auth state changes
- Efficient change detection through `ChangeNotifier`
- Minimal widget tree rebuilds
