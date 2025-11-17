# JWT Token Manager Documentation

## File: `lib/core/services/jwt_token_manager.dart`

### Purpose
Secure management of JWT tokens, user data, and tenant information using Flutter Secure Storage.

### Key Features

1. **Secure Storage**: Uses `flutter_secure_storage` with encryption
2. **Token Management**: Handles access tokens, refresh tokens, and tenant IDs
3. **JWT Validation**: Checks token expiration and validity
4. **Auto-refresh Logic**: Determines when tokens need refreshing

### Storage Keys

```dart
static const String _accessTokenKey = 'access_token';
static const String _refreshTokenKey = 'refresh_token';
static const String _userIdKey = 'user_id';
static const String _emailKey = 'email';
static const String _emailVerifiedKey = 'email_verified';
static const String _tenantIdKey = 'tenant_id';
```

### Core Methods

#### Save Tokens
```dart
static Future<void> saveTokens({
  required String accessToken,
  required String refreshToken,
  required String userId,
  required String email,
  required bool emailVerified,
  String? tenantId,
}) async
```

**Usage**: Store authentication data after successful login/registration.

#### Get Methods
```dart
static Future<String?> getAccessToken() async
static Future<String?> getRefreshToken() async
static Future<String?> getTenantId() async
static Future<String?> getUserId() async
static Future<String?> getEmail() async
static Future<bool> isEmailVerified() async
```

**Usage**: Retrieve stored authentication data.

#### Token Validation
```dart
static Future<bool> isAuthenticated() async
static Future<bool> isAccessTokenExpired() async
static Future<bool> willExpireSoon() async
```

**Usage**: Check authentication status and token validity.

#### Tenant Management
```dart
static Future<void> saveTenantId(String tenantId) async
static Future<String?> getTenantId() async
```

**Usage**: Manage tenant ID for multi-tenant applications.

#### Clear Data
```dart
static Future<void> clearTokens() async
```

**Usage**: Remove all stored authentication data during logout.

### Security Configuration

```dart
static const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  ),
);
```

### JWT Processing

The manager uses `jwt_decoder` package to:
- Parse JWT tokens
- Extract payload data
- Check expiration dates
- Validate token structure

### Auto-Refresh Logic

```dart
static Future<bool> willExpireSoon() async {
  // Returns true if token expires within 5 minutes
  return timeUntilExpiry.inMinutes <= 5;
}
```

### Error Handling

All methods include try-catch blocks to handle:
- Storage access errors
- JWT parsing errors
- Invalid token formats
- Platform-specific storage issues

### Usage Examples

#### Complete Authentication Flow
```dart
// After successful login
await JwtTokenManager.saveTokens(
  accessToken: response.accessToken,
  refreshToken: response.refreshToken,
  userId: response.user.id,
  email: response.user.email,
  emailVerified: response.user.emailVerified,
  tenantId: response.tenantId,
);

// Check authentication status
final isAuth = await JwtTokenManager.isAuthenticated();

// Get current user data
final userId = await JwtTokenManager.getUserId();
final email = await JwtTokenManager.getEmail();

// Logout
await JwtTokenManager.clearTokens();
```

### Platform Considerations

- **Android**: Uses encrypted shared preferences
- **iOS**: Uses Keychain with device unlock requirement
- **Web**: Uses secure browser storage
- **Desktop**: Uses platform-specific secure storage
