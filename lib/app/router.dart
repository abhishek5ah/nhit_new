import 'package:go_router/go_router.dart';
import 'package:ppv_components/app/layout.dart';
import 'package:ppv_components/features/crm/screens/crm_main_page.dart';
import 'package:ppv_components/features/dashboard/presentation/dashboard_page.dart';
import 'package:ppv_components/features/documents/screen/documents_page.dart';
import 'package:ppv_components/features/finance/finance_page.dart';
import 'package:ppv_components/features/finance/screens/accounts/account_detail_page.dart';
import 'package:ppv_components/features/finance/screens/accounts/account_table.dart';
import 'package:ppv_components/features/finance/screens/expenses/screens/expense_table.dart';
import 'package:ppv_components/features/finance/screens/expenses/screens/expense_view_page_layout.dart';
import 'package:ppv_components/features/finance/screens/invoices/invoice_table.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_detail_page_layout.dart';
import 'package:ppv_components/features/gst/screen/gst_page.dart';
import 'package:ppv_components/features/hrms/screen/hrms_page.dart';
import 'package:ppv_components/features/inventory/screen/invendory_page.dart';
import 'package:ppv_components/features/it_services/screen/it_service_page.dart';
import 'package:ppv_components/features/pantry/screen/pantry_page.dart';
import 'package:ppv_components/features/projects/screen/projects_page.dart';
import 'package:ppv_components/features/reports/screen/reports_page.dart';
import 'package:ppv_components/features/vendors/screen/vendors_page.dart';
import 'package:ppv_components/features/finance/screens/accounts/account_detail_page.dart';




final GoRouter router = GoRouter(
  initialLocation: '/finance',
  routes: [
    ShellRoute(
      builder: (context, state, child) => LayoutPage(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsPage(),
        ),
        GoRoute(
          path: '/finance',
          builder: (context, state) => const FinanceMainPage(),
          routes: [
            // Invoices
            GoRoute(
              path: 'invoices',
              builder: (context, state) => const InvoiceTableView(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final invoiceId = state.pathParameters['id']!;
                    return InvoiceDetailPageLayout(invoiceId: invoiceId);
                  },
                ),
              ],
            ),
            // Expense (new structure like invoices)
            GoRoute(
              path: 'expense',
              builder: (context, state) => const ExpenseTableView(), // create this page
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final expenseId = state.pathParameters['id']!;
                    return ExpenseViewPageLayout(expenseId: expenseId);
                  },
                ),
              ],
            ),
            GoRoute(
              path: 'account',
              builder: (context, state) => const AccountTableView(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final accountId = state.pathParameters['id']!;
                    return AccountDetailPage(accountId: accountId);
                  },
                ),
              ],
            ),

            // Account (example structure under finance)
            // GoRoute(
            //   path: 'account',
            //   builder: (context, state) => const AccountTableView(), // create this page
            //   routes: [
            //     GoRoute(
            //       path: ':id',
            //       builder: (context, state) {
            //         final accountId = state.pathParameters['id']!;
            //         return AccountDetailPage(accountId: accountId); // create this page
            //       },
            //     ),
            //   ],
            // ),
            /*
            // Reports under finance (commented out as requested)
            GoRoute(
              path: 'reports',
              builder: (context, state) => const ReportsTableView(), // create this page
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final reportId = state.pathParameters['id']!;
                    return ReportDetailPage(reportId: reportId); // create this page
                  },
                ),
              ],
            ),
            */
          ],
        ),
        GoRoute(path: '/crm', builder: (context, state) => const CRMPage()),
        GoRoute(path: '/hrms', builder: (context, state) => const HRMSPage()),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryPage(),
        ),
        GoRoute(
          path: '/vendors',
          builder: (context, state) => const VendorsPage(),
        ),
        GoRoute(
          path: '/pantry',
          builder: (context, state) => const PantryPage(),
        ),
        GoRoute(
          path: '/itservices',
          builder: (context, state) => const ItServicePage(),
        ),
        GoRoute(path: '/gst', builder: (context, state) => const GstPage()),
        GoRoute(
          path: '/documents',
          builder: (context, state) => const DocumentsPage(),
        ),
        // If you want to have top-level reports module too
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsPage(),
        ),
      ],
    ),
  ],
);
