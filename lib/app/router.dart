import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/app/layout.dart';
import 'package:ppv_components/features/activity/screen/activity_main_page.dart';
import 'package:ppv_components/features/activity/screen/login_history_main_page.dart';
import 'package:ppv_components/features/approval_management/screens/approval_rules_management_page.dart';
import 'package:ppv_components/features/approval_management/screens/approval_rules_page.dart';
import 'package:ppv_components/features/approval_management/screens/create_approval_rule_page.dart';
import 'package:ppv_components/features/auth/presentation/pages/register_organization_page.dart';
import 'package:ppv_components/features/auth/presentation/pages/register_super_admin_page.dart';
import 'package:ppv_components/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:ppv_components/features/auth/presentation/pages/login_page.dart';
import 'package:ppv_components/features/auth/presentation/pages/verify_email_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/account_transfers_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/bank_letter_full_preview.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/bank_letters_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/create_bank_letter_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/create_escrow_account_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/create_transfer_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/widget/escrow_accounts_page.dart';
import 'package:ppv_components/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:ppv_components/features/department/screen/create_department.dart';
import 'package:ppv_components/features/department/screen/department_main_page.dart';
import 'package:ppv_components/features/designation/screen/create_designation.dart';
import 'package:ppv_components/features/designation/screen/designation_main_page.dart';
import 'package:ppv_components/features/expense/screens/all_notes_page.dart';
import 'package:ppv_components/features/expense/screens/create_note_page.dart';
import 'package:ppv_components/features/organization/screens/create_organization.dart';
import 'package:ppv_components/features/organization/screens/organization_main_page.dart';
import 'package:ppv_components/features/payment_notes/screen/create_payment.dart';
import 'package:ppv_components/features/payment_notes/screen/draft_payment.dart';
import 'package:ppv_components/features/payment_notes/screen/payment_notes_main_page.dart';
import 'package:ppv_components/features/reimbursement/widget/create_reimbursement_form.dart';
import 'package:ppv_components/features/reimbursement/widget/reimbursement_table_page.dart';
import 'package:ppv_components/features/roles/screens/create_role.dart';
import 'package:ppv_components/features/roles/screens/roles_main_page.dart';
import 'package:ppv_components/features/user/screens/add_user.dart';
import 'package:ppv_components/features/user/screens/user_main_page.dart';
import 'package:ppv_components/features/vendor/screen/vendor_main_page.dart';
import 'package:ppv_components/features/vendor/widgets/add_vendor_form.dart';
import 'package:ppv_components/core/services/auth_service.dart';
import 'package:ppv_components/core/notifiers/auth_notifier.dart';

// Placeholder widget for pages that don't exist yet
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              '$title Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This page is under construction',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Create AuthNotifier instance
final _authNotifier = AuthNotifier(authService);

final GoRouter router = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authNotifier, // Listen to auth state changes
  redirect: (BuildContext context, GoRouterState state) async {
    print('🔄 [Router] Checking route: ${state.matchedLocation}');

    // Define auth routes (public routes)
    final authRoutes = {
      '/login',
      '/tenants',
      '/register-organization',
      '/forgot-password',
      '/verify-email'
    };

    final isAuthRoute = authRoutes.contains(state.matchedLocation);

    try {
      // Use AuthService's enhanced authentication check
      final isAuthenticated = await authService.checkIsAuthenticated();

      print('🔐 [Router] Authentication status: $isAuthenticated');
      print('📍 [Router] Current route: ${state.matchedLocation}, Is auth route: $isAuthRoute');

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        print('🚫 [Router] Not authenticated, redirecting to login');
        return '/login';
      }

      // If authenticated and trying to access auth routes, redirect to dashboard
      if (isAuthenticated && isAuthRoute) {
        print('✅ [Router] Already authenticated, redirecting to dashboard');
        return '/dashboard';
      }

      print('✅ [Router] Route access allowed');
      return null; // No redirect needed

    } catch (e) {
      print('🚨 [Router] Error in redirect logic: $e');
      // On error, redirect to login for safety
      if (!isAuthRoute) {
        return '/login';
      }
      return null;
    }
  },
  routes: [
    // Authentication Routes
    GoRoute(
      path: '/tenants',
      builder: (context, state) => const RegisterSuperAdminPage(),
    ),
    GoRoute(
      path: '/register-organization',
      builder: (context, state) => const RegisterOrganizationPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/verify-email',
      builder: (context, state) => const VerifyEmailPage(),
    ),

    // Protected Routes (inside ShellRoute - with layout)
    ShellRoute(
      builder: (context, state, child) => LayoutPage(child: child),
      routes: [
        // DASHBOARD
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),

        // EXPENSE MANAGEMENT
        GoRoute(
          path: '/expense/create-note',
          builder: (context, state) => const CreateNotePage (),
        ),
        GoRoute(
          path: '/expense/all-notes',
          builder: (context, state) => const AllNotesPage(),
        ),

        // Payment Notes
        GoRoute(
          path: '/payment-notes/create',
          builder: (context, state) => const CreatePaymentScreen(),
        ),
        GoRoute(
          path: '/payment-notes',
          builder: (context, state) => const PaymentMainPage(),
        ),
        GoRoute(
          path: '/payment-notes/drafts',
          builder: (context, state) => const DraftPaymentScreen(),
        ),

        // APPROVAL RULES
        GoRoute(
          path: '/approval-rules',
          builder: (context, state) => const ApprovalRulesPage(),
        ),
        GoRoute(
          path: '/approval-rules/expense',
          builder: (context, state) => const ApprovalRulesManagementPage(ruleType: 'expense'),
        ),
        GoRoute(
          path: '/approval-rules/expense/create',
          builder: (context, state) => const CreateApprovalRulePage(ruleType: 'expense'),
        ),
        GoRoute(
          path: '/approval-rules/payment',
          builder: (context, state) => const ApprovalRulesManagementPage(ruleType: 'payment'),
        ),
        GoRoute(
          path: '/approval-rules/payment/create',
          builder: (context, state) => const CreateApprovalRulePage(ruleType: 'payment'),
        ),
        GoRoute(
          path: '/approval-rules/reimbursement',
          builder: (context, state) => const ApprovalRulesManagementPage(ruleType: 'reimbursement'),
        ),
        GoRoute(
          path: '/approval-rules/reimbursement/create',
          builder: (context, state) => const CreateApprovalRulePage(ruleType: 'reimbursement'),
        ),

        // Escrow Banking System
        GoRoute(
          path: '/escrow-accounts',
          builder: (context, state) => const EscrowAccountsPage(),
        ),
        GoRoute(
          path: '/escrow-accounts/create',
          builder: (context, state) => const CreateEscrowAccountPage(),
        ),
        GoRoute(
          path: '/escrow/account-transfers',
          builder: (context, state) => const AccountTransfersPage(),
        ),
        GoRoute(
          path: '/escrow/create',
          builder: (context, state) => const CreateTransferPage(),
        ),
        GoRoute(
          path: '/escrow/bank-letter',
          builder: (context, state) => const BankLettersPage(),
        ),
        GoRoute(
          path: '/escrow/bank-letter/create',
          builder: (context, state) => const CreateBankLetterPage(),
        ),
        GoRoute(
          path: '/escrow/bank-letter/preview/:id',
          builder: (context, state) {
            final letterId = state.pathParameters['id'] ?? '';
            return BankLetterFullPreview(letterId: letterId);
          },
        ),

        // Travel & Reimbursement
        GoRoute(
          path: '/reimbursement-note/create',
          builder: (context, state) => const ReimbursementForm(),
        ),
        GoRoute(
          path: '/reimbursement-note',
          builder: (context, state) => const ReimbursementTablePage(),
        ),

        // MANAGEMENT
        // Organization Management
        GoRoute(
          path: '/organizations',
          builder: (context, state) => const OrganizationMainPage(),
        ),

        // User Management
        GoRoute(
          path: '/users',
          builder: (context, state) => const UserMainPage(),
        ),
        GoRoute(
          path: '/users/create',
          builder: (context, state) => const CreateUserScreen(),
        ),

        // Role Management
        GoRoute(
          path: '/roles',
          builder: (context, state) => const RoleMainPage(),
        ),
        GoRoute(
          path: '/roles/create',
          builder: (context, state) => const CreateRoleScreen(),
        ),

        // Departments
        GoRoute(
          path: '/department',
          builder: (context, state) => const DepartmentMainPage(),
        ),
        GoRoute(
          path: '/department/create',
          builder: (context, state) => const CreateDepartmentScreen(),
        ),

        // Designations
        GoRoute(
          path: '/designations',
          builder: (context, state) => const DesignationMainPage(),
        ),
        GoRoute(
          path: '/designations/create',
          builder: (context, state) => const CreateDesignationScreen(),
        ),

        // Vendor Management
        GoRoute(
          path: '/vendors',
          builder: (context, state) => const VendorMainPage(),
        ),
        GoRoute(
          path: '/vendors/create',
          builder: (context, state) => const CreateVendorScreen(),
        ),

        // Organization Management
        GoRoute(
          path: '/organizations',
          builder: (context, state) => const OrganizationMainPage(),
        ),
        GoRoute(
          path: '/organizations/create',
          builder: (context, state) => const CreateOrganizationScreen(),
        ),

        // ACTIVITY & REPORTS
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityMainPage(),
        ),
        GoRoute(
          path: '/login-history',
          builder: (context, state) => const LoginHistoryMainPage(),
        ),
      ],
    ),
  ],
);








//////////////////////////////////////////      BYPASS   //////////////////////////////////////
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:ppv_components/app/layout.dart';
// import 'package:ppv_components/features/activity/screen/activity_main_page.dart';
// import 'package:ppv_components/features/activity/screen/login_history_main_page.dart';
// import 'package:ppv_components/features/approval_management/screens/approval_rules_management_page.dart';
// import 'package:ppv_components/features/approval_management/screens/approval_rules_page.dart';
// import 'package:ppv_components/features/approval_management/screens/create_approval_rule_page.dart';
// import 'package:ppv_components/features/auth/presentation/pages/register_organization_page.dart';
// import 'package:ppv_components/features/auth/presentation/pages/register_super_admin_page.dart';
// import 'package:ppv_components/features/auth/presentation/pages/forgot_password_page.dart';
// import 'package:ppv_components/features/auth/presentation/pages/login_page.dart';
// import 'package:ppv_components/features/auth/presentation/pages/verify_email_page.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/account_transfers_page.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/bank_letter_full_preview.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/bank_letters_page.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/create_bank_letter_page.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/create_escrow_account_page.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/create_transfer_page.dart';
// import 'package:ppv_components/features/bank_rtgs_neft/widget/escrow_accounts_page.dart';
// import 'package:ppv_components/features/dashboard/presentation/pages/dashboard_page.dart';
// import 'package:ppv_components/features/department/screen/create_department.dart';
// import 'package:ppv_components/features/department/screen/department_main_page.dart';
// import 'package:ppv_components/features/designation/screen/create_designation.dart';
// import 'package:ppv_components/features/designation/screen/designation_main_page.dart';
// import 'package:ppv_components/features/expense/screens/all_notes_page.dart';
// import 'package:ppv_components/features/expense/screens/create_note_page.dart';
// import 'package:ppv_components/features/organization/screens/create_organization.dart';
// import 'package:ppv_components/features/organization/screens/organization_main_page.dart';
// import 'package:ppv_components/features/payment_notes/screen/create_payment.dart';
// import 'package:ppv_components/features/payment_notes/screen/draft_payment.dart';
// import 'package:ppv_components/features/payment_notes/screen/payment_notes_main_page.dart';
// import 'package:ppv_components/features/reimbursement/widget/create_reimbursement_form.dart';
// import 'package:ppv_components/features/reimbursement/widget/reimbursement_table_page.dart';
// import 'package:ppv_components/features/roles/screens/create_role.dart';
// import 'package:ppv_components/features/roles/screens/roles_main_page.dart';
// import 'package:ppv_components/features/user/screens/add_user.dart';
// import 'package:ppv_components/features/user/screens/user_main_page.dart';
// import 'package:ppv_components/features/vendor/screen/vendor_main_page.dart';
// import 'package:ppv_components/features/vendor/widgets/add_vendor_form.dart';
// import 'package:ppv_components/core/services/auth_service.dart';
// import 'package:ppv_components/core/notifiers/auth_notifier.dart';
//
// // Placeholder widget for pages that don't exist yet
// class PlaceholderPage extends StatelessWidget {
//   final String title;
//   const PlaceholderPage({super.key, required this.title});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.construction, size: 100, color: Colors.grey),
//             SizedBox(height: 20),
//             Text(
//               '$title Page',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'This page is under construction',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Create AuthNotifier instance
// final _authNotifier = AuthNotifier(authService);
//
// final GoRouter router = GoRouter(
//   // 🛑 CHANGE 1: Set initial location to dashboard to bypass login screen
//   initialLocation: '/dashboard',
//   refreshListenable: _authNotifier,
//
//   // 🛑 CHANGE 2: Temporarily disable the authentication redirect logic
//   redirect: (BuildContext context, GoRouterState state) async {
//     // =========================================================================
//     // >>>>>>>>>>>>>>>>>> TEMPORARY AUTH BYPASS ACTIVE <<<<<<<<<<<<<<<<<<<
//     // Uncomment the block below to re-enable authentication check.
//     print('⚠️ [Router] Authentication Bypassed. Direct access granted.');
//     return null;
//     // =========================================================================
//
//     /*
//   // 🛑 ORIGINAL REDIRECT LOGIC (COMMENTED OUT)
//   print('🔄 [Router] Checking route: ${state.matchedLocation}');
//
//   // Define auth routes (public routes)
//   final authRoutes = {
//    '/login',
//    '/tenants',
//    '/register-organization',
//    '/forgot-password',
//    '/verify-email'
//   };
//
//   final isAuthRoute = authRoutes.contains(state.matchedLocation);
//
//   try {
//    // Use AuthService's enhanced authentication check
//    final isAuthenticated = await authService.checkIsAuthenticated();
//
//    print('🔐 [Router] Authentication status: $isAuthenticated');
//    print('📍 [Router] Current route: ${state.matchedLocation}, Is auth route: $isAuthRoute');
//
//    // If not authenticated and trying to access protected route
//    if (!isAuthenticated && !isAuthRoute) {
//  print('🚫 [Router] Not authenticated, redirecting to login');
//  return '/login';
//    }
//
//    // If authenticated and trying to access auth routes, redirect to dashboard
//    if (isAuthenticated && isAuthRoute) {
//  print('✅ [Router] Already authenticated, redirecting to dashboard');
//  return '/dashboard';
//    }
//
//    print('✅ [Router] Route access allowed');
//    return null; // No redirect needed
//
//   } catch (e) {
//    print('🚨 [Router] Error in redirect logic: $e');
//    // On error, redirect to login for safety
//    if (!isAuthRoute) {
//  return '/login';
//    }
//    return null;
//   }
//   */
//   },
//
//   routes: [
//     // Authentication Routes (KEEP THEM HERE for manual navigation if needed)
//     GoRoute(
//       path: '/tenants',
//       builder: (context, state) => const RegisterSuperAdminPage(),
//     ),
//     GoRoute(
//       path: '/register-organization',
//       builder: (context, state) => const RegisterOrganizationPage(),
//     ),
//     GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
//     GoRoute(
//       path: '/forgot-password',
//       builder: (context, state) => const ForgotPasswordPage(),
//     ),
//     GoRoute(
//       path: '/verify-email',
//       builder: (context, state) => const VerifyEmailPage(),
//     ),
//
//     // Protected Routes (inside ShellRoute - with layout)
//     ShellRoute(
//       builder: (context, state, child) => LayoutPage(child: child),
//       routes: [
//         // DASHBOARD
//         GoRoute(
//           path: '/dashboard',
//           builder: (context, state) => const DashboardPage(),
//         ),
//
//         // EXPENSE MANAGEMENT
//         GoRoute(
//           path: '/expense/create-note',
//           builder: (context, state) => const CreateNotePage(),
//         ),
//         GoRoute(
//           path: '/expense/all-notes',
//           builder: (context, state) => const AllNotesPage(),
//         ),
//
//         // Payment Notes
//         GoRoute(
//           path: '/payment-notes/create',
//           builder: (context, state) => const CreatePaymentScreen(),
//         ),
//         GoRoute(
//           path: '/payment-notes',
//           builder: (context, state) => const PaymentMainPage(),
//         ),
//         GoRoute(
//           path: '/payment-notes/drafts',
//           builder: (context, state) => const DraftPaymentScreen(),
//         ),
//
//         // APPROVAL RULES
//         GoRoute(
//           path: '/approval-rules',
//           builder: (context, state) => const ApprovalRulesPage(),
//         ),
//         GoRoute(
//           path: '/approval-rules/expense',
//           builder: (context, state) =>
//               const ApprovalRulesManagementPage(ruleType: 'expense'),
//         ),
//         GoRoute(
//           path: '/approval-rules/expense/create',
//           builder: (context, state) =>
//               const CreateApprovalRulePage(ruleType: 'expense'),
//         ),
//         GoRoute(
//           path: '/approval-rules/payment',
//           builder: (context, state) =>
//               const ApprovalRulesManagementPage(ruleType: 'payment'),
//         ),
//         GoRoute(
//           path: '/approval-rules/payment/create',
//           builder: (context, state) =>
//               const CreateApprovalRulePage(ruleType: 'payment'),
//         ),
//         GoRoute(
//           path: '/approval-rules/reimbursement',
//           builder: (context, state) =>
//               const ApprovalRulesManagementPage(ruleType: 'reimbursement'),
//         ),
//         GoRoute(
//           path: '/approval-rules/reimbursement/create',
//           builder: (context, state) =>
//               const CreateApprovalRulePage(ruleType: 'reimbursement'),
//         ),
//
//         // Escrow Banking System
//         GoRoute(
//           path: '/escrow-accounts',
//           builder: (context, state) =>
//               const EscrowAccountsPage(),
//         ),
//         GoRoute(
//           path: '/escrow-accounts/create',
//           builder: (context, state) =>
//               const CreateEscrowAccountPage(),
//         ),
//         GoRoute(
//           path: '/escrow/account-transfers',
//           builder: (context, state) =>
//               const AccountTransfersPage(),
//         ),
//         GoRoute(
//           path: '/escrow/create',
//           builder: (context, state) =>
//               const CreateTransferPage(),
//         ),
//         GoRoute(
//           path: '/escrow/bank-letter',
//           builder: (context, state) =>
//               const BankLettersPage()
//         ),
//         GoRoute(
//           path: '/escrow/bank-letter/create',
//           builder: (context, state) =>
//               const CreateBankLetterPage()
//         ),
//         GoRoute(
//           path: '/escrow/bank-letter/preview/:id',
//           builder: (context, state) {
//             final letterId = state.pathParameters['id'] ?? '';
//             return BankLetterFullPreview(letterId: letterId);
//           },
//         ),
//
//
//         // Travel & Reimbursement
//         GoRoute(
//           path: '/reimbursement-note/create',
//           builder: (context, state) =>
//               const ReimbursementForm(),
//         ),
//         GoRoute(
//           path: '/reimbursement-note',
//           builder: (context, state) => const ReimbursementTablePage(),
//         ),
//
//         // MANAGEMENT
//         // Organization Management
//         GoRoute(
//           path: '/organizations',
//           builder: (context, state) => const OrganizationMainPage(),
//         ),
//
//         // User Management
//         GoRoute(
//           path: '/users',
//           builder: (context, state) => const UserMainPage(),
//         ),
//         GoRoute(
//           path: '/users/create',
//           builder: (context, state) => const CreateUserScreen(),
//         ),
//
//         // Role Management
//         GoRoute(
//           path: '/roles',
//           builder: (context, state) => const RoleMainPage(),
//         ),
//         GoRoute(
//           path: '/roles/create',
//           builder: (context, state) => const CreateRoleScreen(),
//         ),
//
//         // Departments
//         GoRoute(
//           path: '/department',
//           builder: (context, state) => const DepartmentMainPage(),
//         ),
//         GoRoute(
//           path: '/department/create',
//           builder: (context, state) => const CreateDepartmentScreen(),
//         ),
//
//         // Designations
//         GoRoute(
//           path: '/designations',
//           builder: (context, state) => const DesignationMainPage(),
//         ),
//         GoRoute(
//           path: '/designations/create',
//           builder: (context, state) => const CreateDesignationScreen(),
//         ),
//
//         // Vendor Management
//         GoRoute(
//           path: '/vendors',
//           builder: (context, state) => const VendorMainPage(),
//         ),
//         GoRoute(
//           path: '/vendors/create',
//           builder: (context, state) => const CreateVendorScreen(),
//         ),
//
//         // Organization Management
//         GoRoute(
//           path: '/organizations',
//           builder: (context, state) => const OrganizationMainPage(),
//         ),
//         GoRoute(
//           path: '/organizations/create',
//           builder: (context, state) => const CreateOrganizationScreen(),
//         ),
//
//         // ACTIVITY & REPORTS
//         GoRoute(
//           path: '/activity',
//           builder: (context, state) => const ActivityMainPage(),
//         ),
//         GoRoute(
//           path: '/login-history',
//           builder: (context, state) => const LoginHistoryMainPage(),
//         ),
//       ],
//     ),
//   ],
// );
