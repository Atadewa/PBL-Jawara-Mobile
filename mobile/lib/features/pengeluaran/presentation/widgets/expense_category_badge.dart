import 'package:flutter/material.dart';
import '../../data/models/expense_category.dart';

/// Widget badge untuk menampilkan kategori pengeluaran
/// Sesuai dengan design Figma
class ExpenseCategoryBadge extends StatelessWidget {
  final ExpenseCategory category;

  const ExpenseCategoryBadge({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.circular(36410900),
      ),
      child: Text(
        category.label,
        style: TextStyle(
          color: category.textColor,
          fontSize: 11,
          fontFamily: 'Arimo',
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
      ),
    );
  }
}
