// models/income_model.dart
import 'package:flutter/material.dart';

class Income {
  final String title;
  final String category;
  final String amount;
  final String date;
  final Color categoryColor;
  final Color categoryTextColor;
  final String? description;

  Income({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.categoryColor,
    required this.categoryTextColor,
    this.description,
  });
}