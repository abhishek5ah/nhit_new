# Quick Reference Guide

## Essential Commands

### Development

```bash
# Get dependencies
flutter pub get

# Run application (Windows)
flutter run -d windows

# Run application (Web)
flutter run -d chrome

# Run application (Android)
flutter run -d <device-id>

# Hot reload
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Clean build
flutter clean
flutter pub get
```

### Build Commands

```bash
# Windows Release
flutter build windows --release

# Web Release
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

### Code Generation

```bash
# Run build runner
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## API Endpoints Quick Reference

### Base URL
```
http://192.168.1.51:8083/api/v1
```

### Authentication

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /auth/login | User login |
| POST | /auth/logout | User logout |
| POST | /auth/refresh | Refresh token |
| POST | /tenants | Create tenant |
| POST | /organizations | Create organization |

### Organizations

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /tenants/{tenantId}/organizations | Get all organizations |
| GET | /organizations/{parentOrgId}/children | Get child organizations |
| GET | /organizations/code/{code} | Get by code |
| POST | /organizations | Create organization |
| PUT | /organizations/{orgId} | Update organization |
| DELETE | /organizations/{orgId} | Delete organization |

### Departments

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /departments/organization/{orgId} | Get departments |
| POST | /departments | Create department |
| PUT | /departments/{id} | Update department |
| DELETE | /departments/{id} | Delete department |

### Designations

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /designations/department/{deptId} | Get designations |
| POST | /designations | Create designation |
| PUT | /designations/{id} | Update designation |
| DELETE | /designations/{id} | Delete designation |

### Vendors

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /vendors/organization/{orgId} | Get vendors |
| POST | /vendors | Create vendor |
| PUT | /vendors/{id} | Update vendor |
| DELETE | /vendors/{id} | Delete vendor |

### Roles & Permissions

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /roles | Get all roles |
| GET | /permissions | Get all permissions |
| POST | /roles | Create role |
| PUT | /roles/{roleId} | Update role |
| DELETE | /roles/{roleId} | Delete role |

---

## Common Code Snippets

### 1. API Call with Error Handling

```dart
Future<void> loadData() async {
  try {
    final response = await _repository.getData();
    
    if (response.success && response.data != null) {
      _data = response.data!;
      notifyListeners();
    } else {
      _error = response.message ?? 'Failed to load data';
      notifyListeners();
    }
  } catch (e) {
    _error = 'Error: $e';
    notifyListeners();
  }
}
```

### 2. Provider Setup

```dart
// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => VendorApiService()),
  ],
  child: MyApp(),
)

// In widget
Consumer<VendorApiService>(
  builder: (context, service, child) {
    if (service.isLoading) return CircularProgressIndicator();
    return ListView(children: service.vendors.map(...));
  },
)
```

### 3. Navigation

```dart
// Navigate to route
context.go('/vendors');

// Navigate with parameters
context.go('/vendors/${vendor.id}');

// Go back
context.pop();

// Replace current route
context.replace('/login');
```

### 4. Form Validation

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field is required';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Process form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

### 5. Secure Storage

```dart
// Save token
await JwtTokenManager.saveTokens(accessToken, refreshToken);

// Get token
final token = await JwtTokenManager.getAccessToken();

// Clear tokens
await JwtTokenManager.clearTokens();

// Save user data
await JwtTokenManager.saveUserData({
  'userId': userId,
  'email': email,
  'name': name,
});
```

### 6. Show Dialog

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          // Perform action
        },
        child: Text('Confirm'),
      ),
    ],
  ),
);
```

### 7. Show Snackbar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Operation successful'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);
```

---

## File Locations

### Core Files

| File | Location |
|------|----------|
| API Constants | `lib/core/constants/api_constants.dart` |
| JWT Manager | `lib/core/services/jwt_token_manager.dart` |
| API Service | `lib/core/services/api_service.dart` |
| Router | `lib/app/router.dart` |
| Main | `lib/main.dart` |

### Feature Files

| Feature | Location |
|---------|----------|
| Auth | `lib/features/auth/` |
| Organizations | `lib/features/organization/` |
| Departments | `lib/features/department/` |
| Designations | `lib/features/designation/` |
| Vendors | `lib/features/vendor/` |
| Roles | `lib/features/roles/` |

---

## Environment Variables

### Development

```dart
// lib/core/constants/api_constants.dart
static const String authBaseUrl = 'http://192.168.1.51:8083/api/v1';
```

### Production

```dart
// lib/core/constants/api_constants.dart
static const String authBaseUrl = 'https://api.production.com/api/v1';
```

---

## Troubleshooting

### Common Issues

#### 1. Build Errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### 2. Dependency Conflicts

```bash
# Update dependencies
flutter pub upgrade

# Get specific version
flutter pub add package_name:^version
```

#### 3. Token Expired

```dart
// Check token validity
final isExpired = await JwtTokenManager.isTokenExpired();

// Refresh token
final refreshToken = await JwtTokenManager.getRefreshToken();
// Call refresh endpoint
```

#### 4. API Connection Issues

```dart
// Check network connectivity
// Verify API base URL
// Check authentication headers
// Review API logs
```

---

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/features/auth/auth_service_test.dart

# With coverage
flutter test --coverage
```

### Test Structure

```dart
void main() {
  group('AuthService Tests', () {
    test('Login with valid credentials', () async {
      // Arrange
      final authService = AuthService();
      
      // Act
      final result = await authService.login('user@test.com', 'password', 'tenant-id');
      
      // Assert
      expect(result.success, true);
    });
  });
}
```

---

## Performance Tips

1. **Use const constructors** where possible
2. **Implement lazy loading** for large lists
3. **Cache API responses** appropriately
4. **Use Provider selectively** to avoid unnecessary rebuilds
5. **Optimize images** and assets
6. **Implement pagination** for large datasets
7. **Use ListView.builder** instead of ListView for long lists

---

## Security Checklist

- ✅ Use HTTPS in production
- ✅ Store tokens in secure storage
- ✅ Implement token refresh
- ✅ Validate all user inputs
- ✅ Implement proper error handling
- ✅ Use role-based access control
- ✅ Log security events
- ✅ Implement rate limiting
- ✅ Sanitize user inputs
- ✅ Use environment variables for secrets

---

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/vendor-management

# Stage changes
git add .

# Commit
git commit -m "feat: implement vendor creation"

# Push to remote
git push origin feature/vendor-management

# Create pull request
# Review and merge
```

---

## Useful Links

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Dio Package](https://pub.dev/packages/dio)

---

**Last Updated:** December 2025  
**Version:** 1.0.0
