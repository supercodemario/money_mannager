import 'package:flutter/material.dart';
import 'package:money_manager/app/app_services.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final services = AppServices.of(context);
    final uid = await services.profiles.getCurrentUserId();
    final prefs = await services.preferences.getForUser(uid);
    if (!mounted) return;
    setState(() {
      _userId = uid;
      _currency = prefs?.currencyCode ?? 'USD';
      _language = prefs?.languageCode ?? 'en';
      _numberFormat = prefs?.numberFormat ?? 'us';
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
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

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
                child: Text(option.toUpperCase()),
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
