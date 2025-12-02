import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');
    final startSerial = currentPage * rowsPerPage;
    final columns = [
      DataColumn(label: Text('S.No', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('User', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('Login Time', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('IP Address', style: TextStyle(color: colorScheme.onSurface))),
      DataColumn(label: Text('User Agent', style: TextStyle(color: colorScheme.onSurface))),
    ];
    final rows = paginated.asMap().entries.map((entry) {
      final index = entry.key;
      final log = entry.value;
      final serialNumber = startSerial + index + 1;
      final loginTimeText = dateFormatter.format(log.loginTime);

      return DataRow(cells: [
        DataCell(Text(serialNumber.toString(), style: TextStyle(color: colorScheme.onSurface))),
        DataCell(Text(log.userLabel, style: TextStyle(color: colorScheme.onSurface))),
        DataCell(Text(loginTimeText, style: TextStyle(color: colorScheme.onSurface))),
        DataCell(Text(log.ipAddress, style: TextStyle(color: colorScheme.onSurface))),
        DataCell(
          Tooltip(
            message: log.userAgent,
            child: SizedBox(
              width: 250,
              child: Text(
                log.userAgent,
                style: TextStyle(color: colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),
      ]);
    }).toList();

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
