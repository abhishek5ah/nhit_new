# Auth Service Documentation

## File: `lib/core/services/auth_service.dart`

### Purpose
Central business logic for the 3-step authentication flow, state management, and user session handling.

### Class: `AuthService extends ChangeNotifier`

### State Variables

```dart
bool _isAuthenticated = false;
UserModel? _currentUser;
bool _emailVerified = false;
bool _isLoading = false;

// Temporary storage for 3-step registration
String? _tempName;
String? _tempEmail;
String? _tempPassword;
OrganizationResponse? _organizationData;
```

### Getters

```dart
bool get isAuthenticated => _isAuthenticated;
UserModel? get currentUser => _currentUser;
bool get emailVerified => _emailVerified;
bool get isLoading => _isLoading;
String? get tempName => _tempName;
String? get tempEmail => _tempEmail;
String? get tempPassword => _tempPassword;
OrganizationResponse? get organizationData => _organizationData;
```

### 3-Step Authentication Flow

#### Step 1: Super Admin Registration

```dart
Future<({bool success, String? message})> registerSuperAdmin(
  SuperAdminRegisterRequest request
) async
```

**Process**:
1. Call auth repository to register user
2. Store temporary user data for Step 2
3. Save JWT tokens (not fully authenticated yet)
4. Navigate to organization creation

**Response**: Returns success status and message

#### Step 2: Create Organization

```dart
Future<({bool success, String? message})> createOrganization(
  CreateOrganizationRequest request
) async
```

**Process**:
1. Call repository to create organization
2. Save tenant_id from response
3. Set fully authenticated status
4. Clear temporary data
5. Navigate to main dashboard

**Response**: Returns success status and message

#### Step 3: Login (Existing Users)

```dart
Future<({bool success, String? message})> login(
  LoginRequest request
) async
```

**Process**:
1. Call auth repository to login
2. Extract tenant_id from JWT or user data
3. Save all authentication data
4. Set authenticated status
5. Navigate to main dashboard

**Response**: Returns success status and message

### Additional Methods

#### Initialize Service
```dart
Future<void> initialize() async
```
- Called on app startup
- Checks existing authentication status
- Restores user session if valid tokens exist

#### Check Auth Status
```dart
Future<({bool success, String? message})> checkAuthStatus() async
```
- Validates current authentication state
- Extracts user info from stored tokens
- Updates internal state variables

#### Logout
```dart
Future<({bool success, String? message})> logout() async
```
- Calls logout API endpoint
- Clears all stored tokens and data
- Resets authentication state
- Navigates to login page

#### Email Verification
```dart
Future<({bool success, String? message})> verifyEmail(String token) async
Future<({bool success, String? message})> sendVerificationEmail() async
```

#### Password Reset
```dart
Future<({bool success, String? message})> forgotPassword(String email) async
Future<({bool success, String? message})> resetPassword(...) async
```

### State Management

The service uses `ChangeNotifier` to notify UI components of state changes:

```dart
void _setLoading(bool loading) {
  _isLoading = loading;
  notifyListeners(); // Notifies listening widgets
}
```

### Error Handling

All methods return a record with:
- `success`: Boolean indicating operation success
- `message`: Optional error or success message

### Global Instance

```dart
final authService = AuthService();
```

Used throughout the app for authentication operations.

### Usage Examples

#### 3-Step Registration Flow
```dart
// Step 1: Register Super Admin
final request = SuperAdminRegisterRequest(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
);
final result = await authService.registerSuperAdmin(request);

if (result.success) {
  // Navigate to organization creation
  context.go('/create-organization');
}

// Step 2: Create Organization
final orgRequest = CreateOrganizationRequest(
  name: 'ACME Corp',
  code: 'ACME',
  description: 'Software company',
  role: 'Super Admin',
  email: authService.tempEmail!,
  password: authService.tempPassword!,
);
final orgResult = await authService.createOrganization(orgRequest);

if (orgResult.success) {
  // Navigate to dashboard - now fully authenticated
  context.go('/payment-notes');
}
```

#### Login Flow
```dart
final loginRequest = LoginRequest(
  email: 'john@example.com',
  password: 'password123',
);
final result = await authService.login(loginRequest);

if (result.success) {
  // User is now authenticated with tenant_id
  context.go('/payment-notes');
}
```

#### State Listening
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return CircularProgressIndicator();
        }
        
        if (authService.isAuthenticated) {
          return DashboardWidget();
        }
        
        return LoginWidget();
      },
    );
  }
}
```

### Integration with Router

The service works with GoRouter for automatic navigation based on authentication state:

```dart
// Router checks authentication status
final isLoggedIn = await JwtTokenManager.isAuthenticated();
final tenantId = await JwtTokenManager.getTenantId();

// Redirects based on authentication state
if (!isLoggedIn) return '/login';
if (isLoggedIn && tenantId == null) return '/create-organization';
```
