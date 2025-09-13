import 'package:go_router/go_router.dart';
import 'package:ppv_components/app/layout.dart';
import 'package:ppv_components/features/crm/screens/crm_main_page.dart';
import 'package:ppv_components/features/dashboard/presentation/dashboard_page.dart';
import 'package:ppv_components/features/documents/screen/documents_page.dart';
import 'package:ppv_components/features/finance/finance_page.dart';
import 'package:ppv_components/features/finance/screens/expenses/screens/expense_view_page_layout.dart';
import 'package:ppv_components/features/finance/screens/invoices/widgets/invoice_detail_page_layout.dart';
import 'package:ppv_components/features/gst/screen/gst_page.dart';
import 'package:ppv_components/features/hrms/screen/hrms_page.dart';
import 'package:ppv_components/features/inventory/screen/invendory_page.dart';
import 'package:ppv_components/features/it_services/screen/it_service_page.dart';
import 'package:ppv_components/features/pantry/screen/pantry_page.dart';
import 'package:ppv_components/features/projects/screen/projects_page.dart';
import 'package:ppv_components/features/reports/screen/reports_page.dart';
import 'package:ppv_components/features/vendors/screen/vendors_page.dart';

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
            GoRoute(
              path: 'invoices/:id',
              builder: (context, state) {
                final invoiceId = state.pathParameters['id']!;
                return InvoiceDetailPageLayout(invoiceId: invoiceId);
              },
            ),
            GoRoute(
              path: 'expense/:id',
              builder: (context, state) {
                final invoiceId = state.pathParameters['id']!;
                return ExpenseViewPageLayout(expenseId: invoiceId,);
              },
            ),
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
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsPage(),
        ),
      ],
    ),
  ],
);
