# NHIT ERP System - Complete Documentation

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Getting Started](#getting-started)
4. [Features Documentation](#features-documentation)
5. [API Integration](#api-integration)
6. [Deployment Guide](#deployment-guide)

---

## Project Overview

**Project Name:** NHIT ERP System  
**Version:** 1.0.0+1  
**Framework:** Flutter 3.8.1  
**Package Name:** ppv_components  
**Platform Support:** Windows, Web, Android, iOS, macOS, Linux

### Purpose
A comprehensive Enterprise Resource Planning (ERP) system built with Flutter for managing organizational operations including:
- Multi-tenant organization management
- User authentication and authorization
- Department and designation management
- Vendor management
- Payment and expense tracking
- Role-based access control
- Activity logging and audit trails

### Technology Stack

#### Frontend
- **Flutter SDK:** 3.8.1
- **State Management:** Provider 6.1.5
- **Routing:** GoRouter 16.2.0
- **UI Framework:** Material Design 3
- **Typography:** Google Fonts 6.3.1

#### Backend Integration
- **HTTP Client:** Dio 5.9.0
- **API Architecture:** RESTful microservices
- **Base URL:** http://192.168.1.51:8083/api/v1
- **Authentication:** JWT (JSON Web Tokens)
- **Secure Storage:** flutter_secure_storage 9.2.4

#### Key Dependencies
```yaml
dependencies:
  - provider: ^6.1.5+1          # State management
  - go_router: ^16.2.0          # Navigation
  - dio: ^5.9.0                 # HTTP client
  - flutter_secure_storage: ^9.2.4  # Secure token storage
  - jwt_decoder: ^2.0.1         # JWT token handling
  - google_sign_in: ^7.2.0      # Google SSO
  - data_table_2: ^2.5.8        # Advanced tables
  - file_picker: ^10.3.1        # File operations
  - pdf: ^3.11.3                # PDF generation
  - printing: ^5.14.2           # Print functionality
  - intl: ^0.20.2               # Internationalization
```

---

## Architecture

### Project Structure
```
lib/
├── app/                    # Application configuration
│   └── router.dart        # Route definitions
├── common_widgets/        # Reusable UI components
│   ├── sidebar.dart       # Navigation sidebar
│   ├── navbar.dart        # Top navigation bar
│   └── layout_page.dart   # Main layout wrapper
├── core/                  # Core utilities and services
│   ├── constants/         # API endpoints, app constants
│   ├── services/          # Core services (API, JWT)
│   ├── utils/             # Helper functions
│   └── providers/         # Global providers
├── features/              # Feature modules
│   ├── auth/             # Authentication
│   ├── organization/     # Organization management
│   ├── department/       # Department management
│   ├── designation/      # Designation management
│   ├── vendor/           # Vendor management
│   ├── roles/            # Role & permission management
│   ├── user/             # User management
│   ├── dashboard/        # Dashboard
│   ├── payment_notes/    # Payment processing
│   ├── expense/          # Expense management
│   ├── reimbursement/    # Reimbursement
│   ├── bank_rtgs_neft/   # Banking operations
│   └── activity/         # Activity logs
└── main.dart             # Application entry point
```

### Feature Module Structure
Each feature follows a clean architecture pattern:
```
feature/
├── data/
│   ├── models/           # Data models
│   └── repositories/     # API repositories
├── services/             # Business logic services
├── providers/            # State providers
├── widgets/              # Feature-specific widgets
└── pages/                # Feature screens
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK (included with Flutter)
- IDE: VS Code or Android Studio
- Git for version control

### Installation

1. **Clone the Repository**
```bash
git clone <repository-url>
cd nhit_redesign_org_created_working_lt
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Run Code Generation** (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the Application**
```bash
# For Windows
flutter run -d windows

# For Web
flutter run -d chrome

# For Android
flutter run -d <device-id>
```

### Environment Configuration

#### API Configuration
Update `lib/core/constants/api_constants.dart`:
```dart
static const String authBaseUrl = 'http://192.168.1.51:8083/api/v1';
```

For Android emulator, use:
```dart
static const String androidAuthBaseUrl = 'http://10.0.2.2:8083/api/v1';
```

---

## Features Documentation

### Core Features
1. [Authentication System](./01-AUTHENTICATION.md)
2. [Organization Management](./02-ORGANIZATION-MANAGEMENT.md)
3. [Department Management](./03-DEPARTMENT-MANAGEMENT.md)
4. [Designation Management](./04-DESIGNATION-MANAGEMENT.md)
5. [Vendor Management](./05-VENDOR-MANAGEMENT.md)
6. [Role & Permission Management](./06-ROLE-MANAGEMENT.md)
7. [User Management](./07-USER-MANAGEMENT.md)
8. [Dashboard](./08-DASHBOARD.md)
9. [Payment & Expense Management](./09-PAYMENT-EXPENSE.md)
10. [Activity Logs](./10-ACTIVITY-LOGS.md)

### UI Components
- [Sidebar Navigation](./UI-COMPONENTS.md#sidebar)
- [Navbar](./UI-COMPONENTS.md#navbar)
- [Data Tables](./UI-COMPONENTS.md#tables)
- [Forms](./UI-COMPONENTS.md#forms)
- [Dialogs](./UI-COMPONENTS.md#dialogs)

---

## API Integration

### Base Configuration
- **Base URL:** http://192.168.1.51:8083/api/v1
- **Protocol:** HTTPS (production), HTTP (development)
- **Authentication:** Bearer Token (JWT)
- **Content-Type:** application/json

### API Services
- Authentication Service (Port 8051)
- User Service (Port 8052)
- Organization Service (Port 8053)
- Department Service (Port 8054)
- Designation Service (Port 8055)
- Vendor Service (Port 8056)

See [API Integration Guide](./API-INTEGRATION.md) for detailed endpoint documentation.

---

## Deployment Guide

### Production Build

#### Windows
```bash
flutter build windows --release
```

#### Web
```bash
flutter build web --release
```

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### Environment Variables
Configure production API endpoints before building:
```dart
// lib/core/constants/api_constants.dart
static const String authBaseUrl = 'https://api.production.com/api/v1';
```

See [Deployment Guide](./DEPLOYMENT-GUIDE.md) for detailed instructions.

---

## Support & Maintenance

### Version History
- **v1.0.0** - Initial release with core features

### Contact
For technical support or questions, contact the development team.

---

## License
Proprietary - All rights reserved

---

**Last Updated:** December 2025  
**Maintained By:** NHIT Development Team
