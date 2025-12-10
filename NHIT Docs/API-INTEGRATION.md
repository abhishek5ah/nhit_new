# API Integration Guide

## Overview
Complete API integration documentation for NHIT ERP System covering all microservices, endpoints, request/response formats, and implementation patterns.

---

## Table of Contents
1. [API Architecture](#api-architecture)
2. [Authentication & Authorization](#authentication--authorization)
3. [Service Endpoints](#service-endpoints)
4. [Request/Response Patterns](#requestresponse-patterns)
5. [Error Handling](#error-handling)
6. [Implementation Examples](#implementation-examples)

---

## API Architecture

### Base Configuration

**Production URL:**
```
http://192.168.1.51:8083/api/v1
```

**Android Emulator URL:**
```
http://10.0.2.2:8083/api/v1
```

### Microservices Architecture

| Service | Port | Base Path | Purpose |
|---------|------|-----------|---------|
| Auth Service | 8051 | /auth | Authentication & authorization |
| User Service | 8052 | /users, /tenants | User management |
| Organization Service | 8053 | /organizations | Organization CRUD |
| Department Service | 8054 | /departments | Department management |
| Designation Service | 8055 | /designations | Designation management |
| Vendor Service | 8056 | /vendors | Vendor management |

### HTTP Client Configuration

**File:** `lib/core/services/api_service.dart`

```dart
class ApiService {
  static final Map<String, Dio> _dioInstances = {};

  static Dio getDioInstance(String service) {
    if (!_dioInstances.containsKey(service)) {
      final dio = Dio(BaseOptions(
        baseUrl: _getBaseUrl(service),
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Add interceptors
      dio.interceptors.add(AuthInterceptor());
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));

      _dioInstances[service] = dio;
    }

    return _dioInstances[service]!;
  }

  static String _getBaseUrl(String service) {
    switch (service) {
      case 'auth':
        return ApiConstants.authBaseUrl;
      case 'user':
        return ApiConstants.userBaseUrl;
      case 'organization':
        return ApiConstants.organizationBaseUrl;
      case 'department':
        return ApiConstants.departmentBaseUrl;
      case 'designation':
        return ApiConstants.designationBaseUrl;
      case 'vendor':
        return ApiConstants.vendorBaseUrl;
      default:
        return ApiConstants.baseUrl;
    }
  }
}
```

---

## Authentication & Authorization

### Headers

**All Authenticated Requests:**
```http
Authorization: Bearer <access_token>
Content-Type: application/json
tenant_id: <tenant_id>
```

### Auth Interceptor

**File:** `lib/core/services/api_service.dart`

```dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add authorization token
    final token = await JwtTokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add tenant ID header
    final tenantId = await JwtTokenManager.getTenantId();
    if (tenantId != null && tenantId.isNotEmpty) {
      options.headers['tenant_id'] = tenantId;
    }

    // Add organization ID if available
    final orgId = await JwtTokenManager.getOrgId();
    if (orgId != null && orgId.isNotEmpty) {
      options.headers['org_id'] = orgId;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try refresh
      final refreshToken = await JwtTokenManager.getRefreshToken();
      if (refreshToken != null) {
        // Attempt token refresh
        // If successful, retry original request
        // If failed, logout and redirect to login
      }
    }

    handler.next(err);
  }
}
```

---

## Service Endpoints

### 1. Authentication Service

**Base Path:** `/auth`

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "tenant_id": "uuid",
  "login": "user@example.com",
  "password": "password123"
}

Response 200:
{
  "token": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "userId": "uuid",
  "email": "user@example.com",
  "name": "John Doe",
  "roles": ["superadmin"],
  "permissions": ["*"],
  "tenantId": "uuid",
  "orgId": "uuid",
  "tokenExpiresAt": "2025-12-10T15:00:00Z",
  "refreshExpiresAt": "2025-12-17T10:00:00Z"
}
```

#### Logout
```http
POST /auth/logout
Authorization: Bearer <token>

Response 200:
{
  "message": "Logged out successfully"
}
```

#### Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}

Response 200:
{
  "token": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "tokenExpiresAt": "2025-12-10T16:00:00Z"
}
```

---

### 2. Tenant Service

**Base Path:** `/tenants`

#### Create Tenant
```http
POST /tenants
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response 201:
{
  "tenantId": "uuid",
  "name": "John Doe",
  "email": "john@example.com"
}
```

#### Get Tenant Organizations
```http
GET /tenants/{tenantId}/organizations
Authorization: Bearer <token>
tenant_id: <tenantId>

Response 200:
{
  "organizations": [
    {
      "orgId": "uuid",
      "tenantId": "uuid",
      "name": "ACME Corp",
      "code": "ACME01",
      "isActive": true,
      "status": "activated"
    }
  ],
  "totalCount": 1
}
```

---

### 3. Organization Service

**Base Path:** `/organizations`

#### Create Organization
```http
POST /organizations
Authorization: Bearer <token>
Content-Type: application/json

{
  "tenantId": "uuid",
  "parentOrgId": "uuid",  // Optional
  "name": "ACME Corp",
  "code": "ACME01",
  "description": "Main organization",
  "super_admin": {
    "name": "John Doe",
    "email": "john@acme.com",
    "password": "SecurePass123!"  // Empty for child orgs
  },
  "initial_projects": ["Project Alpha"],
  "createdBy": "John Doe"
}

Response 201:
{
  "orgId": "uuid",
  "tenantId": "uuid",
  "name": "ACME Corp",
  "code": "ACME01",
  "superAdmin": {
    "userId": "uuid",
    "name": "John Doe",
    "email": "john@acme.com"
  },
  "createdAt": "2025-01-01T10:00:00Z"
}
```

#### Update Organization
```http
PUT /organizations/{orgId}
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "ACME Corporation",
  "description": "Updated description",
  "status": "activated"
}

Response 200:
{
  "orgId": "uuid",
  "name": "ACME Corporation",
  "updatedAt": "2025-01-02T10:00:00Z"
}
```

#### Get Child Organizations
```http
GET /organizations/{parentOrgId}/children
Authorization: Bearer <token>

Response 200:
{
  "organizations": [
    {
      "orgId": "uuid",
      "parentOrgId": "uuid",
      "name": "ACME - Sales",
      "code": "ACME-SALES01"
    }
  ]
}
```

#### Get Organization by Code
```http
GET /organizations/code/{code}
Authorization: Bearer <token>

Response 200:
{
  "orgId": "uuid",
  "name": "ACME Corp",
  "code": "ACME01",
  "isActive": true
}
```

---

### 4. Department Service

**Base Path:** `/departments`

#### Get Departments by Organization
```http
GET /departments/organization/{orgId}
Authorization: Bearer <token>
tenant_id: <tenantId>

Response 200:
{
  "departments": [
    {
      "id": 1,
      "orgId": "uuid",
      "name": "Engineering",
      "code": "ENG01",
      "description": "Engineering department",
      "isActive": true,
      "createdAt": "2025-01-01T10:00:00Z"
    }
  ]
}
```

#### Create Department
```http
POST /departments
Authorization: Bearer <token>
Content-Type: application/json

{
  "orgId": "uuid",
  "name": "Engineering",
  "code": "ENG01",
  "description": "Engineering department"
}

Response 201:
{
  "id": 1,
  "orgId": "uuid",
  "name": "Engineering",
  "code": "ENG01",
  "isActive": true
}
```

#### Update Department
```http
PUT /departments/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Engineering & Tech",
  "description": "Updated description",
  "isActive": true
}

Response 200:
{
  "id": 1,
  "name": "Engineering & Tech",
  "updatedAt": "2025-01-02T10:00:00Z"
}
```

#### Delete Department
```http
DELETE /departments/{id}
Authorization: Bearer <token>

Response 200:
{
  "message": "Department deleted successfully"
}
```

---

### 5. Designation Service

**Base Path:** `/designations`

#### Get Designations by Department
```http
GET /designations/department/{departmentId}
Authorization: Bearer <token>

Response 200:
{
  "designations": [
    {
      "id": 1,
      "departmentId": 1,
      "name": "Senior Engineer",
      "code": "SE01",
      "description": "Senior engineering role",
      "isActive": true
    }
  ]
}
```

#### Create Designation
```http
POST /designations
Authorization: Bearer <token>
Content-Type: application/json

{
  "departmentId": 1,
  "name": "Senior Engineer",
  "code": "SE01",
  "description": "Senior engineering role"
}

Response 201:
{
  "id": 1,
  "departmentId": 1,
  "name": "Senior Engineer",
  "code": "SE01"
}
```

---

### 6. Vendor Service

**Base Path:** `/vendors`

#### Get Vendors by Organization
```http
GET /vendors/organization/{orgId}
Authorization: Bearer <token>

Response 200:
{
  "vendors": [
    {
      "id": 1,
      "vendorCode": "VEN001",
      "name": "ABC Suppliers",
      "email": "contact@abc.com",
      "phone": "1234567890",
      "status": "ACTIVE",
      "accounts": [
        {
          "accountNumber": "1234567890",
          "bankName": "State Bank",
          "ifscCode": "SBIN0001234",
          "isPrimary": true
        }
      ]
    }
  ]
}
```

#### Create Vendor
```http
POST /vendors
Authorization: Bearer <token>
Content-Type: application/json

{
  "vendor": {
    "vendorCode": "VEN001",
    "name": "ABC Suppliers",
    "contactPerson": "John Doe",
    "email": "contact@abc.com",
    "phone": "1234567890",
    "address": {
      "street": "123 Main St",
      "city": "Mumbai",
      "state": "Maharashtra",
      "postalCode": "400001",
      "country": "India"
    },
    "gstNumber": "27AABCU9603R1ZM",
    "panNumber": "AABCU9603R",
    "msmeRegistered": true,
    "msmeNumber": "MSME123456",
    "vendorType": "SUPPLIER",
    "paymentTerms": "Net 30",
    "creditLimit": 100000.00,
    "status": "ACTIVE",
    "accounts": [
      {
        "accountHolderName": "ABC Suppliers",
        "bankName": "State Bank",
        "branchName": "Mumbai Branch",
        "accountNumber": "1234567890",
        "ifscCode": "SBIN0001234",
        "accountType": "CURRENT",
        "isPrimary": true,
        "isActive": true
      }
    ]
  }
}

Response 201:
{
  "vendor": {
    "id": 1,
    "vendorCode": "VEN001",
    "name": "ABC Suppliers",
    "status": "ACTIVE",
    "createdAt": "2025-01-01T10:00:00Z"
  }
}
```

---

### 7. Role & Permission Service

**Base Path:** `/roles`, `/permissions`

#### Get All Roles
```http
GET /roles
Authorization: Bearer <token>

Response 200:
{
  "roles": [
    {
      "roleId": "uuid",
      "name": "MANAGER",
      "permissions": ["view-department", "edit-department"],
      "createdAt": "2025-01-01T10:00:00Z"
    }
  ]
}
```

#### Get All Permissions
```http
GET /permissions
Authorization: Bearer <token>

Response 200:
{
  "permissions": [
    {
      "permissionId": "uuid",
      "name": "view-department",
      "description": "View departments",
      "module": "departments",
      "action": "view",
      "isSystemPermission": true
    }
  ]
}
```

#### Create Role
```http
POST /roles
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "MANAGER",
  "permissions": ["view-department", "edit-department", "view-designation"]
}

Response 201:
{
  "roleId": "uuid",
  "name": "MANAGER",
  "permissions": ["view-department", "edit-department", "view-designation"],
  "createdAt": "2025-01-01T10:00:00Z"
}
```

---

## Request/Response Patterns

### Standard Response Format

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error information"
}
```

### API Response Wrapper

**File:** `lib/core/utils/api_response.dart`

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.success({String? message, T? data}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.error({String? message, dynamic error}) {
    return ApiResponse(
      success: false,
      message: message,
      error: error,
    );
  }
}
```

---

## Error Handling

### HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK | Success |
| 201 | Created | Resource created |
| 400 | Bad Request | Validation error |
| 401 | Unauthorized | Token expired/invalid |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate resource |
| 500 | Server Error | Backend error |

### Error Handling Pattern

```dart
try {
  final response = await _dio.post(endpoint, data: requestData);
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    return ApiResponse.success(
      message: 'Success',
      data: parseResponse(response.data),
    );
  } else {
    return ApiResponse.error(
      message: 'Unexpected status: ${response.statusCode}',
    );
  }
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Handle unauthorized
    await handleTokenExpired();
  } else if (e.response?.statusCode == 400) {
    // Handle validation error
    return ApiResponse.error(
      message: e.response?.data['message'] ?? 'Validation error',
    );
  }
  
  return ApiResponse.error(
    message: e.message ?? 'Network error',
  );
} catch (e) {
  return ApiResponse.error(
    message: 'Unexpected error: $e',
  );
}
```

---

## Implementation Examples

### 1. Repository Pattern

```dart
class VendorApiRepository {
  final Dio _dio;

  VendorApiRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.vendorBaseUrl,
          connectTimeout: ApiConstants.connectionTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ));

  Future<void> _addAuthHeader() async {
    final token = await JwtTokenManager.getAccessToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<ApiResponse<VendorApiModel>> createVendor(
      CreateVendorRequest request) async {
    try {
      await _addAuthHeader();

      final response = await _dio.post(
        ApiConstants.vendors,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor created successfully',
          data: vendorResponse.vendor,
        );
      } else {
        return ApiResponse.error(message: 'Failed to create vendor');
      }
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    }
  }
}
```

---

### 2. Service Layer

```dart
class VendorApiService extends ChangeNotifier {
  final VendorApiRepository _repository = VendorApiRepository();
  
  List<VendorApiModel> _vendors = [];
  bool _isLoading = false;
  String? _error;

  List<VendorApiModel> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<({bool success, String? message})> createVendor(
      VendorApiModel vendor) async {
    _setLoading(true);

    try {
      final request = CreateVendorRequest(vendor: vendor);
      final response = await _repository.createVendor(request);

      if (response.success) {
        await loadVendors(forceRefresh: true);
        _setLoading(false);
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      _setError('Error: $e');
      _setLoading(false);
      return (success: false, message: 'Error: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}
```

---

## Best Practices

1. **Always use interceptors** for authentication and logging
2. **Implement proper error handling** for all API calls
3. **Use typed responses** with ApiResponse wrapper
4. **Cache responses** when appropriate
5. **Implement retry logic** for failed requests
6. **Add request/response logging** in development
7. **Validate data** before sending to API
8. **Handle token refresh** automatically
9. **Use proper HTTP methods** (GET, POST, PUT, DELETE)
10. **Implement timeout handling** for slow networks

---

**Last Updated:** December 2025  
**Version:** 1.0.0
