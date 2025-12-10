# Authentication System Documentation

## Overview
The NHIT ERP system implements a comprehensive JWT-based authentication system with multi-tenant support, role-based access control, and secure token management.

---

## Table of Contents
1. [Architecture](#architecture)
2. [Authentication Flow](#authentication-flow)
3. [API Endpoints](#api-endpoints)
4. [Implementation Details](#implementation-details)
5. [Security Features](#security-features)
6. [Usage Examples](#usage-examples)

---

## Architecture

### Components

#### 1. JWT Token Manager (`lib/core/services/jwt_token_manager.dart`)
**Purpose:** Secure storage and management of JWT tokens

**Key Features:**
- Secure token storage using `flutter_secure_storage`
- Automatic token expiration validation
- Token refresh mechanism
- Tenant and organization context management

**Stored Data:**
```dart
- accessToken: JWT access token
- refreshToken: JWT refresh token
- userId: User identifier
- email: User email
- name: User full name
- tenantId: Tenant identifier
- orgId: Organization identifier
- roles: User roles array
- permissions: User permissions array
- tokenExpiresAt: Token expiration timestamp
- refreshExpiresAt: Refresh token expiration
```

**Methods:**
```dart
// Token Management
Future<void> saveTokens(String accessToken, String refreshToken)
Future<String?> getAccessToken()
Future<String?> getRefreshToken()
Future<void> clearTokens()

// User Data
Future<void> saveUserData(Map<String, dynamic> userData)
Future<String?> getUserId()
Future<String?> getEmail()
Future<String?> getName()

// Tenant & Organization
Future<void> saveTenantId(String tenantId)
Future<String?> getTenantId()
Future<void> saveOrgId(String orgId)
Future<String?> getOrgId()

// Validation
Future<bool> isTokenExpired()
Future<bool> hasValidToken()
```

---

#### 2. Auth Service (`lib/features/auth/services/auth_service.dart`)
**Purpose:** Business logic for authentication operations

**State Management:** ChangeNotifier pattern

**Key Features:**
- Login/Logout operations
- User session management
- Role-based access control
- Authentication state tracking

**Properties:**
```dart
bool isAuthenticated      // Current auth status
bool isLoading           // Loading state
String? error            // Error messages
UserModel? currentUser   // Current user data
```

**Methods:**
```dart
// Authentication
Future<ApiResponse> login(String email, String password, String tenantId)
Future<void> logout()
Future<bool> isAuthenticated()

// Role Management
bool isSuperAdmin()
bool hasRole(String role)
bool hasPermission(String permission)

// Session
Future<void> loadUserSession()
Future<void> clearAuthData()
```

---

#### 3. Auth Repository (`lib/features/auth/data/repositories/auth_repository.dart`)
**Purpose:** API communication layer

**Endpoints Handled:**
- POST /auth/login
- POST /auth/logout
- POST /auth/refresh
- POST /tenants (registration)
- POST /organizations (organization creation)

**Methods:**
```dart
Future<ApiResponse<LoginResponse>> login(LoginRequest request)
Future<ApiResponse> logout()
Future<ApiResponse<LoginResponse>> refreshToken(String refreshToken)
Future<ApiResponse<TenantResponse>> createTenant(TenantRequest request)
Future<ApiResponse<OrganizationResponse>> createOrganization(OrganizationRequest request)
```

---

## Authentication Flow

### 1. Registration Flow
```
User Registration
    ↓
Create Tenant
    ↓
Receive tenantId
    ↓
Create Organization
    ↓
Super Admin Account Created
    ↓
Login with Credentials
```

**Step-by-Step:**

1. **Create Tenant**
   - Endpoint: `POST /tenants`
   - Request:
   ```json
   {
     "name": "John Doe",
     "email": "john@example.com",
     "password": "SecurePass123!"
   }
   ```
   - Response:
   ```json
   {
     "tenantId": "uuid-v4",
     "name": "John Doe",
     "email": "john@example.com"
   }
   ```

2. **Create Organization**
   - Endpoint: `POST /organizations`
   - Request:
   ```json
   {
     "tenantId": "uuid-v4",
     "name": "ACME Corp",
     "code": "ACME01",
     "description": "Main organization",
     "super_admin": {
       "name": "John Doe",
       "email": "john@example.com",
       "password": "SecurePass123!"
     },
     "initial_projects": ["Project Alpha"]
   }
   ```
   - Response:
   ```json
   {
     "orgId": "uuid-v4",
     "tenantId": "uuid-v4",
     "name": "ACME Corp",
     "code": "ACME01",
     "superAdmin": {
       "userId": "uuid-v4",
       "name": "John Doe",
       "email": "john@example.com",
       "role": "superadmin"
     }
   }
   ```

---

### 2. Login Flow
```
Enter Credentials
    ↓
POST /auth/login
    ↓
Receive JWT Tokens
    ↓
Store Tokens Securely
    ↓
Extract User Data
    ↓
Save to Secure Storage
    ↓
Navigate to Dashboard
```

**Login Request:**
```json
{
  "tenant_id": "uuid-v4",
  "login": "john@example.com",
  "password": "SecurePass123!"
}
```

**Login Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userId": "uuid-v4",
  "email": "john@example.com",
  "name": "John Doe",
  "roles": ["superadmin"],
  "permissions": ["*"],
  "tenantId": "uuid-v4",
  "orgId": "uuid-v4",
  "tokenExpiresAt": "2025-12-10T15:30:00Z",
  "refreshExpiresAt": "2025-12-17T10:00:00Z",
  "lastLoginAt": "2025-12-10T10:00:00Z",
  "lastLoginIp": "192.168.1.100"
}
```

---

### 3. Token Refresh Flow
```
Token Expires Soon
    ↓
Check Expiration (5 min before)
    ↓
POST /auth/refresh
    ↓
Receive New Tokens
    ↓
Update Stored Tokens
    ↓
Continue Session
```

**Refresh Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 4. Logout Flow
```
User Clicks Logout
    ↓
Confirm Action
    ↓
POST /auth/logout
    ↓
Clear Local Tokens
    ↓
Clear User Data
    ↓
Navigate to Login
```

---

## API Endpoints

### Base URL
```
http://192.168.1.51:8083/api/v1
```

### Endpoints

#### 1. Login
- **Endpoint:** `POST /auth/login`
- **Authentication:** None (public)
- **Request Body:**
```json
{
  "tenant_id": "string (required)",
  "login": "string (email, required)",
  "password": "string (required)"
}
```
- **Response (200 OK):**
```json
{
  "token": "string",
  "refreshToken": "string",
  "userId": "string",
  "email": "string",
  "name": "string",
  "roles": ["string"],
  "permissions": ["string"],
  "tenantId": "string",
  "orgId": "string",
  "tokenExpiresAt": "ISO8601 datetime",
  "refreshExpiresAt": "ISO8601 datetime",
  "lastLoginAt": "ISO8601 datetime",
  "lastLoginIp": "string"
}
```
- **Error Responses:**
  - 400: Invalid credentials
  - 401: Unauthorized
  - 404: User not found

---

#### 2. Logout
- **Endpoint:** `POST /auth/logout`
- **Authentication:** Bearer Token
- **Headers:**
```
Authorization: Bearer <access_token>
```
- **Response (200 OK):**
```json
{
  "message": "Logged out successfully"
}
```

---

#### 3. Refresh Token
- **Endpoint:** `POST /auth/refresh`
- **Authentication:** None
- **Request Body:**
```json
{
  "refreshToken": "string (required)"
}
```
- **Response (200 OK):**
```json
{
  "token": "string",
  "refreshToken": "string",
  "tokenExpiresAt": "ISO8601 datetime",
  "refreshExpiresAt": "ISO8601 datetime"
}
```

---

#### 4. Create Tenant
- **Endpoint:** `POST /tenants`
- **Authentication:** None (public registration)
- **Request Body:**
```json
{
  "name": "string (required)",
  "email": "string (required, valid email)",
  "password": "string (required, min 8 chars)"
}
```
- **Response (201 Created):**
```json
{
  "tenantId": "string",
  "name": "string",
  "email": "string"
}
```

---

#### 5. Create Organization
- **Endpoint:** `POST /organizations`
- **Authentication:** None (during registration)
- **Request Body:**
```json
{
  "tenantId": "string (required)",
  "parentOrgId": "string (optional, for child orgs)",
  "name": "string (required)",
  "code": "string (required, unique)",
  "description": "string (optional)",
  "super_admin": {
    "name": "string (required)",
    "email": "string (required)",
    "password": "string (optional, empty for child orgs)"
  },
  "initial_projects": ["string"],
  "createdBy": "string (optional)"
}
```
- **Response (201 Created):**
```json
{
  "orgId": "string",
  "tenantId": "string",
  "parentOrgId": "string",
  "name": "string",
  "code": "string",
  "description": "string",
  "superAdmin": {
    "userId": "string",
    "name": "string",
    "email": "string"
  },
  "createdAt": "ISO8601 datetime",
  "updatedAt": "ISO8601 datetime"
}
```

---

## Implementation Details

### 1. Login Implementation

**File:** `lib/features/auth/services/auth_service.dart`

```dart
Future<ApiResponse> login(String email, String password, String tenantId) async {
  setLoading(true);
  setError(null);

  try {
    // Create login request
    final request = LoginRequest(
      tenantId: tenantId,
      login: email,
      password: password,
    );

    // Call API
    final response = await _repository.login(request);

    if (response.success && response.data != null) {
      final loginData = response.data!;

      // Save JWT tokens
      await JwtTokenManager.saveTokens(
        loginData.token,
        loginData.refreshToken,
      );

      // Save user data
      await JwtTokenManager.saveUserData({
        'userId': loginData.userId,
        'email': loginData.email,
        'name': loginData.name,
        'tenantId': loginData.tenantId,
        'orgId': loginData.orgId,
        'roles': loginData.roles,
        'permissions': loginData.permissions,
      });

      // Update current user
      _currentUser = UserModel(
        userId: loginData.userId,
        email: loginData.email,
        name: loginData.name,
        roles: loginData.roles,
        permissions: loginData.permissions,
      );

      setLoading(false);
      notifyListeners();

      return ApiResponse.success(message: 'Login successful');
    } else {
      setError(response.message ?? 'Login failed');
      setLoading(false);
      return ApiResponse.error(message: response.message ?? 'Login failed');
    }
  } catch (e) {
    setError('Login error: $e');
    setLoading(false);
    return ApiResponse.error(message: 'Login error: $e');
  }
}
```

---

### 2. Route Protection

**File:** `lib/app/router.dart`

```dart
final router = GoRouter(
  refreshListenable: AuthNotifier(authService),
  redirect: (context, state) async {
    final authService = context.read<AuthService>();
    final isAuthenticated = await authService.isAuthenticated();
    final isAuthRoute = ['/login', '/tenants', '/create-organization'].contains(state.matchedLocation);

    // Redirect to login if not authenticated
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // Redirect to dashboard if authenticated and trying to access auth routes
    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }

    return null; // No redirect needed
  },
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    
    // Protected routes
    ShellRoute(
      builder: (context, state, child) => LayoutPage(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (context, state) => DashboardPage()),
        // ... other protected routes
      ],
    ),
  ],
);
```

---

### 3. Auto Token Refresh

**File:** `lib/core/services/api_service.dart`

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Check token expiration
    final isExpired = await JwtTokenManager.isTokenExpired();
    
    if (isExpired) {
      // Refresh token
      final refreshToken = await JwtTokenManager.getRefreshToken();
      if (refreshToken != null) {
        // Call refresh endpoint
        final response = await _refreshToken(refreshToken);
        if (response.success) {
          // Update tokens
          await JwtTokenManager.saveTokens(
            response.data.token,
            response.data.refreshToken,
          );
        }
      }
    }

    // Add authorization header
    final token = await JwtTokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add tenant header
    final tenantId = await JwtTokenManager.getTenantId();
    if (tenantId != null) {
      options.headers['tenant_id'] = tenantId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try refresh
      final refreshToken = await JwtTokenManager.getRefreshToken();
      if (refreshToken != null) {
        final response = await _refreshToken(refreshToken);
        if (response.success) {
          // Retry original request
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer ${response.data.token}';
          final retryResponse = await Dio().fetch(options);
          return handler.resolve(retryResponse);
        }
      }
      
      // Refresh failed, logout
      await JwtTokenManager.clearTokens();
      // Navigate to login
    }

    handler.next(err);
  }
}
```

---

## Security Features

### 1. Secure Token Storage
- Uses `flutter_secure_storage` for encrypted storage
- Tokens never stored in plain text
- Automatic cleanup on logout

### 2. Token Expiration
- Access tokens expire after configured duration
- Refresh tokens have longer expiration
- Automatic refresh 5 minutes before expiration

### 3. Multi-Tenant Isolation
- Tenant ID required for all operations
- Automatic tenant header injection
- Tenant-specific data access

### 4. Role-Based Access Control (RBAC)
```dart
// Check if user is super admin
if (authService.isSuperAdmin()) {
  // Show admin features
}

// Check specific role
if (authService.hasRole('manager')) {
  // Show manager features
}

// Check permission
if (authService.hasPermission('create-vendor')) {
  // Allow vendor creation
}
```

### 5. Password Requirements
- Minimum 8 characters
- Must contain uppercase, lowercase, number, special character
- Validated on both client and server

---

## Usage Examples

### 1. Login Page Implementation

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tenantIdController = TextEditingController();

  Future<void> _handleLogin() async {
    final authService = context.read<AuthService>();
    
    final result = await authService.login(
      _emailController.text,
      _passwordController.text,
      _tenantIdController.text,
    );

    if (result.success) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Form(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: _tenantIdController,
                  decoration: InputDecoration(labelText: 'Tenant ID'),
                ),
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text('Login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

---

### 2. Protected Route Example

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Text('Welcome, ${authService.currentUser?.name}'),
          if (authService.isSuperAdmin())
            ElevatedButton(
              onPressed: () => context.go('/admin'),
              child: Text('Admin Panel'),
            ),
        ],
      ),
    );
  }
}
```

---

## Troubleshooting

### Common Issues

#### 1. Token Expired Error
**Symptom:** 401 Unauthorized responses  
**Solution:** Check token expiration, implement auto-refresh

#### 2. Tenant ID Missing
**Symptom:** 400 Bad Request  
**Solution:** Ensure tenant ID is saved and sent with requests

#### 3. Login Fails After Logout
**Symptom:** Cannot login after logout  
**Solution:** Clear all stored data properly in logout method

---

## Best Practices

1. **Always validate tokens before API calls**
2. **Implement proper error handling**
3. **Use secure storage for sensitive data**
4. **Implement token refresh before expiration**
5. **Clear all auth data on logout**
6. **Validate user permissions before showing features**
7. **Use HTTPS in production**
8. **Implement rate limiting on login attempts**

---

**Last Updated:** December 2025  
**Version:** 1.0.0
