# ⚡ Quick Setup Guide - Organizations Module

## 🚀 Step-by-Step Setup (5 minutes)

### Step 1: Update Router (`lib/app/router.dart`)

**Add these imports at the top of the file (around line 30):**

```dart
// Add after existing organization imports
import 'package:ppv_components/features/organization/screens/organizations_list_page.dart';
import 'package:ppv_components/features/organization/screens/create_organization_page.dart';
import 'package:ppv_components/features/organization/screens/organization_detail_page.dart';
import 'package:ppv_components/features/organization/screens/edit_organization_page.dart';
```

**Find the ShellRoute section (around line 130) and add these routes:**

Replace or add after the existing `/organizations` route:

```dart
// Organizations Module - Complete CRUD
GoRoute(
  path: '/organizations',
  builder: (context, state) => const OrganizationsListPage(),
),
GoRoute(
  path: '/organizations/create',
  builder: (context, state) => const CreateOrganizationPage(),
),
GoRoute(
  path: '/organizations/:orgId',
  builder: (context, state) {
    final orgId = state.pathParameters['orgId']!;
    return OrganizationDetailPage(orgId: orgId);
  },
),
GoRoute(
  path: '/organizations/:orgId/edit',
  builder: (context, state) {
    final orgId = state.pathParameters['orgId']!;
    return EditOrganizationPage(orgId: orgId);
  },
),
```

---

### Step 2: Update Main.dart (`lib/main.dart`)

**Add import at the top:**

```dart
import 'package:ppv_components/features/organization/services/organizations_api_service.dart';
```

**Add to the providers list (in MultiProvider):**

Find the `MultiProvider` widget and add:

```dart
ChangeNotifierProvider(
  create: (_) => OrganizationsApiService(),
),
```

It should look like this:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => OrganizationService()),
    ChangeNotifierProvider(create: (_) => OrganizationsApiService()), // 👈 ADD THIS
    // ... other providers
  ],
  child: MaterialApp.router(
    // ...
  ),
)
```

---

### Step 3: Run the App

```bash
# Get dependencies (if needed)
flutter pub get

# Run the app
flutter run
```

---

## 🧪 Quick Test

1. **Start your backend**: Ensure it's running at `http://localhost:8083`

2. **Login to the app** with valid credentials

3. **Navigate to Organizations**:
   - Click "Organizations" in the sidebar
   - OR go to: `http://localhost:XXXX/#/organizations`

4. **Test Create**:
   - Click "Create Organization" button
   - Fill in all required fields
   - Click "Create Organization"
   - ✅ Should redirect to list with new organization

5. **Test View**:
   - Click "View" on any organization card
   - ✅ Should show full organization details

6. **Test Edit**:
   - From detail page, click "Edit Organization"
   - Modify name or description
   - Click "Save Changes"
   - ✅ Should update and redirect

7. **Test Dashboard Real-Time**:
   - Navigate to `/dashboard`
   - Check "Recent Activity" section
   - Wait 1 minute
   - ✅ Time should update automatically

---

## 📋 Checklist

- [ ] Added 4 imports to router.dart
- [ ] Added 4 routes to router.dart (list, create, detail, edit)
- [ ] Added 1 import to main.dart
- [ ] Added OrganizationsApiService to providers
- [ ] Ran `flutter pub get`
- [ ] App compiles without errors
- [ ] Can navigate to /organizations
- [ ] Can create new organization
- [ ] Can view organization details
- [ ] Can edit organization
- [ ] Dashboard time updates automatically

---

## 🔍 Verify It's Working

### Check 1: Routes Added
Navigate to these URLs manually:
- `/organizations` - Should show list page
- `/organizations/create` - Should show create form
- `/organizations/test-id` - Should show detail page (or 404)

### Check 2: API Calls Working
Open Browser DevTools (F12) → Network Tab:

**On /organizations page:**
```
✅ GET /api/v1/tenants/{tenantId}/organizations
✅ Authorization: Bearer {token} header present
✅ 200 OK response
```

**On create:**
```
✅ POST /api/v1/organizations
✅ Authorization: Bearer {token} header present
✅ Request body has all fields
✅ 200/201 response
```

### Check 3: Console Logs
Look for these logs in console:
```
🏢 [OrganizationsApiService] Loading organizations
🔑 [OrganizationsApiService] Using tenant ID: xxx-xxx
✅ [OrganizationsApiService] Loaded X organizations
```

---

## ⚠️ Troubleshooting

### Issue: Import errors
**Solution:** Make sure file paths are correct. All new files are in:
```
lib/features/organization/
├── data/models/organization_api_models.dart
├── data/repositories/organizations_api_repository.dart
├── services/organizations_api_service.dart
└── screens/
    ├── organizations_list_page.dart
    ├── create_organization_page.dart
    ├── organization_detail_page.dart
    └── edit_organization_page.dart
```

### Issue: "No tenant ID found"
**Solution:** 
- Logout and login again
- Check JWT token has `tenantId` in claims
- Verify `JwtTokenManager.getTenantId()` returns value

### Issue: Organizations not loading
**Solution:**
- Verify backend is running at `http://localhost:8083`
- Check API constants in `lib/core/constants/api_constants.dart`
- Verify endpoint: `GET /tenants/{tenantId}/organizations` exists

### Issue: "Provider not found"
**Solution:**
- Ensure `OrganizationsApiService()` is added to providers in main.dart
- Restart the app (hot reload may not work for provider changes)

---

## 🎉 You're Done!

If all checks pass, your Organizations module is fully working!

Next steps:
1. Read `ORGANIZATIONS_MODULE_IMPLEMENTATION.md` for detailed testing guide
2. Test all CRUD operations
3. Verify tenant isolation
4. Check dashboard real-time updates

---

*Setup Time: ~5 minutes*
*Difficulty: Easy*
*Status: Ready to Use! ✅*
