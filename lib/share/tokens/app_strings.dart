class AppStrings {
  const AppStrings._();

  static const appTitle = 'Money Manager';

  // Home tutorial (first-run on dashboard)
  static const getStartedBadge = 'New Chapter';
  static const getStartedTitle = 'Get Started with HomeRatio';
  static const getStartedSubtitle =
      "Your journey to financial clarity begins here. Let's set up your sanctuary with a few simple steps.";
  static const getStartedCardTrackTitle = 'Track Your Ratios';
  static const getStartedCardTrackBody =
      'Visualize the harmony between your spending and income. Understand efficiency through clear summaries.';
  static const getStartedCardLimitsTitle = 'Set Your Limits';
  static const getStartedCardLimitsBody =
      'Define daily and monthly guidance. We use gentle cues before you cross your comfort zones.';
  static const getStartedExampleDaily = r'Daily: $50';
  static const getStartedExampleMonthly = r'Monthly: $1.2k';
  static const getStartedCardExpensesTitle = 'Add Daily Expenses';
  static const getStartedCardExpensesBody =
      'Quick logging for immediate insight. Every small purchase contributes to your full picture.';
  static const getStartedCardRecurringTitle = 'Recurring payments';
  static const getStartedCardRecurringBody =
      'Capture rent, subscriptions, and bills that repeat. See what is due soon and keep your monthly picture accurate.';
  static const getStartedSampleDataLabel = 'SAMPLE DATA';
  static const getStartedPrimaryCta = 'Add Your First Expense';
  static const getStartedSecondaryCta = 'Add income & limits first';

  // Dashboard / Home
  static const dashboardTitle = 'homeRatio';
  static const quickAddExpenseFabTooltip = 'Add expense';
  static const totalFamilyBudgetLabel = 'TOTAL FAMILY BUDGET';
  static const onTrack = 'On Track';
  static const overBudget = 'Over Budget';
  static const monthlySpending = 'Monthly Spending';
  static const monthlySpendingSubtitle =
      'You have used 64% of your shared budget';
  static const spentSoFarLabel = 'SPENT THIS MONTH';
  static const remainingLabel = 'REMAINING';
  static const dailyLimitLabel = 'DAILY LIMIT';
  static const savingsLabel = 'SAVINGS GOAL';
  static const limitsNotSet = 'Limits not set';
  static const monthlyProgressLabel = 'MONTHLY PROGRESS';
  static const monthlyRemainingLabel = 'MONTHLY REMAINING';
  static const monthlyOverspentLabel = 'MONTHLY OVERSPENT';
  static const upcomingBills = 'Recurring payments';
  static const viewAllCalendar = 'View All Calendar';

  static const homeMortgage = 'Home Mortgage';
  static const dueIn4Days = 'Due in 4 days';
  static const autoEmi = 'Auto EMI';
  static const dueIn8Days = 'Due in 8 days';
  static const utilities = 'Utilities';
  static const dueIn12Days = 'Due in 12 days';

  // Bottom navigation
  static const navHome = 'Home';
  static const navExpenses = 'Expenses';
  static const navAdd = 'Add';
  static const navInsights = 'Insights';
  static const navSettings = 'Settings';

  // Settings — compact layout (Stitch reference)
  static const settingsSubtitle = 'Manage your flow and limits.';
  static const settingsCardRecurring = 'Recurring';
  static const settingsCardRecurringAmount = '\$2,654.99/mo';
  static String settingsCardRecurringActiveBadge(int activeCount) =>
      '$activeCount ACTIVE';
  static const settingsCardFamily = 'Family';
  static const settingsCardFamilySubtitle = 'Your household';
  static const settingsCardLimits = 'Limits';
  static const settingsCardLimitsBadge = '\$12k Limit';
  static const settingsCardPreferences = 'Preferences';
  static const settingsCardPreferencesBadge = 'USD (\$)';
  static const settingsCardPreferencesSubtitle = 'Alerts & currency';
  static const cloudSyncSectionTitle = 'Cloud sync';
  static const authScreenTitle = 'Cloud account';
  static const authScreenSubtitle =
      'Sign in with email or create a new account to sync across devices.';
  static const cloudSyncOpenAuthButton = 'Sign in or create account';
  static const cloudSyncManageAccountButton = 'Manage account';
  static const commonDone = 'Done';
  static const cloudSyncAccountCreatedSnackbar =
      'Account created. You can sign in now.';
  static const cloudSyncNotConfigured =
      'Supabase is not configured. Pass SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define (see README).';
  static const cloudSyncEmailLabel = 'Email';
  static const cloudSyncPasswordLabel = 'Password';
  static const cloudSyncCreateAccount = 'Create account';
  static const cloudSyncNeedAccountHint =
      'New here? Create a Supabase account first.';
  static const cloudSyncSignIn = 'Sign in';
  static const cloudSyncSignOut = 'Sign out';
  static const cloudSyncSignedIn = 'Signed in';
  static const cloudSyncSyncReady = 'Sync active';
  static const cloudSyncUnsyncedLocalDataTitle = 'Local data available';
  static const cloudSyncUnsyncedLocalDataBody =
      'You have local data that is not synced. Sync to cloud now?';
  static const cloudSyncSyncNow = 'Yes, sync now';
  static const cloudSyncNotNow = 'Not now';
  static const cloudSyncPostAuthTitle = 'Sync local data';
  static const cloudSyncPostAuthPromptTitle = 'Data ready to sync';
  static String cloudSyncPostAuthPromptBody(int totalRows) =>
      '$totalRows local item(s) are available to sync to cloud.';
  static const cloudSyncPostAuthPreparing = 'Preparing local data';
  static const cloudSyncPostAuthPushing = 'Uploading local changes';
  static const cloudSyncPostAuthPulling = 'Downloading latest cloud data';
  static const cloudSyncPostAuthSuccessTitle = 'Sync completed';
  static const cloudSyncPostAuthSuccessBody =
      'Your local data is now synced to cloud.';
  static const cloudSyncPostAuthFailureTitle = 'Sync failed';
  static const cloudSyncSyncBeforeLogoutTitle = 'Syncing data before logout';
  static const cloudSyncSyncBeforeLogoutPreparing = 'Preparing local data';
  static const cloudSyncSyncBeforeLogoutPushing = 'Uploading local changes';
  static const cloudSyncSyncBeforeLogoutPulling =
      'Downloading latest cloud data';
  static const cloudSyncSyncBeforeLogoutFailureTitle =
      'Sync failed before logout';
  static const cloudSyncRetry = 'Retry';
  static const cloudSyncLogoutWithoutSync = 'Logout without sync';
  static const cloudSyncLogoutWithoutSyncWarning =
      'Unsynced local changes may be lost.';

  static const settingsBiometricTitle = 'Biometric lock';
  static const settingsBiometricSubtitle = 'Require Face ID';
  static const settingsPushNotifications = 'Push notifications';
  static const preferencesDetailsTitle = 'Preferences';
  static const preferencesRegionalSection = 'Regional';
  static const preferencesCurrencyLabel = 'Currency';
  static const preferencesLanguageLabel = 'Language';
  static const preferencesNumberFormatLabel = 'Number format';
  static const preferencesCategorySection = 'Categories';
  static const preferencesManageCategories = 'Manage categories';
  static const categoryManagementTitle = 'Category list';

  // Expense limits (guidance, non-blocking)
  static const expenseLimitsScreenTitle = 'Expense limits';
  static const expenseLimitsGuidanceFootnote =
      'These numbers are guides so you can pace spending. They do not block expenses.';
  static const expenseLimitsMonthlyIncomeLabel = 'Monthly income';
  static const expenseLimitsMonthlySavingsLabel = 'Monthly savings goal';
  static const expenseLimitsExcludeRecurringLabel = 'Subtract unpaid recurring';
  static const expenseLimitsExcludeRecurringSubtitle =
      'Uses enabled templates not yet paid this month (scheduled amounts).';
  static const expenseLimitsSpendableMonthlyLabel =
      'Indicative monthly spendable';
  static const expenseLimitsIndicativeDailyLabel = 'Indicative daily';
  static const expenseLimitsSave = 'Save';
  static const expenseLimitsUnsetHint =
      'Set a monthly income to see indicative amounts.';
  static const expenseLimitsValidationIncome =
      'Enter a valid monthly income or leave blank to clear.';
  static const expenseLimitsValidationSavings =
      'Enter a valid savings amount or leave blank to clear.';
  static const expenseLimitsUnsetValue = 'Not set';
  static String expenseLimitsDaysInMonth(int days) => '$days days this month';

  // Expenses tab
  static const expensesDaily = 'Daily';
  static const expensesMonthly = 'Monthly';
  static const expensesRecurring = 'Recurring';
  static const recurringOverdue = 'Overdue';
  static const recurringUpcoming = 'Upcoming';
  static const recurringMarkPaid = 'Mark as paid';
  static const recurringPaid = 'Paid';
  static const recurringAddTitle = 'Add recurring payment';
  static const recurringManageScreenTitle = 'Recurring templates';
  static const recurringEditTitle = 'Edit recurring payment';
  static const recurringManageEditAction = 'Edit';
  static const recurringDeleteConfirmTitle = 'Delete recurring payment?';
  static const recurringManageScheduledSwitchLabel =
      'Show in Expenses and Home';
  static String recurringDeleteConfirmBody(String title) =>
      'Remove “$title”? Future months will not list it; expenses you already recorded stay in history.';
  static const recurringEmptyTitle = 'No recurring payments';
  static const recurringEmptySubtitle =
      'Add rent, bills, or EMIs you pay each month.';
  static const recurringTitleLabel = 'Title';
  static const recurringDayOfMonthLabel = 'Day of month';
  static const recurringCategoryLabel = 'Category';
  static const recurringSaveTemplate = 'Save';
  static const recurringDelete = 'Delete';
  static const recurringDuePrefix = 'Due';
  static const recurringDueDateSectionTitle = 'Due date';
  static const recurringCalendarHint =
      'Pick the calendar day this payment is due each month.';
  static const recurringHomeEmpty = 'Nothing due right now';
  static const recurringConfirmAmountHint = 'Amount';
  static const recurringAutoRecurringLabel = 'Auto recurring';
  static const recurringAutoRecurringHint = 'Turn off to set an end month.';
  static const recurringEndMonthLabel = 'End month';
  static const recurringEndMonthHint = 'Optional';
  static const recurringDueDayLabel = 'Due day';
  static const recurringPickDueDay = 'Pick a date to set the due day-of-month.';
  static const recurringValidationTitle = 'Enter a title';
  static const recurringValidationAmount = 'Enter a valid amount';

  static String recurringDueEachMonthSummary(int dayOfMonth) =>
      'Due on day $dayOfMonth of each month';
  static String recurringEndsInMonth(String monthKey) => 'Ends $monthKey';
  static const expensesEmptyTitle = 'No expenses yet';
  static const expensesEmptySubtitle = 'Add an expense to see it here.';
  static const expensesPreviousDayTooltip = 'Previous day';
  static const expensesNextDayTooltip = 'Next day';
  static const expensesPreviousMonthTooltip = 'Previous month';
  static const expensesNextMonthTooltip = 'Next month';

  // Add Expense
  static const newExpenseTitle = 'New Expense';
  static const transactionAmountLabel = 'Transaction Amount';
  static const amountPlaceholder = '0.00';
  static const dateLabel = 'Date';
  static const noteLabel = 'Note';
  static const noteHint = 'What was this for?';
  static const selectCategoryTitle = 'Select Category';
  static const quickAddAmountLabel = 'AMOUNT';
  static const quickAddNotePlaceholder = 'Add a note...';
  static const editAmount = 'Edit amount';
  static const tapCategoryToSaveInstantly = 'Tap category to save instantly';
  static const saveExpense = 'Save Expense';
  static const cancel = 'Cancel';

  // User profile
  static const defaultUserDisplayName = 'You';
  static const profileTitle = 'Profile';
  static const displayNameLabel = 'Display name';
  static const edit = 'Edit';
  static const save = 'Save';

  static const categoryHousing = 'Housing';
  static const categoryMedical = 'Medical';
  static const categoryTravel = 'Travel';
  static const categoryGrocery = 'Grocery';
  static const categoryUtilitiesBills = 'Utilities/Bills';
  static const categoryDiningOut = 'Dining Out';
  static const categoryCinema = 'Cinema';
  static const categoryHealth = 'Health';
  static const categoryOnlineShopping = 'Online Shopping';
  static const categoryVegetables = 'Vegetables';
  static const categoryFuel = 'Fuel';
  static const categoryVacation = 'Vacation';
  static const categorySavings = 'Savings';
}
