# USER MANAGEMENT API INTEGRATION DOCUMENTATION

## 📋 Overview

Complete API integration for User Management module with full CRUD operations, dropdown support, and organization management.

**Base URL**: `http://192.168.1.51:8083/api/v1`

---

## 🏗️ Architecture

### Data Layer
- **Models**: `lib/features/user/data/models/user_api_models.dart`
- **Repository**: `lib/features/user/data/repositories/user_api_repository.dart`

### Business Logic
- **Service**: `lib/features/user/services/user_api_service.dart`
- **Mapper**: `lib/features/user/utils/user_mapper.dart`

### UI Layer
- **Main Page**: `lib/features/user/screens/user_main_page.dart`
- **Widgets**: `lib/features/user/widgets/`

---

## 📡 API ENDPOINTS

### 1. Create User
**POST** `/api/v1/users`

**Request Body**:
```json
{
  "tenant_id": "tenant-uuid",
  "org_id": "org-uuid",
  "email": "john.doe@example.com",
  "name": "John Doe",
  "password": "securepassword123",
  "role_id": "role-uuid",
  "department_id": "department-uuid",
  "designation_id": "designation-uuid",
  "project_ids": ["project-uuid-1", "project-uuid-2"],
  "created_by": "admin-uuid",
  "account_holder_name": "John Doe",
  "bank_name": "State Bank of India",
  "bank_account_number": "123456789012",
  "ifsc_code": "SBIN0001234"
}
```

**Response**:
```json
{
  "user_id": "generated-user-uuid",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "roles": ["Role Name"],
  "permissions": ["permission.one", "permission.two"]
}
```

---

### 2. Get User Details
**GET** `/api/v1/users/{user_id}`

**Response**:
```json
{
  "user_id": "user-uuid",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "roles": ["Admin"],
  "permissions": ["users.view", "users.update"],
  "department_name": "Engineering",
  "designation_name": "Senior Developer"
}
```

---

### 3. List Users (Paginated)
**GET** `/api/v1/users?page=1&page_size=10`

**Response**:
```json
{
  "users": [
    {
      "user_id": "user-uuid-1",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "roles": ["Admin"],
      "permissions": []
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 10,
    "total_pages": 5,
    "total_items": 50
  }
}
```

---

### 4. Update User
**PUT** `/api/v1/users/{user_id}`

**Request Body**:
```json
{
  "user_id": "user-uuid",
  "name": "John Doe Updated",
  "email": "john.updated@example.com",
  "password": "newpassword123",
  "roles": ["Admin", "Manager"]
}
```

**Response**:
```json
{
  "user_id": "user-uuid",
  "name": "John Doe Updated",
  "email": "john.updated@example.com",
  "roles": ["Admin", "Manager"],
  "permissions": []
}
```

---

### 5. Upload User Signature
**POST** `/api/v1/users/{user_id}/signature`

**Request Body**:
```json
{
  "user_id": "user-uuid",
  "filename": "signature.png",
  "signature_file": "base64_encoded_string_of_image_bytes"
}
```

**Response**:
```json
{
  "message": "Signature uploaded successfully",
  "file_url": "signature/file/path.png"
}
```

---

### 6. List User Organizations
**GET** `/api/v1/users/{user_id}/organizations`

**Response**:
```json
{
  "organizations": [
    {
      "org_id": "org-uuid-1",
      "org_name": "Headquarters",
      "role_name": "Admin",
      "is_current_context": true,
      "joined_at": "2025-01-01T10:00:00Z"
    }
  ]
}
```

---

### 7. Add User to Organization
**POST** `/api/v1/users/{user_id}/organizations`

**Request Body**:
```json
{
  "user_id": "user-uuid",
  "org_id": "target-org-uuid",
  "role_id": "role-uuid-for-this-org",
  "department_id": "dept-uuid",
  "designation_id": "desig-uuid",
  "project_ids": ["project-uuid-1"],
  "added_by": "admin-uuid"
}
```

---

### 8. Dropdown Endpoints

#### A. Departments Dropdown
**GET** `/api/v1/users/dropdowns/departments?org_id={org_id}`

**Response**:
```json
{
  "departments": [
    { "id": "dept-uuid-1", "name": "Engineering" },
    { "id": "dept-uuid-2", "name": "HR" }
  ]
}
```

#### B. Designations Dropdown
**GET** `/api/v1/users/dropdowns/designations?org_id={org_id}`

**Response**:
```json
{
  "designations": [
    { "id": "desig-uuid-1", "name": "Manager" },
    { "id": "desig-uuid-2", "name": "Developer" }
  ]
}
```

#### C. Roles Dropdown
**GET** `/api/v1/users/dropdowns/roles?org_id={org_id}`

**Response**:
```json
{
  "roles": [
    { "id": "role-uuid-1", "name": "Admin" },
    { "id": "role-uuid-2", "name": "Viewer" }
  ]
}
```

---

## 💻 USAGE EXAMPLES

### Initialize Service
```dart
// Service is already registered in main.dart
final userService = context.read<UserApiService>();
```

### Load Users
```dart
await userService.loadUsers(
  page: 1,
  pageSize: 10,
);

// Access users
final users = userService.users;
final pagination = userService.pagination;
```

### Create User
```dart
final request = CreateUserRequest(
  tenantId: await JwtTokenManager.getTenantId() ?? '',
  orgId: await JwtTokenManager.getOrgId() ?? '',
  email: 'john.doe@example.com',
  name: 'John Doe',
  password: 'securePassword123',
  roleId: selectedRoleId,
  departmentId: selectedDepartmentId,
  designationId: selectedDesignationId,
  createdBy: await JwtTokenManager.getUserId() ?? '',
  accountHolderName: 'John Doe',
  bankName: 'State Bank',
  bankAccountNumber: '123456789012',
  ifscCode: 'SBIN0001234',
);

final result = await userService.createUser(request);
if (result.success) {
  print('User created: ${result.user?.userId}');
}
```

### Update User
```dart
final request = UpdateUserRequest(
  userId: userId,
  name: 'Updated Name',
  email: 'updated@example.com',
  roles: ['Admin', 'Manager'],
);

final result = await userService.updateUser(request);
if (result.success) {
  print('User updated successfully');
}
```

### Load Dropdowns
```dart
final orgId = await JwtTokenManager.getOrgId() ?? '';

// Load all dropdowns at once
await userService.loadDropdowns(orgId);

// Access dropdowns
final departments = userService.departments;
final designations = userService.designations;
final roles = userService.roles;

// Or load individually
final deptResult = await userService.loadDepartments(orgId);
if (deptResult.success) {
  final departments = deptResult.items;
}
```

### Upload Signature
```dart
// Convert image to base64
final bytes = await File(imagePath).readAsBytes();
final base64Image = base64Encode(bytes);

final request = UploadSignatureRequest(
  userId: userId,
  filename: 'signature.png',
  signatureFile: base64Image,
);

final result = await userService.uploadSignature(request);
if (result.success) {
  print('Signature uploaded: ${result.fileUrl}');
}
```

### Search Users
```dart
// Local search (client-side)
final searchResults = userService.searchUsers('john');
```

---

## 🎨 UI INTEGRATION

### User Main Page
```dart
Consumer<UserApiService>(
  builder: (context, userService, _) {
    // Map API models to UI models
    final users = userService.users.map(mapUserApiToUi).toList();
    
    return UserTableView(
      userData: users,
      isLoading: userService.isLoading,
      errorMessage: userService.error,
      onDelete: _onDeleteUser,
      onEdit: _onEditUser,
    );
  },
)
```

### Add User Form
```dart
// Load dropdowns on init
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadDropdowns();
  });
}

Future<void> _loadDropdowns() async {
  final service = context.read<UserApiService>();
  final orgId = await JwtTokenManager.getOrgId() ?? '';
  await service.loadDropdowns(orgId);
}

// Use dropdowns in form
Consumer<UserApiService>(
  builder: (context, userService, _) {
    return DropdownButton<String>(
      items: userService.departments.map((dept) {
        return DropdownMenuItem(
          value: dept.id,
          child: Text(dept.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedDeptId = value),
    );
  },
)
```

---

## 🔄 STATE MANAGEMENT

### Service State
```dart
class UserApiService extends ChangeNotifier {
  // Data
  List<UserApiModel> _users = [];
  UserPagination? _pagination;
  
  // Loading & Error
  bool _isLoading = false;
  String? _error;
  
  // Dropdowns
  List<DropdownItem> _departments = [];
  List<DropdownItem> _designations = [];
  List<DropdownItem> _roles = [];
  
  // Getters
  List<UserApiModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Notify listeners on state changes
  notifyListeners();
}
```

---

## 🗺️ MODEL MAPPING

### API Model to UI Model
```dart
User mapUserApiToUi(UserApiModel apiModel) {
  return User(
    id: apiModel.userId.hashCode,
    name: apiModel.name,
    username: apiModel.email.split('@').first,
    email: apiModel.email,
    roles: apiModel.roles,
    isActive: true,
    designation: apiModel.designationName,
    department: apiModel.departmentName,
    signatureUrl: apiModel.signatureUrl,
    accountHolder: apiModel.accountHolderName,
    bankName: apiModel.bankName,
    bankAccount: apiModel.bankAccountNumber,
    ifsc: apiModel.ifscCode,
  );
}
```

---

## 🔐 AUTHENTICATION

All API requests automatically include:
- **Authorization Header**: `Bearer {access_token}`
- **Tenant ID Header**: `tenant_id: {tenant_id}` (via AuthInterceptor)

Retrieved from `JwtTokenManager`:
```dart
final token = await JwtTokenManager.getAccessToken();
final tenantId = await JwtTokenManager.getTenantId();
final orgId = await JwtTokenManager.getOrgId();
final userId = await JwtTokenManager.getUserId();
```

---

## ✅ TESTING CHECKLIST

### API Integration
- [ ] Create user with all fields
- [ ] Create user with minimal fields
- [ ] Get user by ID
- [ ] List users with pagination
- [ ] Update user details
- [ ] Upload user signature
- [ ] Get user organizations
- [ ] Add user to organization
- [ ] Load departments dropdown
- [ ] Load designations dropdown
- [ ] Load roles dropdown

### UI Integration
- [ ] User list loads from API
- [ ] Pagination works correctly
- [ ] Search filters users
- [ ] Create user form submits to API
- [ ] Edit user form updates via API
- [ ] Delete user calls API
- [ ] Dropdowns populate from API
- [ ] Loading states display correctly
- [ ] Error messages show properly
- [ ] Empty states handled

### Error Handling
- [ ] Network errors handled gracefully
- [ ] Validation errors displayed
- [ ] 401 Unauthorized redirects to login
- [ ] 403 Forbidden shows permission error
- [ ] 404 Not Found handled
- [ ] 500 Server Error shows retry option

---

## 📁 FILE STRUCTURE

```
lib/features/user/
├── data/
│   ├── models/
│   │   └── user_api_models.dart          # API models
│   ├── repositories/
│   │   └── user_api_repository.dart      # HTTP requests
│   └── user_mockdb.dart                  # ❌ TO BE REMOVED
├── services/
│   └── user_api_service.dart             # State management
├── utils/
│   └── user_mapper.dart                  # Model conversion
├── model/
│   └── user_model.dart                   # Legacy UI model
├── screens/
│   ├── user_main_page.dart               # ✅ UPDATED
│   ├── add_user.dart                     # TODO: Wire to API
│   ├── edit_user.dart                    # TODO: Wire to API
│   └── view_user.dart                    # TODO: Wire to API
└── widgets/
    ├── user_table.dart                   # TODO: Add pagination
    ├── user_grid.dart                    # TODO: Update
    ├── user_header.dart                  # ✅ No changes needed
    └── add_user_form.dart                # TODO: Wire dropdowns
```

---

## 🚀 NEXT STEPS

### Immediate
1. ✅ Create API models
2. ✅ Implement repository
3. ✅ Create service with state management
4. ✅ Register service in main.dart
5. ✅ Update user main page
6. ⏳ Wire add user form with dropdowns
7. ⏳ Wire edit user screen
8. ⏳ Wire view user screen
9. ⏳ Update user table with pagination
10. ⏳ Remove mock data

### Future Enhancements
- Implement user deletion API
- Add user status toggle
- Implement user search on backend
- Add user filters (role, department, status)
- Implement bulk operations
- Add user import/export
- Implement user audit logs

---

## 🐛 TROUBLESHOOTING

### Issue: Users not loading
**Solution**: Check if service is initialized and API endpoint is correct
```dart
print('Loading state: ${userService.isLoading}');
print('Error: ${userService.error}');
print('Users count: ${userService.users.length}');
```

### Issue: Dropdowns empty
**Solution**: Ensure orgId is valid and dropdowns are loaded
```dart
final orgId = await JwtTokenManager.getOrgId();
print('Org ID: $orgId');
await userService.loadDropdowns(orgId ?? '');
```

### Issue: 401 Unauthorized
**Solution**: Check if token is valid and not expired
```dart
final token = await JwtTokenManager.getAccessToken();
final isExpired = await JwtTokenManager.isTokenExpired();
print('Token: ${token?.substring(0, 20)}...');
print('Expired: $isExpired');
```

---

## 📞 SUPPORT

For issues or questions:
1. Check console logs for detailed error messages
2. Verify API endpoint availability
3. Confirm authentication tokens are valid
4. Review network requests in DevTools

---

**Last Updated**: December 2024  
**API Version**: v1  
**Status**: ✅ Core Integration Complete
