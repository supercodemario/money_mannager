import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
import 'package:money_manager/data/local/sync_metadata_store.dart';
import 'package:money_manager/data/remote/household_remote_gateway.dart';
import 'package:money_manager/features/settings/view/category_management_screen.dart';
import 'package:money_manager/share/share.dart';

class PreferencesDetailsScreen extends StatefulWidget {
  const PreferencesDetailsScreen({super.key});

  @override
  State<PreferencesDetailsScreen> createState() => _PreferencesDetailsScreenState();
}

class _PreferencesDetailsScreenState extends State<PreferencesDetailsScreen> {
  static const _currencies = ['USD', 'EUR', 'INR'];
  static const _languages = ['en', 'es', 'fr'];
  static const _numberFormats = ['us', 'eu', 'in'];

  String _currency = 'USD';
  String _language = 'en';
  String _numberFormat = 'us';
  bool _loading = true;
  String? _userId;
  List<HouseholdSummaryRow> _households = const [];
  String? _defaultHouseholdId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final services = AppServices.of(context);
    final uid = await services.profiles.getCurrentUserId();
    final prefs = await services.preferences.getForUser(uid);
    List<HouseholdSummaryRow> households = const [];
    String? defaultHouseholdId;
    if (services.cloudSync.syncAllowed) {
      await services.cloudSync.ensurePersonalHousehold();
      households = await services.household.fetchHouseholdsForCurrentUser();
      defaultHouseholdId =
          await SyncMetadataStore.getDefaultExpenseHouseholdId();
      if (defaultHouseholdId != null &&
          households.every((h) => h.householdId != defaultHouseholdId)) {
        defaultHouseholdId = null;
      }
      if (defaultHouseholdId == null && households.isNotEmpty) {
        final self = households.where((h) => h.isPersonal).toList();
        defaultHouseholdId = self.isNotEmpty
            ? self.first.householdId
            : households.first.householdId;
        await services.cloudSync.setDefaultExpenseHousehold(defaultHouseholdId);
      }
    }
    if (!mounted) return;
    setState(() {
      _userId = uid;
      _currency = prefs?.currencyCode ?? 'USD';
      _language = prefs?.languageCode ?? 'en';
      _numberFormat = prefs?.numberFormat ?? 'us';
      _households = households;
      _defaultHouseholdId = defaultHouseholdId;
      _loading = false;
    });
  }

  Future<void> _savePrefs() async {
    final uid = _userId;
    if (uid == null) return;
    await AppServices.of(context).preferences.upsertForUser(
      userId: uid,
      currencyCode: _currency,
      languageCode: _language,
      numberFormat: _numberFormat,
    );
  }

  Future<void> _setDefaultHousehold(String householdId) async {
    await AppServices.of(context).cloudSync.setDefaultExpenseHousehold(
      householdId,
    );
    if (!mounted) return;
    setState(() => _defaultHouseholdId = householdId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.preferencesDetailsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          Text(
            AppStrings.preferencesRegionalSection,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s16),
            borderRadius: AppRadius.xl,
            child: Column(
              children: [
                _PreferenceDropdown(
                  label: AppStrings.preferencesCurrencyLabel,
                  value: _currency,
                  options: _currencies,
                  onChanged: (v) async {
                    setState(() => _currency = v);
                    await _savePrefs();
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                _PreferenceDropdown(
                  label: AppStrings.preferencesLanguageLabel,
                  value: _language,
                  options: _languages,
                  onChanged: (v) async {
                    setState(() => _language = v);
                    await _savePrefs();
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                _PreferenceDropdown(
                  label: AppStrings.preferencesNumberFormatLabel,
                  value: _numberFormat,
                  options: _numberFormats,
                  onChanged: (v) async {
                    setState(() => _numberFormat = v);
                    await _savePrefs();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s20),
          Text(
            AppStrings.preferencesExpenseScopeSection,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s16),
            borderRadius: AppRadius.xl,
            child: _households.isEmpty
                ? Text(
                    AppStrings.preferencesDefaultHouseholdNoOptions,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.preferencesDefaultHouseholdHint,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      _PreferenceDropdown(
                        label: AppStrings.preferencesDefaultHouseholdLabel,
                        value:
                            _defaultHouseholdId ?? _households.first.householdId,
                        options: _households.map((h) => h.householdId).toList(),
                        optionLabel: (id) {
                          final row = _households.firstWhere(
                            (h) => h.householdId == id,
                            orElse: () => _households.first,
                          );
                          if (row.isPersonal) {
                            return AppStrings.preferencesDefaultHouseholdSelf;
                          }
                          return row.name;
                        },
                        onChanged: _setDefaultHousehold,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.s20),
          Text(
            AppStrings.preferencesCategorySection,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.s8),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.s16),
            borderRadius: AppRadius.xl,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.category_outlined),
              title: const Text(AppStrings.preferencesManageCategories),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (context) => const CategoryManagementScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceDropdown extends StatelessWidget {
  const _PreferenceDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.optionLabel,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String Function(String value)? optionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        DropdownButton<String>(
          value: value,
          items: [
            for (final option in options)
              DropdownMenuItem<String>(
                value: option,
                child: Text(optionLabel?.call(option) ?? option.toUpperCase()),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
