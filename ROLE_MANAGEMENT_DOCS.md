# Role Management System - Complete Documentation

## 📋 Overview

Complete Role & Permission Management system integrated with backend API endpoints. Supports full CRUD operations for roles with real-time permission assignment.

## 🎯 Features Implemented

### ✅ Backend API Integration
- **GET /api/v1/roles** - List all roles
- **GET /api/v1/roles/{role_id}** - Get role by ID
- **POST /api/v1/roles** - Create new role
- **PUT /api/v1/roles/{role_id}** - Update role
- **DELETE /api/v1/roles/{role_id}** - Delete role
- **GET /api/v1/permissions** - Get all available permissions

### ✅ Data Models
- `PermissionModel` - System permissions with module/action structure
- `RoleModel` - Roles with assigned permissions
- `CreateRoleRequest` - Request model for creating roles
- `UpdateRoleRequest` - Request model for updating roles

### ✅ Service Layer
- `RolesApiRepository` - Direct API communication
- `RolesApiService` - State management with ChangeNotifier
- Real-time updates and reactive UI
- Comprehensive error handling

## 📁 Project Structure

```
lib/features/roles/
├── data/
│   ├── models/
│   │   └── role_models.dart          # All data models
│   └── repositories/
│       └── roles_api_repository.dart  # API calls
├── services/
│   └── roles_api_service.dart         # State management
└── screens/
    ├── roles_main_page.dart           # Main roles list (TO BE CREATED)
    ├── create_role_dialog.dart        # Create role form (TO BE CREATED)
    └── edit_role_dialog.dart          # Edit role form (TO BE CREATED)
```

## 🔧 Implementation Details

### 1. Data Models (`role_models.dart`)

#### PermissionModel
```dart
class PermissionModel {
  final String permissionId;
  final String name;
  final String description;
  final String module;          // e.g., "departments", "users", "roles"
  final String action;          // e.g., "create", "view", "edit", "delete"
  final bool isSystemPermission;
}
```

**Example Permission:**
```json
{
  "permissionId": "7721a525-3bef-4a3a-9161-f2a0f3acf418",
  "name": "view-department",
  "description": "View departments",
  "module": "departments",
  "action": "view",
  "isSystemPermission": true
}
```

#### RoleModel
```dart
class RoleModel {
  final String? roleId;
  final String name;
  final List<String> permissions;  // List of permission names
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

**Example Role:**
```json
{
  "roleId": "abc123",
  "name": "MANAGER",
  "permissions": ["view-department", "view-designation"],
  "createdAt": "2025-11-20T13:12:50Z",
  "updatedAt": "2025-11-20T13:12:50Z"
}
```

### 2. API Repository (`roles_api_repository.dart`)

#### Configuration
- **Base URL:** `http://192.168.1.51:8083/api/v1`
- **Authentication:** JWT Bearer token (auto-injected)
- **Content-Type:** `application/json`

#### Methods

**Get All Roles**
```dart
Future<({bool success, String? message, RolesListResponse? data})> getRoles()
```

**Get Role by ID**
```dart
Future<({bool success, String? message, RoleModel? data})> getRoleById(String roleId)
```

**Create Role**
```dart
Future<({bool success, String? message, RoleModel? data})> createRole(CreateRoleRequest request)
```
Request body:
```json
{
  "name": "MANAGER",
  "permissions": ["view-department", "view-designation"]
}
```

**Update Role**
```dart
Future<({bool success, String? message, RoleModel? data})> updateRole(String roleId, UpdateRoleRequest request)
```

**Delete Role**
```dart
Future<({bool success, String? message})> deleteRole(String roleId)
```

**Get All Permissions**
```dart
Future<({bool success, String? message, List<PermissionModel>? data})> getPermissions()
```

### 3. Service Layer (`roles_api_service.dart`)

#### State Management
```dart
class RolesApiService extends ChangeNotifier {
  List<RoleModel> _roles = [];
  List<PermissionModel> _availablePermissions = [];
  bool _isLoading = false;
  String? _error;
}
```

#### Key Methods

**Load Roles**
```dart
await rolesService.loadRoles();
```

**Load Permissions**
```dart
await rolesService.loadPermissions();
```

**Create Role**
```dart
final request = CreateRoleRequest(
  name: 'MANAGER',
  permissions: ['view-department', 'view-designation'],
);
final result = await rolesService.createRole(request);
```

**Update Role**
```dart
final request = UpdateRoleRequest(
  name: 'SENIOR_MANAGER',
  permissions: ['view-department', 'edit-department', 'view-designation'],
);
final result = await rolesService.updateRole(roleId, request);
```

**Delete Role**
```dart
final result = await rolesService.deleteRole(roleId);
```

**Search Roles**
```dart
final filteredRoles = rolesService.searchRoles('manager');
```

**Get Permissions by Module**
```dart
final grouped = rolesService.getPermissionsByModule();
// Returns: Map<String, List<PermissionModel>>
// {
//   "departments": [Permission1, Permission2],
//   "users": [Permission3, Permission4],
//   ...
// }
```

## 🚀 Usage Examples

### Example 1: Load and Display Roles

```dart
class RolesPage extends StatefulWidget {
  @override
  _RolesPageState createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rolesService = context.read<RolesApiService>();
    await rolesService.loadRoles();
    await rolesService.loadPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RolesApiService>(
      builder: (context, rolesService, child) {
        if (rolesService.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: rolesService.roles.length,
          itemBuilder: (context, index) {
            final role = rolesService.roles[index];
            return ListTile(
              title: Text(role.name),
              subtitle: Text('${role.permissions.length} permissions'),
            );
          },
        );
      },
    );
  }
}
```

### Example 2: Create New Role

```dart
Future<void> _createRole() async {
  final rolesService = context.read<RolesApiService>();
  
  final request = CreateRoleRequest(
    name: 'MANAGER',
    permissions: [
      'view-department',
      'view-designation',
      'create-department',
    ],
  );

  final result = await rolesService.createRole(request);

  if (result.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Role created successfully!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${result.message}')),
    );
  }
}
```

### Example 3: Permission Selection UI

```dart
Widget _buildPermissionSelector(RolesApiService rolesService) {
  final permissionsByModule = rolesService.getPermissionsByModule();
  
  return ListView(
    children: permissionsByModule.entries.map((entry) {
      final module = entry.key;
      final permissions = entry.value;
      
      return ExpansionTile(
        title: Text(module.toUpperCase()),
        children: permissions.map((permission) {
          return CheckboxListTile(
            title: Text(permission.description),
            subtitle: Text(permission.name),
            value: selectedPermissions.contains(permission.name),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedPermissions.add(permission.name);
                } else {
                  selectedPermissions.remove(permission.name);
                }
              });
            },
          );
        }).toList(),
      );
    }).toList(),
  );
}
```

## 📊 Available Permissions (Sample)

### Departments Module
- `view-department` - View departments
- `create-department` - Create departments
- `edit-department` - Edit departments
- `delete-department` - Delete departments

### Designations Module
- `view-designation` - View designations
- `create-designation` - Create designations
- `edit-designation` - Edit designations
- `delete-designation` - Delete designations

### Users Module
- `view-user` - View users
- `create-user` - Create new users
- `edit-user` - Edit existing users
- `delete-user` - Delete users

### Roles Module
- `view-role` - View roles
- `create-role` - Create new roles
- `edit-role` - Edit existing roles
- `delete-role` - Delete roles

### Organizations Module
- `view-organizations` - View organizations
- `create-organizations` - Create organizations
- `edit-organizations` - Edit organizations
- `delete-organizations` - Delete organizations
- `switch-organizations` - Switch between organizations

## 🔐 Security & Authentication

- All API calls require JWT authentication
- Bearer token automatically injected via interceptor
- Tokens retrieved from `JwtTokenManager`
- 401 errors trigger token refresh automatically

## 🐛 Error Handling

### Repository Level
```dart
try {
  final response = await _dio.get('/roles');
  return (success: true, message: 'Success', data: response.data);
} on DioException catch (e) {
  final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed';
  return (success: false, message: errorMessage, data: null);
} catch (e) {
  return (success: false, message: 'Unexpected error: $e', data: null);
}
```

### Service Level
```dart
final result = await rolesService.createRole(request);
if (!result.success) {
  // Handle error
  print('Error: ${result.message}');
}
```

## 📝 Next Steps (UI Implementation)

### 1. Create Roles Main Page
- Display roles in a data table
- Search and filter functionality
- Create/Edit/Delete actions
- Permission count display

### 2. Create Role Dialog
- Role name input
- Permission selection (grouped by module)
- Validation
- Submit handling

### 3. Edit Role Dialog
- Pre-populate existing role data
- Update permissions
- Save changes

### 4. Integration
- Add to provider in `main.dart`
- Add routes in router
- Add navigation menu item

## 🧪 Testing Checklist

- [ ] Load all roles successfully
- [ ] Load all permissions successfully
- [ ] Create new role with permissions
- [ ] Update existing role
- [ ] Delete role
- [ ] Search roles by name
- [ ] Group permissions by module
- [ ] Handle API errors gracefully
- [ ] Show loading states
- [ ] Display success/error messages

## 📚 API Response Examples

### GET /api/v1/roles
```json
[
  {
    "roleId": "abc123",
    "name": "MANAGER",
    "permissions": ["view-department", "view-designation"],
    "createdAt": "2025-11-20T13:12:50Z",
    "updatedAt": "2025-11-20T13:12:50Z"
  }
]
```

### GET /api/v1/permissions
```json
{
  "permissions": [
    {
      "permissionId": "7721a525-3bef-4a3a-9161-f2a0f3acf418",
      "name": "view-department",
      "description": "View departments",
      "module": "departments",
      "action": "view",
      "isSystemPermission": true
    }
  ]
}
```

### POST /api/v1/roles
Request:
```json
{
  "name": "MANAGER",
  "permissions": ["view-department", "view-designation"]
}
```

Response:
```json
{
  "roleId": "new-role-id",
  "name": "MANAGER",
  "permissions": ["view-department", "view-designation"],
  "createdAt": "2025-11-20T13:12:50Z",
  "updatedAt": "2025-11-20T13:12:50Z"
}
```

## 🎨 UI Design Recommendations

### Roles Table Columns
1. **Role Name** - Display role name
2. **Permissions Count** - Number of assigned permissions
3. **Created Date** - When role was created
4. **Actions** - Edit, Delete buttons

### Permission Selector
- Group by module (Departments, Users, Roles, etc.)
- Expandable sections for each module
- Checkboxes for each permission
- Search/filter permissions
- Select all/none per module

### Color Coding
- System roles: Blue badge
- Custom roles: Green badge
- Permissions by module: Different colors per module

## 🔗 Related Documentation
- Organization Management System
- User Management System
- Authentication & Authorization Flow
- API Integration Guide

---

**Status:** ✅ Backend Integration Complete | 🚧 UI Implementation Pending
**Last Updated:** November 20, 2025
**Version:** 1.0.0
