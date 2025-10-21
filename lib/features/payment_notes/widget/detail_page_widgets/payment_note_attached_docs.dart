import 'package:flutter/material.dart';
import 'package:ppv_components/common_widgets/custom_table.dart';

class PaymentNoteAttachedDocs extends StatelessWidget {
  final List attachedDocsFiltered;
  final int rowsPerPage;
  final int currentPage;
  final Function(String) onSearch;
  final Function(int?) onChangeRowsPerPage;
  final Function(int) onGotoPage;
  final Function(dynamic) onDeleteDoc;

  const PaymentNoteAttachedDocs({
    super.key,
    required this.attachedDocsFiltered,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onSearch,
    required this.onChangeRowsPerPage,
    required this.onGotoPage,
    required this.onDeleteDoc,
  });

  List<DataRow> _buildRows(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    int start = currentPage * rowsPerPage;
    int end = (start + rowsPerPage).clamp(0, attachedDocsFiltered.length);
    final pageItems = attachedDocsFiltered.sublist(start, end);
    return pageItems.map<DataRow>((doc) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              doc.sno.toString(),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(doc.fileName, style: TextStyle(color: colorScheme.onSurface)),
          ),
          DataCell(Icon(Icons.insert_drive_file, color: colorScheme.primary)),
          DataCell(
            Text(
              doc.uploadDate,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Text(
              doc.uploadedBy,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          DataCell(
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.download_rounded, size: 20),
                  onPressed: () {}, // Implement download if needed
                  splashRadius: 18,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () => onDeleteDoc(doc),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final columns = [
      DataColumn(
        label: Text(
          'S no.',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'File name',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'File',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Upload Date',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Uploaded By',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      DataColumn(
        label: Text(
          'Action',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
    int startItem = attachedDocsFiltered.isEmpty
        ? 0
        : currentPage * rowsPerPage + 1;
    int endItem = (currentPage * rowsPerPage + rowsPerPage).clamp(
      0,
      attachedDocsFiltered.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 12),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Attached Supporting Docs',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {},
              child: const Text('View Green Note'),
            ),
            const Spacer(),
            SizedBox(
              width: 250,
              child: TextField(
                onChanged: onSearch,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  hintText: 'Search files',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<int>(
              value: rowsPerPage,
              items: [5, 10, 20, 50]
                  .map(
                    (e) =>
                    DropdownMenuItem(value: e, child: Text('$e entries')),
              )
                  .toList(),
              onChanged: onChangeRowsPerPage,
            ),
            Text(
              'Showing $startItem to $endItem of ${attachedDocsFiltered.length} entries',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        CustomTable(columns: columns, rows: _buildRows(context)),
      ],
    );
  }
}
