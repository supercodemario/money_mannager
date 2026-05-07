import 'package:flutter/material.dart';
import 'package:money_manager/data/categories/category_bucket.dart';
import 'package:money_manager/data/local/app_database.dart' as db;
import 'package:money_manager/features/add_expense/models/expense_category/expense_category.dart' as model;
import 'package:money_manager/share/share.dart';

class CategoryVisual {
  const CategoryVisual({
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}

const _fallbackVisual = CategoryVisual(
  icon: Icons.category_rounded,
  backgroundColor: AppColors.surfaceContainerHigh,
  foregroundColor: AppColors.onSurfaceVariant,
);

const _visualById = <String, CategoryVisual>{
  'house': CategoryVisual(
    icon: Icons.home_rounded,
    backgroundColor: AppColors.primaryContainer,
    foregroundColor: AppColors.primary,
  ),
  'medical': CategoryVisual(
    icon: Icons.medical_services_rounded,
    backgroundColor: AppColors.categoryMedicalTint,
    foregroundColor: AppColors.error,
  ),
  'travel': CategoryVisual(
    icon: Icons.flight_rounded,
    backgroundColor: AppColors.categoryTravelTint,
    foregroundColor: AppColors.tertiary,
  ),
  'grocery': CategoryVisual(
    icon: Icons.shopping_cart_rounded,
    backgroundColor: AppColors.secondaryContainer,
    foregroundColor: AppColors.secondary,
  ),
  'bill': CategoryVisual(
    icon: Icons.receipt_long_rounded,
    backgroundColor: AppColors.surfaceContainer,
    foregroundColor: AppColors.onSurface,
  ),
  'out-eat': CategoryVisual(
    icon: Icons.restaurant_rounded,
    backgroundColor: AppColors.tertiaryContainer,
    foregroundColor: AppColors.onTertiaryContainer,
  ),
  'cinema': CategoryVisual(
    icon: Icons.movie_rounded,
    backgroundColor: AppColors.categoryCinemaTint,
    foregroundColor: AppColors.onPrimaryContainer,
  ),
  'health': CategoryVisual(
    icon: Icons.fitness_center_rounded,
    backgroundColor: AppColors.categoryHealthTint,
    foregroundColor: AppColors.secondaryDim,
  ),
  'online-shopping': CategoryVisual(
    icon: Icons.shopping_bag_rounded,
    backgroundColor: AppColors.categoryOnlineTint,
    foregroundColor: AppColors.categoryOnlineOnTint,
  ),
  'vegetables': CategoryVisual(
    icon: Icons.eco_rounded,
    backgroundColor: AppColors.categoryVegetablesTint,
    foregroundColor: AppColors.categoryVegetablesOnTint,
  ),
  'fuel': CategoryVisual(
    icon: Icons.local_gas_station_rounded,
    backgroundColor: AppColors.categoryFuelTint,
    foregroundColor: AppColors.tertiaryDim,
  ),
  'vacation': CategoryVisual(
    icon: Icons.beach_access_rounded,
    backgroundColor: AppColors.categoryVacationTint,
    foregroundColor: AppColors.categoryVacationOnTint,
  ),
  'savings': CategoryVisual(
    icon: Icons.savings_rounded,
    backgroundColor: AppColors.categorySavingsTint,
    foregroundColor: AppColors.categorySavingsOnTint,
  ),
};

model.ExpenseCategory mapDbCategoryToExpenseCategory(db.ExpenseCategory dbRow) {
  final visual = _visualById[dbRow.id] ?? _fallbackVisual;
  return model.ExpenseCategory(
    id: dbRow.id,
    label: dbRow.label,
    bucket: categoryBucketFromDb(dbRow.bucket),
    icon: visual.icon,
    backgroundColor: visual.backgroundColor,
    foregroundColor: visual.foregroundColor,
  );
}
