import 'package:flutter/material.dart';
import 'package:money_manager/data/categories/category_bucket.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.bucket,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String id;
  final String label;
  final CategoryBucket bucket;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}

