# Designation Module API Integration

## Overview
The Designation module has been fully integrated with backend APIs, replacing all mock data with real API calls using Provider for state management and Dio for HTTP requests. This follows the same architecture as the Department module.

## Architecture

### 1. Data Layer
**File**: `lib/features/designation/model/designation_model.dart`
- Updated `Designation` model with String ID (matching backend)
- Added `createdAt` and `updatedAt` DateTime fields
- JSON serialization/deserialization methods

**File**: `lib/features/designation/data/repositories/designation_api_repository.dart`
- Repository pattern for API calls
- Uses Dio with AuthInterceptor for authentication
- Handles all CRUD operations + Get by ID
- Returns record types for success/error handling

### 2. Business Logic Layer
**File**: `lib/features/designation/providers/designation_provider.dart`
- `ChangeNotifier` provider for reactive state management
- Methods:
  - `loadDesignations()` - Fetch all designations
  - `getDesignationById()` - Fetch single designation
  - `createDesignation()` - Create new designation
  - `updateDesignation()` - Update existing designation
  - `deleteDesignation()` - Delete designation
  - `searchDesignations()` - Local search/filter
  - `refresh()` - Reload data
  - `clearData()` - Clear state on logout

### 3. Presentation Layer
Updated screens to use Provider:
- `DesignationMainPage` - List view with search
- `CreateDesignationScreen` - Create form
- `EditDesignationScreen` - Edit form
- `ViewDesignationPage` - Read-only view
- `DesignationTableView` - Table with sequential numbering

## API Endpoints

Base URL: `http://192.168.1.51:8083/api/v1`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/designations` | Get all designations |
| GET | `/designations/:id` | Get designation by ID |
| POST | `/designations` | Create designation |
| PUT | `/designations/:id` | Update designation |
| DELETE | `/designations/:id` | Delete designation |

### Request/Response Examples

#### GET /designations
**Response**:
```json
{
  "designations": [
    {
      "id": "026931ab-4bb9-4769-9c17-593c3f7b20f2",
      "name": "Junior Software Engineer",
      "description": "Responsible for frontend and backend websites",
      "createdAt": "2025-11-21T09:54:42.333097Z",
      "updatedAt": "2025-11-21T09:54:42.333097Z"
    }
  ],
  "pagination": null
}
```

#### GET /designations/:id
**Response**:
```json
{
  "designation": {
    "id": "026931ab-4bb9-4769-9c17-593c3f7b20f2",
    "name": "Junior Software Engineer",
    "description": "Responsible for frontend and backend websites",
    "createdAt": "2025-11-21T09:54:42.333097Z",
    "updatedAt": "2025-11-21T09:54:42.333097Z"
  },
  "message": ""
}
```

#### POST /designations
**Request**:
```json
{
  "name": "Junior Software Engineer",
  "description": "Responsible for frontend and backend websites"
}
```

**Response**:
```json
{
  "designation": {
    "id": "026931ab-4bb9-4769-9c17-593c3f7b20f2",
    "name": "Junior Software Engineer",
    "description": "Responsible for frontend and backend websites",
    "createdAt": "2025-11-21T09:54:42.333097Z",
    "updatedAt": "2025-11-21T09:54:42.333097Z"
  },
  "message": ""
}
```

#### PUT /designations/:id
**Request**:
```json
{
  "name": "Viewer",
  "description": "Handles viewing on websites"
}
```

**Response**:
```json
{
  "designation": {
    "id": "35122070-f843-4cd2-acf5-790c43df20ac",
    "name": "Viewer",
    "description": "Handles viewing on websites",
    "createdAt": "2025-11-21T06:57:13.511594Z",
    "updatedAt": "2025-11-21T09:59:54.638066700Z"
  },
  "message": ""
}
```

#### DELETE /designations/:id
**Response**:
```json
{
  "success": true,
  "message": "Designation deleted successfully"
}
```

## Provider Registration

The `DesignationProvider` is registered in `main.dart`:

```dart
MultiProvider(
  providers: [
    // ... other providers
    ChangeNotifierProvider(create: (_) => DesignationProvider()),
  ],
  child: const MyApp(),
)
```

## Usage Examples

### 1. Load Designations
```dart
final provider = context.read<DesignationProvider>();
await provider.loadDesignations();

// Access data
final designations = provider.designations;
final isLoading = provider.isLoading;
final error = provider.error;
```

### 2. Get Designation by ID
```dart
final provider = context.read<DesignationProvider>();
final result = await provider.getDesignationById('026931ab-4bb9-4769-9c17-593c3f7b20f2');

if (result.success) {
  print('Designation: ${result.designation?.name}');
}
```

### 3. Create Designation
```dart
final provider = context.read<DesignationProvider>();
final result = await provider.createDesignation(
  name: 'Junior Software Engineer',
  description: 'Responsible for frontend and backend websites',
);

if (result.success) {
  print('Created: ${result.designation?.name}');
} else {
  print('Error: ${result.message}');
}
```

### 4. Update Designation
```dart
final provider = context.read<DesignationProvider>();
final result = await provider.updateDesignation(
  id: '026931ab-4bb9-4769-9c17-593c3f7b20f2',
  name: 'Senior Software Engineer',
  description: 'Updated description',
);
```

### 5. Delete Designation
```dart
final provider = context.read<DesignationProvider>();
final result = await provider.deleteDesignation('026931ab-4bb9-4769-9c17-593c3f7b20f2');
```

### 6. Search Designations
```dart
final provider = context.read<DesignationProvider>();
final filtered = provider.searchDesignations('engineer');
```

### 7. Listen to Changes
```dart
Consumer<DesignationProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    
    return ListView.builder(
      itemCount: provider.designations.length,
      itemBuilder: (context, index) {
        final desig = provider.designations[index];
        return ListTile(
          title: Text(desig.name),
          subtitle: Text(desig.description),
        );
      },
    );
  },
)
```

## Error Handling

All API methods return record types with success status and message:

```dart
final result = await provider.createDesignation(...);

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

The `DesignationApiRepository` uses `AuthInterceptor` which automatically:
- Adds `Authorization: Bearer <token>` header
- Skips `tenant_id` header for `/designations` endpoint (CORS workaround)
- Handles token refresh on 401 errors
- Manages logout on authentication failures

## Sequential Numbering

The designation table displays sequential numbers (1, 2, 3...) instead of UUIDs:
- Newest designations appear first (sorted by `createdAt`)
- Numbers are calculated per page: `(currentPage * rowsPerPage) + rowIndex + 1`
- Numbers stay gap-free even after deletions
- Pagination-aware numbering

## CORS Workaround

**Temporary Fix Applied**: The `AuthInterceptor` skips tenant headers for `/designations` endpoint to avoid CORS errors.

**File Modified**: `lib/core/services/api_service.dart`
```dart
bool _shouldAttachTenantHeader(String path) {
  const skipTenantHeaderPaths = [
    '/permissions',
    '/departments',
    '/designations',  // Backend CORS doesn't allow tenant_id header
  ];
  final shouldSkip = skipTenantHeaderPaths.any((skipPath) => path.contains(skipPath));
  return !shouldSkip;
}
```

**⚠️ Backend Fix Required**: Update backend CORS configuration to allow tenant headers:

```java
@CrossOrigin(
    origins = {"http://localhost:*", "http://127.0.0.1:*"},
    allowedHeaders = {
        "Authorization",
        "Content-Type",
        "Accept",
        "tenant_id",
        "tenant-id"
    },
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS}
)
```

## Testing

To test the integration:

1. **Start the backend server** at `http://192.168.1.51:8083`

2. **Login** to get authentication token

3. **Navigate to Designations** page (`/designations`)

4. **Test CRUD operations**:
   - ✅ View list of designations
   - ✅ Create new designation
   - ✅ Edit existing designation
   - ✅ Delete designation
   - ✅ Search designations
   - ✅ View designation details

5. **Check console logs** for API calls:
   ```
   🔍 [DesignationApiRepository] GET /designations
   📥 [DesignationApiRepository] Response: 200
   📦 [DesignationApiRepository] Data: {...}
   ✅ [DesignationProvider] Loaded 3 designations
   ```

## Files Modified

1. `lib/features/designation/model/designation_model.dart` - Updated model
2. `lib/features/designation/data/repositories/designation_api_repository.dart` - New repository
3. `lib/features/designation/providers/designation_provider.dart` - New provider
4. `lib/features/designation/screen/designation_main_page.dart` - Provider integration
5. `lib/features/designation/screen/create_designation.dart` - Provider integration
6. `lib/features/designation/screen/edit_designation.dart` - Provider integration
7. `lib/features/designation/widgets/designation_table.dart` - Sequential numbering
8. `lib/features/designation/screen/view_designation.dart` - ID type fix
9. `lib/main.dart` - Provider registration
10. `lib/core/services/api_service.dart` - CORS workaround

## Files Deleted

1. `lib/features/designation/data/designation_mockdb.dart` - Mock data removed

## Comparison with Department Module

Both modules follow identical architecture:
- ✅ Same Provider pattern
- ✅ Same Repository pattern
- ✅ Same error handling approach
- ✅ Same CORS workaround
- ✅ Same sequential numbering
- ✅ Same newest-first sorting

## Next Steps

1. ✅ Run `flutter pub get` (already done)
2. ✅ Test all CRUD operations
3. ✅ Verify error handling
4. ✅ Check authentication flow
5. ✅ Monitor API logs for issues
6. ⏳ Backend CORS fix (when available)

## Support

For issues or questions:
- Check console logs for detailed error messages
- Verify backend API responses match expected format
- Ensure authentication headers are being sent
- Review Provider state in Flutter DevTools
