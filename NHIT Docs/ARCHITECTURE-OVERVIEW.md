# Architecture Overview

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
│                    (Multi-Platform Client)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ HTTPS/HTTP
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                   API Gateway / Load Balancer                │
│                  (http://192.168.1.51:8083)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
┌───────▼────┐  ┌──────▼─────┐  ┌────▼──────┐
│   Auth     │  │Organization│  │  Vendor   │
│  Service   │  │  Service   │  │  Service  │
│ (Port 8051)│  │(Port 8053) │  │(Port 8056)│
└────────────┘  └────────────┘  └───────────┘
        │              │              │
┌───────▼────┐  ┌──────▼─────┐  ┌────▼──────┐
│   User     │  │ Department │  │   Roles   │
│  Service   │  │  Service   │  │  Service  │
│ (Port 8052)│  │(Port 8054) │  │(Port 8057)│
└────────────┘  └────────────┘  └───────────┘
        │              │              │
        └──────────────┼──────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                     Database Layer                           │
│              (PostgreSQL / MySQL / MongoDB)                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Application Architecture

### Layer Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Pages   │  │ Widgets  │  │ Dialogs  │  │  Forms   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                    Business Logic Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Services │  │Providers │  │Validators│  │  Utils   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Models  │  │Repository│  │API Client│  │  Cache   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                      Core Layer                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │Constants │  │  Config  │  │  Storage │  │  Network │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
lib/
├── app/
│   ├── router.dart                 # Route configuration
│   └── theme.dart                  # App theme
│
├── common_widgets/
│   ├── sidebar.dart                # Navigation sidebar
│   ├── navbar.dart                 # Top navigation bar
│   ├── layout_page.dart            # Main layout wrapper
│   ├── button/
│   │   ├── primary_button.dart
│   │   └── secondary_button.dart
│   └── dropdown.dart
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # API endpoints
│   │   └── app_constants.dart      # App constants
│   │
│   ├── services/
│   │   ├── api_service.dart        # HTTP client
│   │   └── jwt_token_manager.dart  # Token management
│   │
│   ├── utils/
│   │   ├── api_response.dart       # Response wrapper
│   │   └── validators.dart         # Input validators
│   │
│   └── providers/
│       └── persistent_form_provider.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── login_request.dart
│   │   │   │   ├── login_response.dart
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   └── pages/
│   │       ├── login_page.dart
│   │       └── signup_page.dart
│   │
│   ├── organization/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── organization_hierarchy_models.dart
│   │   │   └── repositories/
│   │   │       └── organization_hierarchy_repository.dart
│   │   ├── services/
│   │   │   └── organization_hierarchy_service.dart
│   │   ├── widgets/
│   │   │   └── organization_card.dart
│   │   └── pages/
│   │       ├── organization_main_page.dart
│   │       └── create_organization_page.dart
│   │
│   ├── department/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── department_models.dart
│   │   │   └── repositories/
│   │   │       └── department_repository.dart
│   │   ├── services/
│   │   │   └── department_provider.dart
│   │   ├── widgets/
│   │   │   └── add_department_form.dart
│   │   └── pages/
│   │       └── department_page.dart
│   │
│   ├── designation/
│   │   ├── data/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── pages/
│   │
│   ├── vendor/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── vendor_api_models.dart
│   │   │   └── repositories/
│   │   │       └── vendor_api_repository.dart
│   │   ├── services/
│   │   │   └── vendor_api_service.dart
│   │   ├── providers/
│   │   │   └── create_vendor_form_provider.dart
│   │   ├── widgets/
│   │   │   └── add_vendor_form.dart
│   │   └── pages/
│   │       └── vendor_page.dart
│   │
│   ├── roles/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── role_models.dart
│   │   │   └── repositories/
│   │   │       └── roles_api_repository.dart
│   │   └── services/
│   │       └── roles_api_service.dart
│   │
│   ├── user/
│   ├── dashboard/
│   ├── payment_notes/
│   ├── expense/
│   ├── reimbursement/
│   ├── bank_rtgs_neft/
│   └── activity/
│
└── main.dart                       # Application entry point
```

---

## Design Patterns

### 1. Repository Pattern

**Purpose:** Separate data access logic from business logic

**Implementation:**
```dart
// Repository handles API calls
class VendorApiRepository {
  final Dio _dio;

  Future<ApiResponse<VendorApiModel>> createVendor(
      CreateVendorRequest request) async {
    // API call logic
  }
}

// Service uses repository
class VendorApiService {
  final VendorApiRepository _repository = VendorApiRepository();

  Future<void> createVendor(VendorApiModel vendor) async {
    final response = await _repository.createVendor(request);
    // Handle response
  }
}
```

---

### 2. Provider Pattern (State Management)

**Purpose:** Reactive state management using ChangeNotifier

**Implementation:**
```dart
class VendorApiService extends ChangeNotifier {
  List<VendorApiModel> _vendors = [];
  bool _isLoading = false;

  List<VendorApiModel> get vendors => _vendors;
  bool get isLoading => _isLoading;

  Future<void> loadVendors() async {
    _isLoading = true;
    notifyListeners(); // Notify UI

    // Load data
    _vendors = await _repository.getVendors();
    
    _isLoading = false;
    notifyListeners(); // Notify UI
  }
}

// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => VendorApiService()),
  ],
  child: MyApp(),
)

// In UI
Consumer<VendorApiService>(
  builder: (context, service, child) {
    if (service.isLoading) return CircularProgressIndicator();
    return ListView(children: service.vendors.map(...));
  },
)
```

---

### 3. Singleton Pattern

**Purpose:** Single instance of services

**Implementation:**
```dart
class JwtTokenManager {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
}
```

---

### 4. Factory Pattern

**Purpose:** Object creation from JSON

**Implementation:**
```dart
class Organization {
  final String orgId;
  final String name;

  Organization({required this.orgId, required this.name});

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      orgId: json['org_id'] ?? json['orgId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'name': name,
    };
  }
}
```

---

## State Management

### Provider Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Consumer<Service>                       │   │
│  │  Listens to changes and rebuilds UI                  │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ notifyListeners()
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                   Service Layer                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         ChangeNotifier Service                       │   │
│  │  - Manages state                                     │   │
│  │  - Calls repositories                                │   │
│  │  - Notifies listeners on state change                │   │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ API calls
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Repository Layer                            │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              API Repository                          │   │
│  │  - Makes HTTP requests                               │   │
│  │  - Returns ApiResponse<T>                            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### State Flow Example

```dart
// 1. UI triggers action
ElevatedButton(
  onPressed: () {
    context.read<VendorApiService>().createVendor(vendor);
  },
)

// 2. Service processes
class VendorApiService extends ChangeNotifier {
  Future<void> createVendor(VendorApiModel vendor) async {
    _isLoading = true;
    notifyListeners(); // UI shows loading

    final response = await _repository.createVendor(request);
    
    if (response.success) {
      _vendors.add(response.data);
    }

    _isLoading = false;
    notifyListeners(); // UI updates
  }
}

// 3. UI reacts to changes
Consumer<VendorApiService>(
  builder: (context, service, child) {
    if (service.isLoading) {
      return CircularProgressIndicator();
    }
    return VendorList(vendors: service.vendors);
  },
)
```

---

## Routing Architecture

### GoRouter Configuration

```dart
final router = GoRouter(
  refreshListenable: AuthNotifier(authService),
  redirect: (context, state) async {
    final isAuthenticated = await authService.isAuthenticated();
    final isAuthRoute = authRoutes.contains(state.matchedLocation);

    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    if (isAuthenticated && isAuthRoute) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    // Public routes
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),

    // Protected routes with layout
    ShellRoute(
      builder: (context, state, child) => LayoutPage(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => DashboardPage(),
        ),
        GoRoute(
          path: '/vendors',
          builder: (context, state) => VendorPage(),
        ),
        GoRoute(
          path: '/vendors/create',
          builder: (context, state) => CreateVendorScreen(),
        ),
      ],
    ),
  ],
);
```

### Route Protection Flow

```
User navigates to /dashboard
        ↓
GoRouter redirect callback
        ↓
Check authentication status
        ↓
    ┌───────┴───────┐
    │               │
Authenticated   Not Authenticated
    │               │
    ↓               ↓
Allow access   Redirect to /login
```

---

## Security Architecture

### Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Login Request                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              Backend Authentication                          │
│  - Validate credentials                                      │
│  - Generate JWT tokens                                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│             Receive JWT Tokens                               │
│  - Access Token (short-lived)                                │
│  - Refresh Token (long-lived)                                │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│          Store in Secure Storage                             │
│  - flutter_secure_storage                                    │
│  - Encrypted storage                                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│            Add to API Requests                               │
│  Authorization: Bearer <access_token>                        │
│  tenant_id: <tenant_id>                                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                  ┌────┴────┐
                  │         │
            Token Valid  Token Expired
                  │         │
                  ↓         ↓
            Process    Refresh Token
            Request        │
                          ↓
                    New Access Token
                          │
                          ↓
                    Retry Request
```

### Multi-Tenant Isolation

```
Every API Request
        ↓
Auth Interceptor
        ↓
Add tenant_id header
        ↓
Backend validates tenant
        ↓
Return tenant-specific data
```

---

## Data Flow

### CRUD Operation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Component                            │
│  User clicks "Create Vendor"                                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Form Validation                             │
│  - Validate inputs                                           │
│  - Show errors if invalid                                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                Service Layer                                 │
│  vendorService.createVendor(vendorData)                      │
│  - Set loading state                                         │
│  - Call repository                                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│               Repository Layer                               │
│  repository.createVendor(request)                            │
│  - Add auth headers                                          │
│  - Make HTTP POST request                                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Backend API                                 │
│  POST /vendors                                               │
│  - Validate data                                             │
│  - Save to database                                          │
│  - Return response                                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              Process Response                                │
│  - Parse JSON                                                │
│  - Create model object                                       │
│  - Return ApiResponse                                        │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│              Update State                                    │
│  - Add to vendors list                                       │
│  - Set loading = false                                       │
│  - notifyListeners()                                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  UI Updates                                  │
│  - Consumer rebuilds                                         │
│  - Show success message                                      │
│  - Navigate to vendor list                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Performance Optimization

### 1. Lazy Loading
- Load data only when needed
- Paginate large lists
- Use infinite scroll

### 2. Caching
- Cache API responses
- Use shared_preferences for settings
- Implement in-memory cache for frequently accessed data

### 3. State Management
- Use Provider for efficient rebuilds
- Implement selective rebuilds with Consumer
- Avoid unnecessary notifyListeners() calls

### 4. Network Optimization
- Implement request debouncing
- Use connection pooling
- Compress request/response data

---

## Testing Strategy

### Unit Tests
```dart
test('Login with valid credentials', () async {
  final authService = AuthService();
  final result = await authService.login('user@test.com', 'password', 'tenant-id');
  expect(result.success, true);
});
```

### Widget Tests
```dart
testWidgets('Login page shows email field', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  expect(find.byType(TextField), findsNWidgets(3));
});
```

### Integration Tests
```dart
testWidgets('Complete login flow', (tester) async {
  // Test complete user journey
});
```

---

## Deployment Architecture

### Build Process

```
Development
    ↓
Code Review
    ↓
Testing
    ↓
Build (flutter build)
    ↓
Quality Assurance
    ↓
Staging Deployment
    ↓
Production Deployment
```

### Platform-Specific Builds

**Windows:**
```bash
flutter build windows --release
```

**Web:**
```bash
flutter build web --release
```

**Android:**
```bash
flutter build apk --release
flutter build appbundle --release
```

---

**Last Updated:** December 2025  
**Version:** 1.0.0
