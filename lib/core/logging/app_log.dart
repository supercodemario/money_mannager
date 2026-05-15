import 'dart:developer' as developer;

/// Central place for error logging — use in every `catch` so failures are never silent.
void logAppError(String tag, Object error, [StackTrace? stackTrace]) {
  developer.log(
    error.toString(),
    name: tag,
    error: error is Error ? error : null,
    stackTrace: stackTrace,
    level: 1000, // Level.shout
  );
}
