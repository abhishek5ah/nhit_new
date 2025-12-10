# Organization Management Documentation

## Overview
The Organization Management module handles multi-tenant organization hierarchies, supporting parent-child organization structures with complete CRUD operations.

---

## Table of Contents
1. [Architecture](#architecture)
2. [Features](#features)
3. [API Endpoints](#api-endpoints)
4. [Data Models](#data-models)
5. [Implementation](#implementation)
6. [Usage Examples](#usage-examples)

---

## Architecture

### Components

#### 1. Organization Model (`lib/features/organization/data/models/organization_hierarchy_models.dart`)

**Purpose:** Data structure for organization entities

**Fields:**
```dart
class Organization {
  final String orgId;              // Unique identifier
  final String tenantId;           // Tenant identifier
  final String? parentOrgId;       // Parent organization ID (empty for parent orgs)
  final String name;               // Organization name
  final String code;               // Unique organization code
  final String databaseName;       // Database identifier
  final String description;        // Organization description
  final String logo;               // Logo URL/path
  final bool isActive;             // Active status
  final String status;             // 'activated' or 'deactivated'
  final List<String> initialProjects; // Associated projects
  final SuperAdmin? superAdmin;    // Super admin details
  final String createdBy;          // Creator name
  final DateTime createdAt;        // Creation timestamp
  final DateTime updatedAt;        // Last update timestamp
}
```

**Helper Properties:**
```dart
bool get isParent => parentOrgId == null || parentOrgId!.isEmpty;
bool get isChild => !isParent;
String get displayStatus => isActive ? 'Active' : 'Inactive';
```

---

#### 2. Organization Service (`lib/features/organization/services/organization_hierarchy_service.dart`)

**Purpose:** Business logic and state management

**State Management:** ChangeNotifier

**Properties:**
```dart
List<Organization> organizations     // All organizations
Organization? currentOrganization    // Active organization
bool isLoading                       // Loading state
String? error                        // Error messages
```

**Methods:**
```dart
// CRUD Operations
Future<void> loadOrganizations()
Future<void> loadOrganizationsWithChildren()
Future<ApiResponse> createOrganization(CreateOrganizationRequest request)
Future<ApiResponse> updateOrganization(String orgId, UpdateOrganizationRequest request)
Future<ApiResponse> deleteOrganization(String orgId)

// Organization Switching
Future<ApiResponse> switchOrganization(Organization organization)

// Utilities
Future<ApiResponse> getOrganizationByCode(String code)
List<Organization> searchOrganizations(String query)
List<Organization> getParentOrganizations()
List<Organization> getChildOrganizations(String parentOrgId)
```

---

#### 3. Organization Repository (`lib/features/organization/data/repositories/organization_hierarchy_repository.dart`)

**Purpose:** API communication layer

**Methods:**
```dart
Future<ApiResponse<OrganizationsResponse>> getOrganizationsByTenant(String tenantId)
Future<ApiResponse<OrganizationsResponse>> getChildOrganizations(String parentOrgId)
Future<ApiResponse<Organization>> getOrganizationById(String orgId)
Future<ApiResponse<Organization>> getOrganizationByCode(String code)
Future<ApiResponse<Organization>> createOrganization(CreateOrganizationRequest request)
Future<ApiResponse<Organization>> updateOrganization(String orgId, UpdateOrganizationRequest request)
Future<ApiResponse> deleteOrganization(String orgId)
```

---

## Features

### 1. Hierarchical Organization Structure
- **Parent Organizations:** Top-level organizations with `parentOrgId` empty
- **Child Organizations:** Sub-organizations with `parentOrgId` set to parent's ID
- **Multi-level Support:** Unlimited nesting depth

### 2. Organization CRUD Operations
- Create parent and child organizations
- Update organization details
- Activate/deactivate organizations
- Delete organizations (with validation)

### 3. Organization Switching
- Switch between organizations within the same tenant
- Automatic context update
- Seamless navigation

### 4. Visual Hierarchy Display
- Parent organizations with tree icon
- Child organizations with indentation
- Color-coded badges (Blue for parent, Green for child)
- Status indicators

### 5. Search and Filter
- Search by name or code
- Filter by status (active/inactive)
- Filter by parent organization

---

## API Endpoints

### Base URL
```
http://192.168.1.51:8083/api/v1
```

### Endpoints

#### 1. Get Organizations by Tenant
- **Endpoint:** `GET /tenants/{tenantId}/organizations`
- **Authentication:** Bearer Token
- **Headers:**
```
Authorization: Bearer <access_token>
tenant_id: <tenant_id>
```
- **Response (200 OK):**
```json
{
  "organizations": [
    {
      "orgId": "uuid-v4",
      "tenantId": "uuid-v4",
      "parentOrgId": "",
      "name": "ACME Corporation",
      "code": "ACME01",
      "databaseName": "acme_db",
      "description": "Main organization",
      "logo": "https://example.com/logo.png",
      "isActive": true,
      "status": "activated",
      "initialProjects": ["Project Alpha", "Project Beta"],
      "superAdmin": {
        "userId": "uuid-v4",
        "name": "John Doe",
        "email": "john@acme.com"
      },
      "createdBy": "John Doe",
      "createdAt": "2025-01-01T10:00:00Z",
      "updatedAt": "2025-01-01T10:00:00Z"
    }
  ],
  "totalCount": 1
}
```

---

#### 2. Get Child Organizations
- **Endpoint:** `GET /organizations/{parentOrgId}/children`
- **Authentication:** Bearer Token
- **Response (200 OK):**
```json
{
  "organizations": [
    {
      "orgId": "uuid-v4",
      "tenantId": "uuid-v4",
      "parentOrgId": "parent-uuid",
      "name": "ACME - Sales Division",
      "code": "ACME-SALES01",
      "description": "Sales department",
      "isActive": true,
      "status": "activated",
      "createdBy": "John Doe",
      "createdAt": "2025-01-02T10:00:00Z",
      "updatedAt": "2025-01-02T10:00:00Z"
    }
  ]
}
```

---

#### 3. Create Organization
- **Endpoint:** `POST /organizations`
- **Authentication:** Bearer Token
- **Request Body (Parent Organization):**
```json
{
  "tenantId": "uuid-v4",
  "name": "ACME Corporation",
  "code": "ACME01",
  "description": "Main organization",
  "super_admin": {
    "name": "John Doe",
    "email": "john@acme.com",
    "password": "SecurePass123!"
  },
  "initial_projects": ["Project Alpha"]
}
```

- **Request Body (Child Organization):**
```json
{
  "tenantId": "uuid-v4",
  "parentOrgId": "parent-uuid",
  "name": "ACME - Sales Division",
  "code": "ACME-SALES01",
  "description": "Sales department",
  "super_admin": {
    "name": "John Doe",
    "email": "john@acme.com"
  },
  "initial_projects": ["Sales Project"],
  "createdBy": "John Doe"
}
```

- **Response (201 Created):**
```json
{
  "orgId": "uuid-v4",
  "tenantId": "uuid-v4",
  "parentOrgId": "parent-uuid",
  "name": "ACME - Sales Division",
  "code": "ACME-SALES01",
  "description": "Sales department",
  "superAdmin": {
    "userId": "uuid-v4",
    "name": "John Doe",
    "email": "john@acme.com"
  },
  "createdAt": "2025-01-02T10:00:00Z",
  "updatedAt": "2025-01-02T10:00:00Z"
}
```

---

#### 4. Update Organization
- **Endpoint:** `PUT /organizations/{orgId}`
- **Authentication:** Bearer Token
- **Request Body:**
```json
{
  "name": "ACME Corporation Updated",
  "description": "Updated description",
  "status": "activated",
  "initialProjects": ["Project Alpha", "Project Gamma"]
}
```

- **Response (200 OK):**
```json
{
  "orgId": "uuid-v4",
  "name": "ACME Corporation Updated",
  "description": "Updated description",
  "status": "activated",
  "updatedAt": "2025-01-03T10:00:00Z"
}
```

---

#### 5. Get Organization by Code
- **Endpoint:** `GET /organizations/code/{code}`
- **Authentication:** Bearer Token
- **Response (200 OK):**
```json
{
  "orgId": "uuid-v4",
  "name": "ACME Corporation",
  "code": "ACME01",
  "isActive": true
}
```

---

#### 6. Delete Organization
- **Endpoint:** `DELETE /organizations/{orgId}`
- **Authentication:** Bearer Token
- **Response (200 OK):**
```json
{
  "message": "Organization deleted successfully"
}
```

---

## Data Models

### 1. Organization Model

```dart
class Organization {
  final String orgId;
  final String tenantId;
  final String? parentOrgId;
  final String name;
  final String code;
  final String databaseName;
  final String description;
  final String logo;
  final bool isActive;
  final String status;
  final List<String> initialProjects;
  final SuperAdmin? superAdmin;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.orgId,
    required this.tenantId,
    this.parentOrgId,
    required this.name,
    required this.code,
    required this.databaseName,
    required this.description,
    this.logo = '',
    required this.isActive,
    required this.status,
    this.initialProjects = const [],
    this.superAdmin,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['org_id'] ?? json['orgId'] ?? '',
      tenantId: json['tenant_id'] ?? json['tenantId'] ?? '',
      parentOrgId: json['parent_org_id'] ?? json['parentOrgId'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      databaseName: json['database_name'] ?? json['databaseName'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      status: json['status'] ?? 'activated',
      initialProjects: (json['initial_projects'] ?? json['initialProjects'] ?? [])
          .cast<String>(),
      superAdmin: json['super_admin'] != null || json['superAdmin'] != null
          ? SuperAdmin.fromJson(json['super_admin'] ?? json['superAdmin'])
          : null,
      createdBy: json['created_by'] ?? json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'tenant_id': tenantId,
      if (parentOrgId != null) 'parent_org_id': parentOrgId,
      'name': name,
      'code': code,
      'database_name': databaseName,
      'description': description,
      'logo': logo,
      'is_active': isActive,
      'status': status,
      'initial_projects': initialProjects,
      if (superAdmin != null) 'super_admin': superAdmin!.toJson(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isParent => parentOrgId == null || parentOrgId!.isEmpty;
  bool get isChild => !isParent;
  String get displayStatus => isActive ? 'Active' : 'Inactive';
}
```

---

### 2. Create Organization Request

```dart
class CreateOrganizationRequest {
  final String? tenantId;
  final String? parentOrgId;
  final String name;
  final String code;
  final String description;
  final SuperAdminRequest superAdmin;
  final List<String> initialProjects;
  final String? createdBy;

  CreateOrganizationRequest({
    this.tenantId,
    this.parentOrgId,
    required this.name,
    required this.code,
    required this.description,
    required this.superAdmin,
    this.initialProjects = const [],
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      if (tenantId != null && tenantId!.isNotEmpty) 'tenantId': tenantId,
      if (parentOrgId != null && parentOrgId!.isNotEmpty) 'parentOrgId': parentOrgId,
      'name': name,
      'code': code,
      'description': description,
      'super_admin': superAdmin.toJson(),
      'initial_projects': initialProjects,
      if (createdBy != null && createdBy!.isNotEmpty) 'createdBy': createdBy,
    };
  }
}
```

---

## Implementation

### 1. Load Organizations with Hierarchy

```dart
Future<void> loadOrganizationsWithChildren() async {
  setLoading(true);
  setError(null);

  try {
    final tenantId = await JwtTokenManager.getTenantId();
    if (tenantId == null) {
      throw Exception('Tenant ID not found');
    }

    // Load parent organizations
    final response = await _repository.getOrganizationsByTenant(tenantId);

    if (response.success && response.data != null) {
      final parentOrgs = response.data!.organizations;
      final allOrgs = <Organization>[];

      // Add parent organizations
      allOrgs.addAll(parentOrgs);

      // Load children for each parent
      for (final parent in parentOrgs) {
        try {
          final childResponse = await _repository.getChildOrganizations(parent.orgId);
          if (childResponse.success && childResponse.data != null) {
            allOrgs.addAll(childResponse.data!.organizations);
          }
        } catch (e) {
          print('Error loading children for ${parent.name}: $e');
        }
      }

      // Sort: parents first, then children
      allOrgs.sort((a, b) {
        if (a.isParent && b.isChild) return -1;
        if (a.isChild && b.isParent) return 1;
        return a.name.compareTo(b.name);
      });

      _organizations = allOrgs;
      setLoading(false);
      notifyListeners();
    } else {
      setError(response.message ?? 'Failed to load organizations');
      setLoading(false);
    }
  } catch (e) {
    setError('Error loading organizations: $e');
    setLoading(false);
  }
}
```

---

### 2. Create Child Organization

```dart
Future<ApiResponse> createChildOrganization({
  required String parentOrgId,
  required String name,
  required String code,
  required String description,
  required List<String> projects,
}) async {
  try {
    // Get current user data
    final userName = await JwtTokenManager.getName();
    final userEmail = await JwtTokenManager.getEmail();
    final tenantId = await JwtTokenManager.getTenantId();

    if (userName == null || userEmail == null || tenantId == null) {
      throw Exception('User data not available');
    }

    // Create super admin request (no password for child orgs)
    final superAdmin = SuperAdminRequest(
      name: userName,
      email: userEmail,
      password: '',
    );

    // Create organization request
    final request = CreateOrganizationRequest(
      tenantId: tenantId,
      parentOrgId: parentOrgId,
      name: name,
      code: code,
      description: description,
      superAdmin: superAdmin,
      initialProjects: projects,
      createdBy: userName,
    );

    // Call API
    final response = await _repository.createOrganization(request);

    if (response.success) {
      // Reload organizations
      await loadOrganizationsWithChildren();
    }

    return response;
  } catch (e) {
    return ApiResponse.error(message: 'Error creating organization: $e');
  }
}
```

---

### 3. Switch Organization

```dart
Future<ApiResponse> switchOrganization(Organization organization) async {
  try {
    // Save organization ID
    await JwtTokenManager.saveOrgId(organization.orgId);

    // Update current organization
    _currentOrganization = organization;
    notifyListeners();

    return ApiResponse.success(
      message: 'Switched to ${organization.name}',
    );
  } catch (e) {
    return ApiResponse.error(
      message: 'Error switching organization: $e',
    );
  }
}
```

---

## Usage Examples

### 1. Organization List Page

```dart
class OrganizationListPage extends StatefulWidget {
  @override
  _OrganizationListPageState createState() => _OrganizationListPageState();
}

class _OrganizationListPageState extends State<OrganizationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizationHierarchyService>().loadOrganizationsWithChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Organizations')),
      body: Consumer<OrganizationHierarchyService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (service.error != null) {
            return Center(child: Text('Error: ${service.error}'));
          }

          if (service.organizations.isEmpty) {
            return Center(child: Text('No organizations found'));
          }

          return ListView.builder(
            itemCount: service.organizations.length,
            itemBuilder: (context, index) {
              final org = service.organizations[index];
              return OrganizationCard(organization: org);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

### 2. Organization Card Widget

```dart
class OrganizationCard extends StatelessWidget {
  final Organization organization;

  const OrganizationCard({required this.organization});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(
          organization.isParent ? Icons.account_tree : Icons.subdirectory_arrow_right,
          color: organization.isParent ? Colors.blue : Colors.green,
        ),
        title: Row(
          children: [
            if (organization.isChild) SizedBox(width: 24),
            Text(organization.name),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${organization.code}'),
            Text('Status: ${organization.displayStatus}'),
            if (organization.isChild)
              Text('Parent Organization', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(organization.isParent ? 'Parent' : 'Child'),
              backgroundColor: organization.isParent
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _editOrganization(context, organization),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Best Practices

1. **Always load organizations with hierarchy** to show complete structure
2. **Validate organization codes** before creation (must be unique)
3. **Handle parent-child relationships** carefully during deletion
4. **Use proper error handling** for API failures
5. **Implement search and filter** for large organization lists
6. **Show visual hierarchy** with indentation and icons
7. **Validate permissions** before allowing organization operations

---

**Last Updated:** December 2025  
**Version:** 1.0.0
