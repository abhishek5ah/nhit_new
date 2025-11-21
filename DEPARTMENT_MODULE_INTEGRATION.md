# Department Module API Integration

## Overview
The Department module has been fully integrated with backend APIs, replacing all mock data with real API calls using Provider for state management and Dio for HTTP requests.

## Architecture

### 1. Data Layer
**File**: `lib/features/department/model/department_model.dart`
- Updated `Department` model with String ID (matching backend)
- Added `createdAt` and `updatedAt` DateTime fields
- JSON serialization/deserialization methods

**File**: `lib/features/department/data/repositories/department_api_repository.dart`
- Repository pattern for API calls
- Uses Dio with AuthInterceptor for authentication
- Handles all CRUD operations
- Returns record types for success/error handling

### 2. Business Logic Layer
**File**: `lib/features/department/providers/department_provider.dart`
- `ChangeNotifier` provider for reactive state management
- Methods:
  - `loadDepartments()` - Fetch all departments
  - `createDepartment()` - Create new department
  - `updateDepartment()` - Update existing department
  - `deleteDepartment()` - Delete department
  - `searchDepartments()` - Local search/filter
  - `refresh()` - Reload data
  - `clearData()` - Clear state on logout

### 3. Presentation Layer
Updated screens to use Provider:
- `DepartmentMainPage` - List view with search
- `CreateDepartmentScreen` - Create form
- `EditDepartmentPage` - Edit form
- `AddDepartmentPage` - Dialog form
- `ViewDepartmentPage` - Read-only view

## API Endpoints

Base URL: `http://192.168.1.51:8083/api/v1`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/departments` | Get all departments |
| POST | `/departments` | Create department |
| PUT | `/departments/:id` | Update department |
| DELETE | `/departments/:id` | Delete department |

### Request/Response Examples

#### GET /departments
**Response**:
```json
{
  "departments": [
    {
      "id": "dept-123",
      "name": "Engineering",
      "description": "Software development team",
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ],
  "totalCount": 1
}
```

#### POST /departments
**Request**:
```json
{
  "name": "Engineering",
  "description": "Software development team"
}
```

**Response**:
```json
{
  "id": "dept-123",
  "name": "Engineering",
  "description": "Software development team",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## Provider Registration

The `DepartmentProvider` is registered in `main.dart`:

```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => DepartmentProvider()),
  ],
  child: const MyApp(),
)
```

## Usage Examples

### 1. Load Departments
```dart
final provider = context.read<DepartmentProvider>();
await provider.loadDepartments();

// Access data
final departments = provider.departments;
final isLoading = provider.isLoading;
final error = provider.error;
```

### 2. Create Department
```dart
final provider = context.read<DepartmentProvider>();
final result = await provider.createDepartment(
  name: 'Engineering',
  description: 'Software development team',
);

if (result.success) {
  print('Created: ${result.department?.name}');
} else {
  print('Error: ${result.message}');
}
```

### 3. Update Department
```dart
final provider = context.read<DepartmentProvider>();
final result = await provider.updateDepartment(
  id: 'dept-123',
  name: 'Updated Name',
  description: 'Updated description',
);
```

### 4. Delete Department
```dart
final provider = context.read<DepartmentProvider>();
final result = await provider.deleteDepartment('dept-123');
```

### 5. Search Departments
```dart
final provider = context.read<DepartmentProvider>();
final filtered = provider.searchDepartments('engineering');
```

### 6. Listen to Changes
```dart
Consumer<DepartmentProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    
    return ListView.builder(
      itemCount: provider.departments.length,
      itemBuilder: (context, index) {
        final dept = provider.departments[index];
        return ListTile(
          title: Text(dept.name),
          subtitle: Text(dept.description),
        );
      },
    );
  },
)
```

## Error Handling

All API methods return record types with success status and message:

```dart
final result = await provider.createDepartment(...);

if (result.success) {
  // Success case
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.message ?? 'Success'),
      backgroundColor: Colors.green,
    ),
  );
} else {
  // Error case
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(result.message ?? 'Failed'),
      backgroundColor: Colors.red,
    ),
  );
}
```

## Authentication

The `DepartmentApiRepository` uses `AuthInterceptor` which automatically:
- Adds `Authorization: Bearer <token>` header
- Adds `tenant_id` and `tenant-id` headers
- Handles token refresh on 401 errors
- Manages logout on authentication failures

## State Management Flow

```
User Action → Widget → Provider Method → Repository → API
                ↓
            State Update
                ↓
          UI Rebuild (via notifyListeners)
```

## Testing

To test the integration:

1. **Start the backend server** at `http://192.168.1.51:8083`

2. **Login** to get authentication token

3. **Navigate to Departments** page (`/department`)

4. **Test CRUD operations**:
   - View list of departments
   - Create new department
   - Edit existing department
   - Delete department
   - Search departments

5. **Check console logs** for API calls:
   ```
   🔍 [DepartmentApiRepository] GET /departments
   📥 [DepartmentApiRepository] Response: 200
   📦 [DepartmentApiRepository] Data: {...}
   ✅ [DepartmentProvider] Loaded 5 departments
   ```

## Migration Notes

### Changes from Mock Data
1. **ID Type**: Changed from `int` to `String` to match backend
2. **Added Fields**: `createdAt` and `updatedAt` timestamps
3. **Removed**: `department_mockdb.dart` file
4. **Updated**: All screens to use Provider instead of local state

### Breaking Changes
- Department IDs are now Strings (was int)
- All department operations are now async
- UI components must handle loading and error states

## Troubleshooting

### CORS Errors (CURRENT ISSUE - TEMPORARY FIX APPLIED)

**Problem**: Backend CORS configuration doesn't allow `tenant_id` header for departments endpoint.

**Error Message**:
```
Access to XMLHttpRequest at 'http://192.168.1.51:8083/api/v1/departments' 
from origin 'http://localhost:60369' has been blocked by CORS policy: 
Request header field tenant_id is not allowed by Access-Control-Allow-Headers 
in preflight response.
```

**Temporary Fix Applied**: 
The `AuthInterceptor` now skips tenant headers for `/departments` endpoint to avoid CORS errors.

**File Modified**: `lib/core/services/api_service.dart`
```dart
bool _shouldAttachTenantHeader(String path) {
  const skipTenantHeaderPaths = [
    '/permissions',
    '/departments',  // Backend CORS doesn't allow tenant_id header
  ];
  final shouldSkip = skipTenantHeaderPaths.any((skipPath) => path.contains(skipPath));
  return !shouldSkip;
}
```

**⚠️ IMPORTANT - Backend Fix Required**:
This is a temporary workaround. The proper solution is to update backend CORS configuration to allow tenant headers:

```java
@CrossOrigin(
    origins = {"http://localhost:*", "http://127.0.0.1:*"},
    allowedHeaders = {
        "Authorization",
        "Content-Type",
        "Accept",
        "tenant_id",      // Add this
        "tenant-id"       // Add this
    },
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}
)
```

**Impact of Workaround**:
- Department API calls will work without CORS errors
- However, if backend requires tenant_id for data isolation, you may see data from all tenants
- Once backend CORS is fixed, remove `/departments` from `skipTenantHeaderPaths`

### Other CORS Issues
If you see CORS errors for other endpoints, ensure backend allows:
- `tenant_id` and `tenant-id` headers
- `Authorization` header
- Proper CORS configuration for preflight requests

### Authentication Errors
- Verify JWT token is valid
- Check token expiration
- Ensure tenant context is set

### Network Errors
- Verify backend is running at `http://192.168.1.51:8083`
- Check network connectivity
- Review Dio interceptor logs

## Files Modified

1. `lib/features/department/model/department_model.dart` - Updated model
2. `lib/features/department/data/repositories/department_api_repository.dart` - New repository
3. `lib/features/department/providers/department_provider.dart` - New provider
4. `lib/features/department/screen/department_main_page.dart` - Provider integration
5. `lib/features/department/screen/create_department.dart` - Provider integration
6. `lib/features/department/screen/edit_department.dart` - Provider integration
7. `lib/features/department/widgets/add_department.dart` - Provider integration
8. `lib/features/department/widgets/department_table.dart` - ID type fix
9. `lib/features/department/screen/view_department.dart` - ID type fix
10. `lib/main.dart` - Provider registration
11. `pubspec.yaml` - Added http dependency

## Files Deleted

1. `lib/features/department/data/department_mockdb.dart` - Mock data removed

## Next Steps

1. Run `flutter pub get` to install dependencies
2. Test all CRUD operations
3. Verify error handling
4. Check authentication flow
5. Monitor API logs for issues

## Support

For issues or questions:
- Check console logs for detailed error messages
- Verify backend API responses match expected format
- Ensure authentication headers are being sent
- Review Provider state in Flutter DevTools
