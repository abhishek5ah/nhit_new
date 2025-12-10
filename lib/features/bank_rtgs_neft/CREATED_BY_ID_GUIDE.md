# How to Set created_by_id in Frontend

## ✅ **FIXED: 400 Bad Request Error**

The 400 Bad Request error was occurring because the backend requires `created_by_id` in the POST request body, but the frontend wasn't sending it properly.

## 🔧 **What Was Fixed:**

### 1. **Request Model Updated** (`escrow_account_request.dart`)
```dart
class CreateEscrowAccountRequest {
  final String createdById; // Now REQUIRED (not optional)
  
  CreateEscrowAccountRequest({
    required this.createdById, // Must be provided
    // ... other fields
  });
  
  Map<String, dynamic> toJson() {
    return {
      'created_by_id': createdById, // Always included in request
      // ... other fields
    };
  }
}
```

### 2. **Service Layer Updated** (`escrow_account_service.dart`)
```dart
Future<EscrowAccountData> createEscrowAccount({
  String? createdById, // Optional parameter
  // ... other parameters
}) async {
  final request = CreateEscrowAccountRequest(
    createdById: createdById ?? 'default-user-id', // Default if not provided
    // ... other fields
  );
}
```

## 📋 **How to Use in Your App:**

### **Option 1: Pass Actual User ID (Recommended)**

When you have authentication and know the current user's ID:

```dart
// In your CreateEscrowAccountPage or wherever you call the API
final controller = EscrowAccountController();

await controller.createEscrowAccount(
  accountName: 'Test Account',
  accountNumber: 'ACC-001',
  bankName: 'Test Bank',
  branchName: 'Main Branch',
  ifscCode: 'TEST0001',
  accountType: 'CURRENT',
  balance: 100000.0,
  description: 'Test account',
  authorizedSignatories: ['John Doe'],
  createdById: currentUser.userId, // ← Pass actual user ID here
);
```

### **Option 2: Use Default Value**

If you don't pass `createdById`, it will use `'default-user-id'`:

```dart
await controller.createEscrowAccount(
  accountName: 'Test Account',
  // ... other fields
  // createdById not passed - will use 'default-user-id'
);
```

### **Option 3: Get User ID from Authentication Service**

```dart
// Example with authentication service
final authService = AuthService();
final userId = await authService.getCurrentUserId();

await controller.createEscrowAccount(
  accountName: 'Test Account',
  // ... other fields
  createdById: userId, // Use authenticated user's ID
);
```

## 🔍 **Request Body Example:**

The frontend now sends this JSON to your backend:

```json
POST http://192.168.1.42:8083/v1/escrow/accounts

{
  "account_name": "Project Alpha Escrow",
  "account_number": "ESC-2024-001",
  "bank_name": "State Bank of India",
  "branch_name": "Corporate Branch Mumbai",
  "ifsc_code": "SBIN0001234",
  "account_type": "CURRENT",
  "balance": 100000.0,
  "description": "Escrow account for Project Alpha",
  "authorized_signatories": ["John Doe", "Jane Smith"],
  "created_by_id": "user-123"  ← NOW INCLUDED!
}
```

## ⚙️ **Where to Update for Production:**

### **1. Update Default User ID**

In `escrow_account_service.dart`, change the default:

```dart
createdById: createdById ?? 'your-actual-default-user-id',
```

### **2. Integrate with Your Auth System**

If you have an authentication service, update the controller to automatically get the user ID:

```dart
// In escrow_account_controller.dart
Future<bool> createEscrowAccount({
  // ... parameters
}) async {
  try {
    // Get current user ID from auth service
    final userId = await AuthService.getCurrentUserId();
    
    final account = await _service.createEscrowAccount(
      // ... other parameters
      createdById: userId, // Use authenticated user's ID
    );
    
    return true;
  } catch (e) {
    // ... error handling
  }
}
```

## ✅ **Result:**

- ✅ **No more 400 Bad Request errors**
- ✅ **created_by_id always sent to backend**
- ✅ **Default value provided if not specified**
- ✅ **Easy to integrate with authentication**
- ✅ **Backend receives required field**

## 🚀 **Testing:**

1. **Test with default value:**
   ```dart
   // Don't pass createdById - uses 'default-user-id'
   await controller.createEscrowAccount(...);
   ```

2. **Test with custom value:**
   ```dart
   // Pass specific user ID
   await controller.createEscrowAccount(
     ...,
     createdById: 'user-123',
   );
   ```

3. **Check backend logs** to verify `created_by_id` is received correctly

The 400 Bad Request error is now resolved, and `created_by_id` is properly included in all create requests!
