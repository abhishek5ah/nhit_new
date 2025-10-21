import 'package:go_router/go_router.dart';
import 'package:ppv_components/app/layout.dart';
import 'package:ppv_components/features/activity/screen/activity_main_page.dart';
import 'package:ppv_components/features/bank_rtgs_neft/screens/bank_rtgs_neft_main.dart';
import 'package:ppv_components/features/department/screen/department_main_page.dart';
import 'package:ppv_components/features/designation/screen/designation_main_page.dart';
import 'package:ppv_components/features/expense/screens/expense_main_page.dart';
import 'package:ppv_components/features/payment_notes/screen/payment_notes_main_page.dart';
import 'package:ppv_components/features/reimbursement/screens/reimbursement_main_page.dart';
import 'package:ppv_components/features/roles/screens/roles_main_page.dart';
import 'package:ppv_components/features/user/screens/user_main_page.dart';
import 'package:ppv_components/features/vendor/screen/vendor_main_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/roles',
  routes: [
    ShellRoute(
      builder: (context, state, child) => LayoutPage(child: child),
      routes: [
        GoRoute(
          path: '/roles',
          builder: (context, state) => const RoleMainPage(),
        ),
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserMainPage(),
        ),
        GoRoute(
          path: '/vendor',
          builder: (context, state) => const VendorMainPage(),
        ),
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityMainPage(),
        ),
        GoRoute(
          path: '/expense',
          builder: (context, state) => const ExpenseMainPage(),
        ),
        GoRoute(
          path: '/payment-notes',
          builder: (context, state) => const PaymentMainPage(),
        ), GoRoute(
          path: '/reimbursement',
          builder: (context, state) => const ReimbursementMainPage(),
        ),
        GoRoute(
          path: '/bank',
          builder: (context, state) => const BankMainPage(),
        ),
        GoRoute(
          path: '/designation',
          builder: (context, state) => const DesignationMainPage(),
        ),
        GoRoute(
          path: '/department',
          builder: (context, state) => const DepartmentMainPage(),
        ),
      ],
    ),
  ],
);
