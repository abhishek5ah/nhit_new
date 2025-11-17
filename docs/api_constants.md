# API Constants Documentation

## File: `lib/core/constants/api_constants.dart`

### Purpose
Centralized configuration for all API endpoints and network settings used in the authentication system.

### Configuration

```dart
class ApiConstants {
  // Base URLs
  static const String authBaseUrl = 'http://localhost:8051/api/v1';
  static const String mainBaseUrl = 'http://localhost:8083/api/v1';
  
  // Auth Endpoints (Port 8051)
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  // ... other auth endpoints
  
  // Organization Endpoints (Port 8083)
  static const String createOrganization = '/organizations';
  
  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Key Features

1. **Dual Service Architecture**:
   - Auth service on port 8051 for authentication operations
   - Main service on port 8083 for business operations (organizations)

2. **Endpoint Management**:
   - All API paths centrally defined
   - Easy to maintain and update

3. **Network Configuration**:
   - Configurable timeouts for connection and data reception
   - 30-second default timeout for both operations

### Usage

```dart
// In API Service
final authDio = Dio(BaseOptions(
  baseUrl: ApiConstants.authBaseUrl,
  connectTimeout: ApiConstants.connectionTimeout,
));

// In Repository
await _apiService.post(
  ApiConstants.register,
  data: requestData,
  useAuthService: true,
);
```

### Environment Configuration

For different environments (dev, staging, prod), update the base URLs:

```dart
// Development
static const String authBaseUrl = 'http://localhost:8051/api/v1';

// Staging
static const String authBaseUrl = 'https://staging-auth.yourapp.com/api/v1';

// Production
static const String authBaseUrl = 'https://auth.yourapp.com/api/v1';
```

### Security Considerations

1. **HTTPS in Production**: Always use HTTPS for production endpoints
2. **Environment Variables**: Consider using environment variables for sensitive URLs
3. **API Versioning**: Version is included in the path (`/api/v1`) for API evolution
