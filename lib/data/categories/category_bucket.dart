enum CategoryBucket { needs, wants, savingsDebt }

extension CategoryBucketX on CategoryBucket {
  String get dbValue => switch (this) {
        CategoryBucket.needs => 'needs',
        CategoryBucket.wants => 'wants',
        CategoryBucket.savingsDebt => 'savings_debt',
      };

  String get displayLabel => switch (this) {
        CategoryBucket.needs => 'Needs (50%)',
        CategoryBucket.wants => 'Wants (30%)',
        CategoryBucket.savingsDebt => 'Savings & Debt (20%)',
      };
}

CategoryBucket categoryBucketFromDb(String raw) {
  return switch (raw) {
    'needs' => CategoryBucket.needs,
    'wants' => CategoryBucket.wants,
    'savings_debt' => CategoryBucket.savingsDebt,
    _ => CategoryBucket.needs,
  };
}
