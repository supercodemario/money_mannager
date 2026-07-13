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
  static const dailyPlanLabel = 'Daily plan';
  static const pacePerDayLabel = 'Pace / day';
  static const todayExpenseLabel = 'Today';
  static const paceOverLabel = 'Over pace';
  static const monthDaySpendListingTitle = 'Daily spend';
  static const monthDaySpendPlanLabel = 'Plan';
  static const monthDaySpendPaceLabel = 'Pace';
  static const monthDaySpendActualLabel = 'Spent';
  static const monthDaySpendDailyExpenseLabel = 'Daily';
  static const monthDaySpendRecurringAmountLabel = 'Recurring';
  static const monthDaySpendOpenSemantics = 'Open daily spend for this month';
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
  static const settingsCardFamilySubtitle = 'Households you belong to';
  static const familyListTitle = 'Family';
  static const familyListEmptyTitle = 'No households yet';
  static const familyListEmptySubtitle =
      'Sign in and sync once to create your home household, or open Family again '
      'after an owner adds you.';
  static const familyListLoadError =
      'Could not load households. Pull to try again.';
  static const familyListSyncHouseholdBadge = 'Sync';
  static const familyListYourRoleOwner = 'You are the owner';
  static const familyListYourRoleMember = 'You are a member';
  static const familyJoinWithQrTooltip = 'Scan to join a family';
  static const familyJoinHouseholdScanTitle = 'Scan family code';
  static const familyJoinHouseholdScanHint =
      'Scan the QR from Share on the family members screen, or paste the household id.';
  static const familyJoinHouseholdWebLead =
      'Paste the household id from the owner (Share on their family members screen shows it).';
  static const familyJoinPasteHouseholdLabel = 'Household id';
  static const familyJoinHouseholdPasteSheetTitle = 'Enter household id';
  static const familyJoinEmptyScanButton = 'Scan family QR';
  static const familyJoinSuccess = 'Joined family';
  static const familyJoinAlreadyIn = 'You are already in that family.';
  static const familyJoinInvalidHousehold = 'That family code is not valid.';
  static const familyJoinGenericError = 'Could not join. Try again.';
  static const familyJoinCannotUseOwnUserId =
      'That is your account id, not a family code. Ask the owner to share their family code from '
      'Family → Share, or scan someone else\'s code.';
  static const familyJoinSoloOwnHouseholdQrInvalid =
      'That code is only for your own home with no one else yet. A family needs at least two people. '
      'Invite someone first, or scan another family\'s code.';
  static const familyValidationMinTwoMembers =
      'A family needs at least two people. Invite someone with Share or scan their Profile invite.';
  static const familyShareHouseholdQrTooltip = 'Share family code';
  static const familyShareHouseholdQrTitle = 'Family code';
  static const familyShareHouseholdQrBody =
      'Others can open Settings → Family and scan this QR, or paste the id below.';
  static const familyShareHouseholdCopyId = 'Copy id';
  static const familyShareHouseholdCopied = 'Household id copied';
  static const familyListCreateFamilyButton = 'Create family';
  static const familyListShowQrTooltip = 'Show family QR';
  static const familyCreateTitle = 'Create family';
  static const familyCreateNameLabel = 'Family name';
  static const familyCreateNameRequired = 'Enter a family name.';
  static const familyCreateSubmitButton = 'Save and show invite';
  static const familyCreateQrHelp =
      'The household is created only after someone else scans this QR from Family and confirms.';
  static const familyCreateRegisterError = 'Could not save invite. Try again.';
  static const familyCreateInviteIdTaken =
      'That invite id is already in use. Close and open Create family again.';
  static const familyCreateUpdateNameButton = 'Update name on invite';
  static const familyCreateUpdateSuccess = 'Name updated.';
  static const familyCreateUpdateError = 'Could not update name.';
  static const familyCreateCancelInviteButton = 'Cancel invite';
  static const familyCreateCancelInviteConfirmTitle = 'Cancel invite?';
  static const familyCreateCancelInviteConfirmBody =
      'The QR code will stop working until you create a new invite.';
  static const familyCreateCancelSuccess = 'Invite cancelled.';
  static const familyCreateCancelError = 'Could not cancel invite.';
  static const familyJoinConfirmTitle = 'Join family';
  static String familyJoinConfirmBody(String familyName) {
    final safe = familyName.replaceAll('"', "'");
    return 'Join "$safe" as a member? Confirming creates this family and adds you.';
  }

  static const familyJoinConfirmButton = 'Confirm and join';
  static const familyAcceptInviteSuccess = 'You joined the family.';
  static const familyAcceptInviteNotFound =
      'That invite is no longer available.';
  static const familyAcceptInviteOwnInvite =
      'You cannot accept your own invite.';
  static const familyAcceptInviteHouseholdExists =
      'That family already exists.';
  static const familyAcceptInviteGenericError = 'Could not join. Try again.';
  static const familyScanOwnPendingInvite =
      'This is your own invite. Share the QR with someone else to create the family.';
  static const familyDetailsSignInRequired =
      'Sign in to your cloud account to view household members and invites.';
  static const familyDetailsNoHousehold =
      'Your household is not ready yet. Try syncing after sign-in.';
  static const familyDetailsEmptyTitle = 'No other members yet';
  static const familyDetailsEmptySubtitle =
      'Add someone by scanning their profile invite code.';
  static const familyDetailsMemberLabel = 'Member';
  static const familyDetailsOwnerLabel = 'Owner';
  static const familyDetailsYouSuffix = ' (you)';
  static const familyAddMemberTooltip = 'Add member';

  /// Primary CTA — scan another person's Profile invite QR.
  static const familyScanOtherQrButton = 'Scan QR code';
  static const familyScanOtherQrSubtitle =
      'Scan the invite QR shown on someone else\'s Profile screen to add them to your household.';
  static const familyScanOtherQrTooltip = 'Scan someone\'s invite QR code';

  /// Shown under the scan button when the current user is not the household owner (RPC still enforces).
  static const familyScanQrOwnerNote =
      'Only the household owner can complete adding a member. Ask the owner to scan if needed.';
  static const familyScanInviteButton = 'Scan invite code';
  static const familyDetailsNonOwnerInviteHint =
      'Only the household owner can scan an invite and add someone to this family. Ask your owner to open Family here and use Scan invite code.';
  static const familyScanTitle = 'Scan invite code';

  /// Web and simulators often lack a usable camera — paste works everywhere.
  static const familyScanWebUnavailable =
      'Camera scanning is not available here. Paste the invite ID from the other '
      'person\'s Profile screen (iOS/Android also support scanning).';
  static const familyScanPointCameraHint =
      'Point at the QR code on their Profile screen.';
  static const familyScanEnterInviteManually = 'Enter invite ID';
  static const familyScanPasteInviteLabel = 'Invite ID';
  static const familyScanPasteInviteHint =
      'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
  static const familyScanSubmitInvite = 'Use invite';
  static const familyScanCameraError =
      'Could not use the camera. Try Enter invite ID or check permissions.';
  static const familyScanInvalidCode = 'That is not a valid invite code.';
  static const familyInviteSuccess = 'Member added';
  static const familyInviteAlreadyMember =
      'That person is already in your family.';
  static const familyInviteNotOwner =
      'Only the household owner can add members.';
  static const familyInviteGenericError = 'Could not add member. Try again.';
  static const familyPersonalNoInvite =
      'Self expense does not support invite, join, or QR sharing.';

  /// Scanned id is not a Supabase auth user (e.g. local-only Profile QR).
  static const familyInviteInvalidAuthUser =
      'That invite is not a cloud account id. Ask the other person to sign in '
      'with cloud sync enabled, then open Profile so their QR shows their account id.';
  static const familyInviteSelfError = 'You cannot add yourself.';
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
  static const cloudSyncRefreshCloudData = 'Refresh cloud data';
  static const cloudSyncUnsyncedLocalDataTitle = 'Local data available';
  static const cloudSyncUnsyncedLocalDataBody =
      'You have local data that is not synced. Sync to cloud now?';
  static const cloudSyncSyncNow = 'Yes, sync now';
  static const cloudSyncNotNow = 'Not now';
  static const cloudSyncPostAuthTitle = 'Sync local data';
  static const cloudSyncPostAuthPromptTitle = 'Data ready to sync';
  static String cloudSyncPostAuthPromptBody(int totalRows) =>
      '$totalRows local item(s) are available to sync to cloud.';
  static const cloudSyncPostAuthBootstrapBody =
      'No local uploads are pending. Download your latest cloud data to this device now?';
  static String cloudSyncPostAuthCloudRowsBody(int totalRows) =>
      'Supabase currently has $totalRows item(s).';
  static String cloudSyncPostAuthLocalRowsBody(int totalRows) =>
      'Local device currently has $totalRows item(s).';
  static const cloudSyncPostAuthCloudRowsUnavailable =
      'Supabase entry count is unavailable right now.';
  static String cloudSyncPostAuthCompareRowsBody(
    int localRows,
    int remoteRows,
  ) => 'Compare: local $localRows vs cloud $remoteRows.';
  static const cloudSyncPostAuthAlreadySyncedStatus =
      'Already synced: local and cloud counts match with no pending changes.';
  static const cloudSyncPostAuthAlreadySyncedAction = 'Already synced (Done)';
  static const cloudSyncPostAuthPreparing = 'Preparing local data';
  static const cloudSyncPostAuthPushing = 'Uploading local changes';
  static const cloudSyncPostAuthPulling = 'Downloading latest cloud data';
  static const cloudSyncPostAuthSuccessTitle = 'Sync completed';
  static const cloudSyncPostAuthSuccessBody =
      'Your local data is now synced to cloud.';
  static const cloudSyncPostAuthBootstrapSuccessBody =
      'Latest cloud data is now available on this device.';
  static const cloudSyncPostAuthFailureTitle = 'Sync failed';
  static const cloudSyncSyncBeforeLogoutTitle = 'Syncing data before logout';
  static const cloudSyncSyncBeforeLogoutPreparing = 'Preparing local data';
  static const cloudSyncSyncBeforeLogoutPushing = 'Uploading local changes';
  static const cloudSyncSyncBeforeLogoutPulling =
      'Downloading latest cloud data';
  static const cloudSyncSyncBeforeLogoutFailureTitle =
      'xSync failed before logout';
  static const cloudSyncRetry = 'Retry';
  static const cloudSyncLogoutWithoutSync = 'Logout without sync';
  static const cloudSyncLogoutWithoutSyncWarning =
      'Unsynced local changes may be lost.';

  static const settingsPrivacyModeTitle = 'Privacy mode';
  static const settingsPrivacyModeSubtitle =
      'Hide Home budget and spending amounts';
  static const privacyShowBalancesSemantics = 'Show balances';
  static const privacyHideBalancesSemantics = 'Hide balances';
  static const settingsBiometricTitle = 'Biometric lock';
  static const settingsBiometricSubtitle = 'Require Face ID';
  static const settingsPushNotifications = 'Push notifications';
  static const preferencesDetailsTitle = 'Preferences';
  static const preferencesRegionalSection = 'Regional';
  static const preferencesCurrencyLabel = 'Currency';
  static const preferencesLanguageLabel = 'Language';
  static const preferencesNumberFormatLabel = 'Number format';
  static const preferencesCategorySection = 'Categories';
  static const preferencesExpenseScopeSection = 'Expense scope';
  static const preferencesDefaultHouseholdLabel = 'Default family';
  static const preferencesDefaultHouseholdHint =
      'New expenses and cloud sync use this household. '
      'Changing this does not move past expenses.';
  static const preferencesDefaultHouseholdSelf = 'Self expense';
  static const preferencesDefaultHouseholdNoOptions =
      'Sign in to choose a default family.';
  static const preferencesDefaultHouseholdSaveFailed =
      'Could not save default family. Check your connection and try again.';
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
  static const expenseLimitsIndicativeDailyLabel = 'Daily plan';
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
  static const expenseCategoryDetailTransactionsTab = 'Transactions';
  static const expenseCategoryDetailTrendTab = 'Trend';
  static const expensePaidByLabel = 'Paid by';
  static const expenseFamilyLabel = 'Family';
  static const expenseFamilyUnset = '—';
  static const expenseFamilyUnknown = 'Unknown';
  static const expenseCategoryDetailTrendEmpty =
      'No spending on this category this month.';
  static const expenseRecordedBy = 'by';
  static const expenseUnknownMember = 'Unknown member';

  /// Shown for expenses created by another signed-in household member (no local display name yet).
  static const expenseHouseholdMemberDisplayName = 'Household member';

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
  static const profileDetailsTitle = 'Profile';
  static const profileDetailsLoadError = 'Could not load profile.';
  static const profileDetailsAvatarSemanticsLabel = 'Profile avatar';
  static const profileDetailsOpenSemanticsLabel = 'Open profile details';
  static const profileDetailsSignOut = 'Sign out';
  static const profileDetailsDeleteLocalData = 'Clear all data';
  static const profileDetailsDeleteConfirmTitle = 'Clear all data?';
  static const profileDetailsDeleteConfirmBody =
      'If you are signed in: deletes your app-owned rows from the cloud (expenses, recurring templates, expense preferences), removes you from households, clears pending family invites you created, then signs out and wipes this device. Your Supabase login is not deleted. Households with no members left may still exist on the server. If you are signed out: only local data on this device is wiped.';
  static const profileDetailsDeleteConfirmButton = 'Clear';
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
