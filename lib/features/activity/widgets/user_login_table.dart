import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/button/toggle_button.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';
import 'package:ppv_components/features/activity/widgets/user_login_grid.dart';

class UserLoginTableView extends StatefulWidget {
  final List<UserLoginHistory> loginData;

  const UserLoginTableView({super.key, required this.loginData});

  @override
  State<UserLoginTableView> createState() => _UserLoginTableViewState();
}

class _UserLoginTableViewState extends State<UserLoginTableView> {
  int toggleIndex = 0;
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
    _updatePagination();
  }

  void _updatePagination() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.loginData.length);
    setState(() {
      paginated = widget.loginData.sublist(start, end);
      final totalPages = (widget.loginData.length / rowsPerPage).ceil();
      if (currentPage >= totalPages && totalPages > 0) {
        currentPage = totalPages - 1;
        paginated = widget.loginData.sublist(start, end);
      }
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
      DataColumn(
        label: Text('ID', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('User', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Login At', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text('Login IP', style: TextStyle(color: colorScheme.onSurface)),
      ),
      DataColumn(
        label: Text(
          'User Agent',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      DataColumn(
        label: Text(
          'Created At',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
    ];

    final rows = paginated
        .map(
          (log) => DataRow(
            cells: [
              DataCell(
                Text(
                  log.id.toString(),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              DataCell(
                Text(log.user, style: TextStyle(color: colorScheme.onSurface)),
              ),
              DataCell(
                Text(
                  log.loginAt,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              DataCell(
                Text(
                  log.loginIp,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              DataCell(
                Text(
                  log.userAgent,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              DataCell(
                Text(
                  log.createdAt,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ],
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'User Logins',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ToggleBtn(
                          labels: ['Table', 'Grid'],
                          selectedIndex: toggleIndex,
                          onChanged: (index) =>
                              setState(() => toggleIndex = index),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: toggleIndex == 0
                          ? Column(
                              children: [
                                Expanded(
                                  child: CustomTable(
                                    columns: columns,
                                    rows: rows,
                                  ),
                                ),
                                _paginationBar(context),
                              ],
                            )
                          : UserLoginGridView(
                              loginList: widget.loginData,
                              rowsPerPage: rowsPerPage,
                              currentPage: currentPage,
                              onPageChanged: (page) {
                                setState(() {
                                  currentPage = page;
                                  _updatePagination();
                                });
                              },
                              onRowsPerPageChanged: (rows) {
                                setState(() {
                                  rowsPerPage = rows ?? rowsPerPage;
                                  currentPage = 0;
                                  _updatePagination();
                                });
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paginationBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalPages = (widget.loginData.length / rowsPerPage).ceil();
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, widget.loginData.length);

    int windowSize = 3;
    int startWindow = 0;
    int endWindow = totalPages;

    if (totalPages > windowSize) {
      if (currentPage <= 1) {
        startWindow = 0;
        endWindow = windowSize;
      } else if (currentPage >= totalPages - 2) {
        startWindow = totalPages - windowSize;
        endWindow = totalPages;
      } else {
        startWindow = currentPage - 1;
        endWindow = currentPage + 2;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${widget.loginData.isEmpty ? 0 : start + 1} to $end of ${widget.loginData.length} entries",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentPage > 0
                    ? () => gotoPage(currentPage - 1)
                    : null,
              ),
              for (int i = startWindow; i < endWindow; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: i == currentPage
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      foregroundColor: i == currentPage
                          ? Colors.white
                          : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () => gotoPage(i),
                    child: Text('${i + 1}'),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages - 1
                    ? () => gotoPage(currentPage + 1)
                    : null,
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [5, 10, 20, 50]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                    .toList(),
                onChanged: changeRowsPerPage,
                style: Theme.of(context).textTheme.bodyMedium,
                underline: const SizedBox(),
              ),
              const SizedBox(width: 8),
              Text('page', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
