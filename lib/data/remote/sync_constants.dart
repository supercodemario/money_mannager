/// Values stored in Drift `sync_status` for expenses.
abstract final class SyncStatusValue {
  static const localOnly = 'local_only';
  static const pending = 'pending';
  static const synced = 'synced';
  static const error = 'error';
}
