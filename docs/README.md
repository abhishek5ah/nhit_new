# JWT Authentication System Documentation

## Overview

This document provides comprehensive documentation for the 3-step Super Admin registration system implemented in the Flutter ERP application.

## 🎯 Authentication Flow

### Step 1: Super Admin Registration
- **Route**: `/register-super-admin`
- **Purpose**: Create super admin account
- **API**: `POST http://localhost:8051/api/v1/auth/register`
- **Next Step**: Redirect to `/create-organization`

### Step 2: Organization Creation
- **Route**: `/create-organization`
- **Purpose**: Create organization and get tenant_id
- **API**: `POST http://localhost:8083/api/v1/organizations`
- **Next Step**: Redirect to `/payment-notes` (main dashboard)

### Step 3: Login (Existing Super Admin)
- **Route**: `/login`
- **Purpose**: Login existing super admin
- **API**: `POST http://localhost:8051/api/v1/auth/login`
- **Next Step**: Direct access to `/payment-notes`

## 📁 File Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── api_service.dart
│   │   ├── jwt_token_manager.dart
│   │   ├── google_auth_service.dart
│   │   └── microsoft_auth_service.dart
│   └── utils/
│       └── api_response.dart
├── features/auth/
│   ├── data/
│   │   ├── models/
│   │   │   ├── super_admin_register_request.dart
│   │   │   ├── create_organization_request.dart
│   │   │   ├── organization_response.dart
│   │   │   ├── login_request.dart
│   │   │   ├── auth_response.dart
│   │   │   └── user_model.dart
│   │   └── repositories/
│   │       └── auth_repository.dart
│   ├── domain/
│   │   └── entities/
│   │       └── user_entity.dart
│   └── presentation/
│       ├── pages/
│       │   ├── register_super_admin_page.dart
│       │   ├── create_organization_page.dart
│       │   ├── login_page.dart
│       │   ├── forgot_password_page.dart
│       │   └── verify_email_page.dart
│       └── widgets/
│           ├── auth_text_field.dart
│           ├── social_login_button.dart
│           └── divider_with_text.dart
└── app/
    └── router.dart
```

## 🔧 Configuration

### API Endpoints
- **Auth Service**: `http://localhost:8051/api/v1`
- **Main Service**: `http://localhost:8083/api/v1`

### Dependencies Required
```yaml
dependencies:
  dio: ^5.9.0
  flutter_secure_storage: ^9.2.4
  jwt_decoder: ^2.0.1
  google_sign_in: ^7.2.0
  go_router: ^16.2.0
```

## 🚀 Getting Started

1. **Start Backend Services**:
   - Auth service on port 8051
   - Main service on port 8083

2. **Run Flutter App**:
   ```bash
   flutter pub get
   flutter run
   ```

3. **Test Flow**:
   - Navigate to `/login`
   - Click "Sign up" → `/register-super-admin`
   - Fill form → Continue to `/create-organization`
   - Create organization → Access `/payment-notes`

## 📖 Detailed Documentation

For detailed information about each component, see the individual documentation files:

- [API Constants](./api_constants.md)
- [JWT Token Manager](./jwt_token_manager.md)
- [Auth Service](./auth_service.md)
- [API Service](./api_service.md)
- [Auth Repository](./auth_repository.md)
- [Data Models](./data_models.md)
- [UI Pages](./ui_pages.md)
- [Router Configuration](./router.md)
