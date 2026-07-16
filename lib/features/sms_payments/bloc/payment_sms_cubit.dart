import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_manager/core/logging/app_log.dart';
import 'package:money_manager/features/sms_payments/data/sms_payments_repository.dart';
import 'package:money_manager/features/sms_payments/models/payment_sms_state/payment_sms_state.dart';

class PaymentSmsCubit extends Cubit<PaymentSmsState> {
  PaymentSmsCubit(this._repo) : super(const PaymentSmsState());

  final SmsPaymentsRepository _repo;

  Future<void> bootstrap() async {
    if (!_repo.isAndroid) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final phase = await _repo.resolvePhase();
      if (phase == PaymentSmsPermissionPhase.granted) {
        final items = await _repo.loadCandidates();
        emit(state.copyWith(phase: phase, items: items, loading: false));
      } else {
        emit(state.copyWith(phase: phase, items: const [], loading: false));
      }
    } catch (e, st) {
      logAppError('payment_sms.bootstrap', e, st);
      emit(state.copyWith(loading: false, errorText: e.toString()));
    }
  }

  Future<void> refresh() => bootstrap();

  Future<void> onExplainDismissed() async {
    await _repo.markExplainDone();
    emit(state.copyWith(phase: PaymentSmsPermissionPhase.dismissed, items: const []));
  }

  Future<bool> onExplainAllow() async {
    await _repo.markExplainDone();
    try {
      final granted = await _repo.requestSmsPermission();
      if (granted) {
        final items = await _repo.loadCandidates();
        emit(state.copyWith(
          phase: PaymentSmsPermissionPhase.granted,
          items: items,
          loading: false,
          clearError: true,
        ));
        return true;
      }
      emit(state.copyWith(phase: PaymentSmsPermissionPhase.denied, items: const []));
      return false;
    } catch (e, st) {
      logAppError('payment_sms.request_permission', e, st);
      emit(state.copyWith(phase: PaymentSmsPermissionPhase.denied, errorText: e.toString()));
      return false;
    }
  }

  Future<void> retryPermission() async {
    await _repo.markExplainDone();
    try {
      final granted = await _repo.requestSmsPermission();
      if (granted) {
        final items = await _repo.loadCandidates();
        emit(state.copyWith(
          phase: PaymentSmsPermissionPhase.granted,
          items: items,
          clearError: true,
        ));
        return;
      }
      // Permanently denied — open settings.
      await _repo.openSystemSettings();
      final phase = await _repo.resolvePhase();
      if (phase == PaymentSmsPermissionPhase.granted) {
        final items = await _repo.loadCandidates();
        emit(state.copyWith(phase: phase, items: items));
      } else {
        emit(state.copyWith(phase: PaymentSmsPermissionPhase.denied));
      }
    } catch (e, st) {
      logAppError('payment_sms.retry_permission', e, st);
      emit(state.copyWith(phase: PaymentSmsPermissionPhase.denied, errorText: e.toString()));
    }
  }

  Future<void> markHandled(String key) async {
    await _repo.markHandled(key);
    final next = state.items.where((e) => e.key != key).toList(growable: false);
    emit(state.copyWith(items: next));
  }
}
