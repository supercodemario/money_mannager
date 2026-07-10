import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/features/settings/settings-preferences/data/preferences_details_repository.dart';
import 'package:money_manager/features/settings/settings-preferences/models/preferences_details_state/preferences_details_state.dart';
import 'package:money_manager/share/tokens/app_strings.dart';

class PreferencesDetailsCubit extends Cubit<PreferencesDetailsState> {
  PreferencesDetailsCubit(this._repo) : super(const PreferencesDetailsState());

  final PreferencesDetailsRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(phase: PreferencesDetailsPhase.loading));
    try {
      final snapshot = await _repo.loadSnapshot();
      if (snapshot.persistedDefaultHouseholdId != null) {
        await _repo.persistResolvedDefaultIfNeeded(
          snapshot.persistedDefaultHouseholdId,
        );
      }
      if (!isClosed) {
        emit(
          PreferencesDetailsState(
            phase: PreferencesDetailsPhase.ready,
            userId: snapshot.userId,
            currency: snapshot.currency,
            language: snapshot.language,
            numberFormat: snapshot.numberFormat,
            households: snapshot.households,
            defaultHouseholdId: snapshot.defaultHouseholdId,
          ),
        );
      }
    } catch (e, st) {
      logAppError('preferences_details.load', e, st);
      if (!isClosed) {
        emit(const PreferencesDetailsState(phase: PreferencesDetailsPhase.error));
      }
    }
  }

  Future<void> setCurrency(String value) async {
    if (state.phase != PreferencesDetailsPhase.ready) return;
    emit(state.copyWith(currency: value, saving: true));
    try {
      await _saveRegional();
    } catch (e, st) {
      logAppError('preferences_details.set_currency', e, st);
    } finally {
      if (!isClosed) emit(state.copyWith(saving: false));
    }
  }

  Future<void> setLanguage(String value) async {
    if (state.phase != PreferencesDetailsPhase.ready) return;
    emit(state.copyWith(language: value, saving: true));
    try {
      await _saveRegional();
    } catch (e, st) {
      logAppError('preferences_details.set_language', e, st);
    } finally {
      if (!isClosed) emit(state.copyWith(saving: false));
    }
  }

  Future<void> setNumberFormat(String value) async {
    if (state.phase != PreferencesDetailsPhase.ready) return;
    emit(state.copyWith(numberFormat: value, saving: true));
    try {
      await _saveRegional();
    } catch (e, st) {
      logAppError('preferences_details.set_number_format', e, st);
    } finally {
      if (!isClosed) emit(state.copyWith(saving: false));
    }
  }

  Future<void> setDefaultHousehold(String householdId) async {
    if (state.phase != PreferencesDetailsPhase.ready) return;
    try {
      final saved = await _repo.setDefaultHousehold(householdId);
      if (!isClosed) {
        if (saved) {
          emit(
            state.copyWith(
              defaultHouseholdId: householdId,
              clearHouseholdSaveError: true,
            ),
          );
        } else {
          final stored = await _repo.getStoredDefaultHouseholdId();
          emit(
            state.copyWith(
              defaultHouseholdId: stored ?? state.defaultHouseholdId,
              householdSaveError: AppStrings.preferencesDefaultHouseholdSaveFailed,
            ),
          );
        }
      }
    } catch (e, st) {
      logAppError('preferences_details.set_default_household', e, st);
      if (!isClosed) {
        final stored = await _repo.getStoredDefaultHouseholdId();
        emit(
          state.copyWith(
            defaultHouseholdId: stored ?? state.defaultHouseholdId,
            householdSaveError: AppStrings.preferencesDefaultHouseholdSaveFailed,
          ),
        );
      }
    }
  }

  Future<void> _saveRegional() async {
    final uid = state.userId;
    if (uid == null) return;
    await _repo.upsertRegional(
      userId: uid,
      currencyCode: state.currency,
      languageCode: state.language,
      numberFormat: state.numberFormat,
    );
  }
}
