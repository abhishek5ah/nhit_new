import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Overdue':
      return Colors.red;
    case 'Pending':
      return Colors.orange;
    case 'Paid':
      return Colors.cyan;
    case 'Draft':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}
