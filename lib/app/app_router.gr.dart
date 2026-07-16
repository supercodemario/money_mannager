// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AddExpenseScreen]
class AddExpenseRoute extends PageRouteInfo<AddExpenseRouteArgs> {
  AddExpenseRoute({
    Key? key,
    VoidCallback? onClose,
    int? initialAmountMinor,
    String? initialNote,
    DateTime? initialDate,
    String? sourceKey,
    List<PageRouteInfo>? children,
  }) : super(
         AddExpenseRoute.name,
         args: AddExpenseRouteArgs(
           key: key,
           onClose: onClose,
           initialAmountMinor: initialAmountMinor,
           initialNote: initialNote,
           initialDate: initialDate,
           sourceKey: sourceKey,
         ),
         initialChildren: children,
       );

  static const String name = 'AddExpenseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddExpenseRouteArgs>(
        orElse: () => const AddExpenseRouteArgs(),
      );
      return AddExpenseScreen(
        key: args.key,
        onClose: args.onClose,
        initialAmountMinor: args.initialAmountMinor,
        initialNote: args.initialNote,
        initialDate: args.initialDate,
        sourceKey: args.sourceKey,
      );
    },
  );
}

class AddExpenseRouteArgs {
  const AddExpenseRouteArgs({
    this.key,
    this.onClose,
    this.initialAmountMinor,
    this.initialNote,
    this.initialDate,
    this.sourceKey,
  });

  final Key? key;

  final VoidCallback? onClose;

  final int? initialAmountMinor;

  final String? initialNote;

  final DateTime? initialDate;

  final String? sourceKey;

  @override
  String toString() {
    return 'AddExpenseRouteArgs{key: $key, onClose: $onClose, initialAmountMinor: $initialAmountMinor, initialNote: $initialNote, initialDate: $initialDate, sourceKey: $sourceKey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddExpenseRouteArgs) return false;
    return key == other.key &&
        onClose == other.onClose &&
        initialAmountMinor == other.initialAmountMinor &&
        initialNote == other.initialNote &&
        initialDate == other.initialDate &&
        sourceKey == other.sourceKey;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onClose.hashCode ^
      initialAmountMinor.hashCode ^
      initialNote.hashCode ^
      initialDate.hashCode ^
      sourceKey.hashCode;
}

/// generated route for
/// [AddRecurringPaymentScreen]
class AddRecurringPaymentRoute
    extends PageRouteInfo<AddRecurringPaymentRouteArgs> {
  AddRecurringPaymentRoute({
    Key? key,
    String? editingTemplateId,
    List<PageRouteInfo>? children,
  }) : super(
         AddRecurringPaymentRoute.name,
         args: AddRecurringPaymentRouteArgs(
           key: key,
           editingTemplateId: editingTemplateId,
         ),
         initialChildren: children,
       );

  static const String name = 'AddRecurringPaymentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddRecurringPaymentRouteArgs>(
        orElse: () => const AddRecurringPaymentRouteArgs(),
      );
      return AddRecurringPaymentScreen(
        key: args.key,
        editingTemplateId: args.editingTemplateId,
      );
    },
  );
}

class AddRecurringPaymentRouteArgs {
  const AddRecurringPaymentRouteArgs({this.key, this.editingTemplateId});

  final Key? key;

  final String? editingTemplateId;

  @override
  String toString() {
    return 'AddRecurringPaymentRouteArgs{key: $key, editingTemplateId: $editingTemplateId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddRecurringPaymentRouteArgs) return false;
    return key == other.key && editingTemplateId == other.editingTemplateId;
  }

  @override
  int get hashCode => key.hashCode ^ editingTemplateId.hashCode;
}

/// generated route for
/// [AppShell]
class AppShellRoute extends PageRouteInfo<void> {
  const AppShellRoute({List<PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppShell();
    },
  );
}

/// generated route for
/// [AuthScreen]
class AuthRoute extends PageRouteInfo<void> {
  const AuthRoute({List<PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthScreen();
    },
  );
}

/// generated route for
/// [CategoryManagementScreen]
class CategoryManagementRoute extends PageRouteInfo<void> {
  const CategoryManagementRoute({List<PageRouteInfo>? children})
    : super(CategoryManagementRoute.name, initialChildren: children);

  static const String name = 'CategoryManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoryManagementScreen();
    },
  );
}

/// generated route for
/// [CreateFamilyScreen]
class CreateFamilyRoute extends PageRouteInfo<void> {
  const CreateFamilyRoute({List<PageRouteInfo>? children})
    : super(CreateFamilyRoute.name, initialChildren: children);

  static const String name = 'CreateFamilyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateFamilyScreen();
    },
  );
}

/// generated route for
/// [DaySpendDetailScreen]
class DaySpendDetailRoute extends PageRouteInfo<DaySpendDetailRouteArgs> {
  DaySpendDetailRoute({
    Key? key,
    required DateTime day,
    List<PageRouteInfo>? children,
  }) : super(
         DaySpendDetailRoute.name,
         args: DaySpendDetailRouteArgs(key: key, day: day),
         initialChildren: children,
       );

  static const String name = 'DaySpendDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DaySpendDetailRouteArgs>();
      return DaySpendDetailScreen(key: args.key, day: args.day);
    },
  );
}

class DaySpendDetailRouteArgs {
  const DaySpendDetailRouteArgs({this.key, required this.day});

  final Key? key;

  final DateTime day;

  @override
  String toString() {
    return 'DaySpendDetailRouteArgs{key: $key, day: $day}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DaySpendDetailRouteArgs) return false;
    return key == other.key && day == other.day;
  }

  @override
  int get hashCode => key.hashCode ^ day.hashCode;
}

/// generated route for
/// [ExpenseLimitsScreen]
class ExpenseLimitsRoute extends PageRouteInfo<void> {
  const ExpenseLimitsRoute({List<PageRouteInfo>? children})
    : super(ExpenseLimitsRoute.name, initialChildren: children);

  static const String name = 'ExpenseLimitsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExpenseLimitsScreen();
    },
  );
}

/// generated route for
/// [FamilyListScreen]
class FamilyListRoute extends PageRouteInfo<void> {
  const FamilyListRoute({List<PageRouteInfo>? children})
    : super(FamilyListRoute.name, initialChildren: children);

  static const String name = 'FamilyListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FamilyListScreen();
    },
  );
}

/// generated route for
/// [FamilyMembersScreen]
class FamilyMembersRoute extends PageRouteInfo<FamilyMembersRouteArgs> {
  FamilyMembersRoute({
    Key? key,
    required String householdId,
    required String householdName,
    List<PageRouteInfo>? children,
  }) : super(
         FamilyMembersRoute.name,
         args: FamilyMembersRouteArgs(
           key: key,
           householdId: householdId,
           householdName: householdName,
         ),
         initialChildren: children,
       );

  static const String name = 'FamilyMembersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FamilyMembersRouteArgs>();
      return FamilyMembersScreen(
        key: args.key,
        householdId: args.householdId,
        householdName: args.householdName,
      );
    },
  );
}

class FamilyMembersRouteArgs {
  const FamilyMembersRouteArgs({
    this.key,
    required this.householdId,
    required this.householdName,
  });

  final Key? key;

  final String householdId;

  final String householdName;

  @override
  String toString() {
    return 'FamilyMembersRouteArgs{key: $key, householdId: $householdId, householdName: $householdName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FamilyMembersRouteArgs) return false;
    return key == other.key &&
        householdId == other.householdId &&
        householdName == other.householdName;
  }

  @override
  int get hashCode =>
      key.hashCode ^ householdId.hashCode ^ householdName.hashCode;
}

/// generated route for
/// [HouseholdScanScreen]
class HouseholdScanRoute extends PageRouteInfo<HouseholdScanRouteArgs> {
  HouseholdScanRoute({
    Key? key,
    String? appBarTitle,
    String? scannerHint,
    String? webLeadParagraph,
    String? pasteSheetTitle,
    String? pasteFieldLabel,
    List<PageRouteInfo>? children,
  }) : super(
         HouseholdScanRoute.name,
         args: HouseholdScanRouteArgs(
           key: key,
           appBarTitle: appBarTitle,
           scannerHint: scannerHint,
           webLeadParagraph: webLeadParagraph,
           pasteSheetTitle: pasteSheetTitle,
           pasteFieldLabel: pasteFieldLabel,
         ),
         initialChildren: children,
       );

  static const String name = 'HouseholdScanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HouseholdScanRouteArgs>(
        orElse: () => const HouseholdScanRouteArgs(),
      );
      return HouseholdScanScreen(
        key: args.key,
        appBarTitle: args.appBarTitle,
        scannerHint: args.scannerHint,
        webLeadParagraph: args.webLeadParagraph,
        pasteSheetTitle: args.pasteSheetTitle,
        pasteFieldLabel: args.pasteFieldLabel,
      );
    },
  );
}

class HouseholdScanRouteArgs {
  const HouseholdScanRouteArgs({
    this.key,
    this.appBarTitle,
    this.scannerHint,
    this.webLeadParagraph,
    this.pasteSheetTitle,
    this.pasteFieldLabel,
  });

  final Key? key;

  final String? appBarTitle;

  final String? scannerHint;

  final String? webLeadParagraph;

  final String? pasteSheetTitle;

  final String? pasteFieldLabel;

  @override
  String toString() {
    return 'HouseholdScanRouteArgs{key: $key, appBarTitle: $appBarTitle, scannerHint: $scannerHint, webLeadParagraph: $webLeadParagraph, pasteSheetTitle: $pasteSheetTitle, pasteFieldLabel: $pasteFieldLabel}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HouseholdScanRouteArgs) return false;
    return key == other.key &&
        appBarTitle == other.appBarTitle &&
        scannerHint == other.scannerHint &&
        webLeadParagraph == other.webLeadParagraph &&
        pasteSheetTitle == other.pasteSheetTitle &&
        pasteFieldLabel == other.pasteFieldLabel;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      appBarTitle.hashCode ^
      scannerHint.hashCode ^
      webLeadParagraph.hashCode ^
      pasteSheetTitle.hashCode ^
      pasteFieldLabel.hashCode;
}

/// generated route for
/// [JoinFamilyConfirmScreen]
class JoinFamilyConfirmRoute extends PageRouteInfo<JoinFamilyConfirmRouteArgs> {
  JoinFamilyConfirmRoute({
    Key? key,
    required FamilyInvitePreview preview,
    List<PageRouteInfo>? children,
  }) : super(
         JoinFamilyConfirmRoute.name,
         args: JoinFamilyConfirmRouteArgs(key: key, preview: preview),
         initialChildren: children,
       );

  static const String name = 'JoinFamilyConfirmRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<JoinFamilyConfirmRouteArgs>();
      return JoinFamilyConfirmScreen(key: args.key, preview: args.preview);
    },
  );
}

class JoinFamilyConfirmRouteArgs {
  const JoinFamilyConfirmRouteArgs({this.key, required this.preview});

  final Key? key;

  final FamilyInvitePreview preview;

  @override
  String toString() {
    return 'JoinFamilyConfirmRouteArgs{key: $key, preview: $preview}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JoinFamilyConfirmRouteArgs) return false;
    return key == other.key && preview == other.preview;
  }

  @override
  int get hashCode => key.hashCode ^ preview.hashCode;
}

/// generated route for
/// [MonthDaySpendListingScreen]
class MonthDaySpendListingRoute extends PageRouteInfo<void> {
  const MonthDaySpendListingRoute({List<PageRouteInfo>? children})
    : super(MonthDaySpendListingRoute.name, initialChildren: children);

  static const String name = 'MonthDaySpendListingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MonthDaySpendListingScreen();
    },
  );
}

/// generated route for
/// [MonthlyCategoryDetailScreen]
class MonthlyCategoryDetailRoute
    extends PageRouteInfo<MonthlyCategoryDetailRouteArgs> {
  MonthlyCategoryDetailRoute({
    Key? key,
    required ExpenseRepository repo,
    required String categoryId,
    required DateTime initialMonth,
    ExpenseCategory? category,
    List<PageRouteInfo>? children,
  }) : super(
         MonthlyCategoryDetailRoute.name,
         args: MonthlyCategoryDetailRouteArgs(
           key: key,
           repo: repo,
           categoryId: categoryId,
           initialMonth: initialMonth,
           category: category,
         ),
         initialChildren: children,
       );

  static const String name = 'MonthlyCategoryDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MonthlyCategoryDetailRouteArgs>();
      return MonthlyCategoryDetailScreen(
        key: args.key,
        repo: args.repo,
        categoryId: args.categoryId,
        initialMonth: args.initialMonth,
        category: args.category,
      );
    },
  );
}

class MonthlyCategoryDetailRouteArgs {
  const MonthlyCategoryDetailRouteArgs({
    this.key,
    required this.repo,
    required this.categoryId,
    required this.initialMonth,
    this.category,
  });

  final Key? key;

  final ExpenseRepository repo;

  final String categoryId;

  final DateTime initialMonth;

  final ExpenseCategory? category;

  @override
  String toString() {
    return 'MonthlyCategoryDetailRouteArgs{key: $key, repo: $repo, categoryId: $categoryId, initialMonth: $initialMonth, category: $category}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MonthlyCategoryDetailRouteArgs) return false;
    return key == other.key &&
        repo == other.repo &&
        categoryId == other.categoryId &&
        initialMonth == other.initialMonth &&
        category == other.category;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      repo.hashCode ^
      categoryId.hashCode ^
      initialMonth.hashCode ^
      category.hashCode;
}

/// generated route for
/// [PostLoginCloudSyncScreen]
class PostLoginCloudSyncRoute
    extends PageRouteInfo<PostLoginCloudSyncRouteArgs> {
  PostLoginCloudSyncRoute({
    Key? key,
    required int totalRows,
    int? localRows,
    int? remoteRows,
    bool isBootstrapOnly = false,
    required PostLoginCloudSyncRunner runSync,
    List<PageRouteInfo>? children,
  }) : super(
         PostLoginCloudSyncRoute.name,
         args: PostLoginCloudSyncRouteArgs(
           key: key,
           totalRows: totalRows,
           localRows: localRows,
           remoteRows: remoteRows,
           isBootstrapOnly: isBootstrapOnly,
           runSync: runSync,
         ),
         initialChildren: children,
       );

  static const String name = 'PostLoginCloudSyncRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostLoginCloudSyncRouteArgs>();
      return PostLoginCloudSyncScreen(
        key: args.key,
        totalRows: args.totalRows,
        localRows: args.localRows,
        remoteRows: args.remoteRows,
        isBootstrapOnly: args.isBootstrapOnly,
        runSync: args.runSync,
      );
    },
  );
}

class PostLoginCloudSyncRouteArgs {
  const PostLoginCloudSyncRouteArgs({
    this.key,
    required this.totalRows,
    this.localRows,
    this.remoteRows,
    this.isBootstrapOnly = false,
    required this.runSync,
  });

  final Key? key;

  final int totalRows;

  final int? localRows;

  final int? remoteRows;

  final bool isBootstrapOnly;

  final PostLoginCloudSyncRunner runSync;

  @override
  String toString() {
    return 'PostLoginCloudSyncRouteArgs{key: $key, totalRows: $totalRows, localRows: $localRows, remoteRows: $remoteRows, isBootstrapOnly: $isBootstrapOnly, runSync: $runSync}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostLoginCloudSyncRouteArgs) return false;
    return key == other.key &&
        totalRows == other.totalRows &&
        localRows == other.localRows &&
        remoteRows == other.remoteRows &&
        isBootstrapOnly == other.isBootstrapOnly &&
        runSync == other.runSync;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      totalRows.hashCode ^
      localRows.hashCode ^
      remoteRows.hashCode ^
      isBootstrapOnly.hashCode ^
      runSync.hashCode;
}

/// generated route for
/// [PreferencesDetailsScreen]
class PreferencesDetailsRoute extends PageRouteInfo<void> {
  const PreferencesDetailsRoute({List<PageRouteInfo>? children})
    : super(PreferencesDetailsRoute.name, initialChildren: children);

  static const String name = 'PreferencesDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PreferencesDetailsScreen();
    },
  );
}

/// generated route for
/// [ProfileDetailsScreen]
class ProfileDetailsRoute extends PageRouteInfo<void> {
  const ProfileDetailsRoute({List<PageRouteInfo>? children})
    : super(ProfileDetailsRoute.name, initialChildren: children);

  static const String name = 'ProfileDetailsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileDetailsScreen();
    },
  );
}

/// generated route for
/// [QuickAddScreen]
class QuickAddRoute extends PageRouteInfo<QuickAddRouteArgs> {
  QuickAddRoute({
    Key? key,
    VoidCallback? onClose,
    int? initialAmountMinor,
    String? initialNote,
    DateTime? initialDate,
    String? sourceKey,
    List<PageRouteInfo>? children,
  }) : super(
         QuickAddRoute.name,
         args: QuickAddRouteArgs(
           key: key,
           onClose: onClose,
           initialAmountMinor: initialAmountMinor,
           initialNote: initialNote,
           initialDate: initialDate,
           sourceKey: sourceKey,
         ),
         initialChildren: children,
       );

  static const String name = 'QuickAddRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuickAddRouteArgs>(
        orElse: () => const QuickAddRouteArgs(),
      );
      return QuickAddScreen(
        key: args.key,
        onClose: args.onClose,
        initialAmountMinor: args.initialAmountMinor,
        initialNote: args.initialNote,
        initialDate: args.initialDate,
        sourceKey: args.sourceKey,
      );
    },
  );
}

class QuickAddRouteArgs {
  const QuickAddRouteArgs({
    this.key,
    this.onClose,
    this.initialAmountMinor,
    this.initialNote,
    this.initialDate,
    this.sourceKey,
  });

  final Key? key;

  final VoidCallback? onClose;

  final int? initialAmountMinor;

  final String? initialNote;

  final DateTime? initialDate;

  final String? sourceKey;

  @override
  String toString() {
    return 'QuickAddRouteArgs{key: $key, onClose: $onClose, initialAmountMinor: $initialAmountMinor, initialNote: $initialNote, initialDate: $initialDate, sourceKey: $sourceKey}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuickAddRouteArgs) return false;
    return key == other.key &&
        onClose == other.onClose &&
        initialAmountMinor == other.initialAmountMinor &&
        initialNote == other.initialNote &&
        initialDate == other.initialDate &&
        sourceKey == other.sourceKey;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      onClose.hashCode ^
      initialAmountMinor.hashCode ^
      initialNote.hashCode ^
      initialDate.hashCode ^
      sourceKey.hashCode;
}

/// generated route for
/// [RecurringTemplatesManagementScreen]
class RecurringTemplatesManagementRoute extends PageRouteInfo<void> {
  const RecurringTemplatesManagementRoute({List<PageRouteInfo>? children})
    : super(RecurringTemplatesManagementRoute.name, initialChildren: children);

  static const String name = 'RecurringTemplatesManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RecurringTemplatesManagementScreen();
    },
  );
}

/// generated route for
/// [SyncBeforeLogoutScreen]
class SyncBeforeLogoutRoute extends PageRouteInfo<SyncBeforeLogoutRouteArgs> {
  SyncBeforeLogoutRoute({
    Key? key,
    required LogoutSyncRunner runSync,
    required Future<void> Function() onSyncSuccess,
    required Future<void> Function() onLogoutWithoutSync,
    List<PageRouteInfo>? children,
  }) : super(
         SyncBeforeLogoutRoute.name,
         args: SyncBeforeLogoutRouteArgs(
           key: key,
           runSync: runSync,
           onSyncSuccess: onSyncSuccess,
           onLogoutWithoutSync: onLogoutWithoutSync,
         ),
         initialChildren: children,
       );

  static const String name = 'SyncBeforeLogoutRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SyncBeforeLogoutRouteArgs>();
      return SyncBeforeLogoutScreen(
        key: args.key,
        runSync: args.runSync,
        onSyncSuccess: args.onSyncSuccess,
        onLogoutWithoutSync: args.onLogoutWithoutSync,
      );
    },
  );
}

class SyncBeforeLogoutRouteArgs {
  const SyncBeforeLogoutRouteArgs({
    this.key,
    required this.runSync,
    required this.onSyncSuccess,
    required this.onLogoutWithoutSync,
  });

  final Key? key;

  final LogoutSyncRunner runSync;

  final Future<void> Function() onSyncSuccess;

  final Future<void> Function() onLogoutWithoutSync;

  @override
  String toString() {
    return 'SyncBeforeLogoutRouteArgs{key: $key, runSync: $runSync, onSyncSuccess: $onSyncSuccess, onLogoutWithoutSync: $onLogoutWithoutSync}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SyncBeforeLogoutRouteArgs) return false;
    return key == other.key && runSync == other.runSync;
  }

  @override
  int get hashCode => key.hashCode ^ runSync.hashCode;
}
