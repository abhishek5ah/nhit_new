import 'package:flutter/material.dart';

Color getAccountTypeColor(String type) {
  switch (type) {
    case 'Asset':
      return const Color(0xFF8ab207);     // Greenish
    case 'Expense':
      return const Color(0xFF0082ce);     // Blue
    case 'Liability':
      return const Color(0xFFcc3222);     // Red
    case 'Equity':
      return const Color(0xFF7d1ab5);     // Purple
    case 'Revenue':
      return const Color(0xFFde7906);     // Orange
    case 'Profit':
      return const Color(0xFF009484);     // Teal
    default:
      return Colors.grey;
  }
}
