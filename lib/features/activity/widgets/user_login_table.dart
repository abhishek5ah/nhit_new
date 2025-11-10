import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/common_widgets/custom_pagination.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';

class UserLoginTableView extends StatefulWidget {
  final List<UserLoginHistory> loginData;
  const UserLoginTableView({super.key, required this.loginData});

  @override
  State<UserLoginTableView> createState() => _UserLoginTableViewState();
}

class _UserLoginTableViewState extends State<UserLoginTableView> {
  int rowsPerPage = 10;
  int currentPage = 0;
  late List<UserLoginHistory> paginated;

  @override
  void initState() {
    super.initState();
    _updatePagination();
  }

  @override
  void didUpdateWidget(covariant UserLoginTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loginData != oldWidget.loginData) {
      currentPage = 0;
    }
    _updatePagination();
  }

  void _updatePagination() {
    final totalPages = (widget.loginData.length / rowsPerPage).ceil();
    if (currentPage >= totalPages && totalPages > 0) {
      currentPage = totalPages - 1;
    }
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.loginData.length);
    setState(() {
      paginated = widget.loginData.sublist(start, end);
    });
  }

  void changeRowsPerPage(int? value) {
    setState(() {
      rowsPerPage = value ?? 10;
      currentPage = 0;
      _updatePagination();
    });
  }

  void gotoPage(int page) {
    setState(() {
      currentPage = page;
      _updatePagination();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final columns = [
      DataColumn(label: Text('ID', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('User', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Login At', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Login IP', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('User Agent', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Created At', style: TextStyle(color: colorScheme.onSurface))),
    ];
    final rows = paginated
        .map((log) => DataRow(cells: [
      DataCell(Text(log.id.toString(), style: TextStyle(color: colorScheme.onSurface))),
      DataCell(Text(log.user, style: TextStyle(color: colorScheme.onSurface))),
      DataCell(Text(log.loginAt, style: TextStyle(color: colorScheme.onSurface))),
      DataCell(Text(log.loginIp, style: TextStyle(color: colorScheme.onSurface))),
      DataCell(Text(log.userAgent, style: TextStyle(color: colorScheme.onSurface))),
      DataCell(Text(log.createdAt, style: TextStyle(color: colorScheme.onSurface))),
    ]))
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Logins',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: CustomTable(columns: columns, rows: rows)),
          // Use the custom pagination bar
          CustomPaginationBar(
            totalItems: widget.loginData.length,
            currentPage: currentPage,
            rowsPerPage: rowsPerPage,
            onPageChanged: gotoPage,
            onRowsPerPageChanged: changeRowsPerPage,
          ),
        ],
      ),
    );
  }
}
