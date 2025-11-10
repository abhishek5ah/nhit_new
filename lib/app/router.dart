import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ppv_components/app/layout.dart';

// Import only the pages that actually exist in your project
import 'package:ppv_components/features/activity/screen/activity_main_page.dart';
import 'package:ppv_components/features/activity/screen/login_history_main_page.dart';
import 'package:ppv_components/features/department/screen/create_department.dart';
import 'package:ppv_components/features/department/screen/department_main_page.dart';
import 'package:ppv_components/features/designation/screen/create_designation.dart';
import 'package:ppv_components/features/designation/screen/designation_main_page.dart';
import 'package:ppv_components/features/organization/screens/create_organization.dart';
import 'package:ppv_components/features/organization/screens/organization_main_page.dart';
import 'package:ppv_components/features/payment_notes/screen/payment_notes_main_page.dart';
import 'package:ppv_components/features/reimbursement/screens/reimbursement_main_page.dart';
import 'package:ppv_components/features/roles/screens/create_role.dart';
import 'package:ppv_components/features/roles/screens/roles_main_page.dart';
import 'package:ppv_components/features/user/screens/add_user.dart';
import 'package:ppv_components/features/user/screens/user_main_page.dart';
import 'package:ppv_components/features/vendor/screen/vendor_main_page.dart';
import 'package:ppv_components/features/vendor/widgets/add_vendor_form.dart';

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

final GoRouter router = GoRouter(
  initialLocation: '/organizations',
  routes: [
    ShellRoute(
      builder: (context, state, child) => LayoutPage(child: child),
      routes: [
        // EXPENSE MANAGEMENT
        // Expense Approval Notes
        GoRoute(
          path: '/expense-notes/note',
          builder: (context, state) => const PlaceholderPage(title: 'Expense Notes'),
        ),
        GoRoute(
          path: '/expense-note/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Expense Note'),
        ),

        // Payment Notes
        GoRoute(
          path: '/payment-notes/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Payment Note'),
        ),
        GoRoute(
          path: '/payment-notes',
          builder: (context, state) => const PaymentMainPage(),
        ),
        GoRoute(
          path: '/drafts',
          builder: (context, state) => const PlaceholderPage(title: 'Draft Notes'),
        ),

        // APPROVAL RULES
        // Approval Rules Management
        GoRoute(
          path: '/approval-rules',
          builder: (context, state) => const PlaceholderPage(title: 'Approval Rules Dashboard'),
        ),
        GoRoute(
          path: '/approval-rules/green_note',
          builder: (context, state) => const PlaceholderPage(title: 'Expense Note Rules'),
        ),
        GoRoute(
          path: '/approval-rules/green_note/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Expense Rule'),
        ),
        GoRoute(
          path: '/approval-rules/payment_note',
          builder: (context, state) => const PlaceholderPage(title: 'Payment Note Rules'),
        ),
        GoRoute(
          path: '/approval-rules/payment_note/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Payment Rule'),
        ),
        GoRoute(
          path: '/approval-rules/reimbursement_note',
          builder: (context, state) => const PlaceholderPage(title: 'Reimbursement Rules'),
        ),
        GoRoute(
          path: '/approval-rules/reimbursement_note/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Reimbursement Rule'),
        ),
        GoRoute(
          path: '/approval-rules/bank_letter',
          builder: (context, state) => const PlaceholderPage(title: 'Bank Letter Rules'),
        ),
        GoRoute(
          path: '/approval-rules/bank_letter/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Bank Letter Rule'),
        ),

        // Escrow Banking System
        GoRoute(
          path: '/escrow-accounts',
          builder: (context, state) => const PlaceholderPage(title: 'Escrow Accounts'),
        ),
        GoRoute(
          path: '/escrow-accounts/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Escrow Account'),
        ),
        GoRoute(
          path: '/escrow/account-transfers',
          builder: (context, state) => const PlaceholderPage(title: 'Fund Transfers'),
        ),
        GoRoute(
          path: '/escrow/create',
          builder: (context, state) => const PlaceholderPage(title: 'New Transfer'),
        ),
        GoRoute(
          path: '/escrow/bank-letter',
          builder: (context, state) => const PlaceholderPage(title: 'Bank Letter'),
        ),
        GoRoute(
          path: '/escrow/bank-letter/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Bank Letter'),
        ),

        // Travel & Reimbursement
        GoRoute(
          path: '/reimbursement-note/create',
          builder: (context, state) => const PlaceholderPage(title: 'Create Reimbursement'),
        ),
        GoRoute(
          path: '/reimbursement-note',
          builder: (context, state) => const ReimbursementMainPage(),
        ),

        // MANAGEMENT
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
        // Activity
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
