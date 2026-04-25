import 'dart:async';
import 'dart:math';

/// Exponential backoff with optional jitter. Max [maxDelay] caps each wait.
Future<T> withExponentialBackoff<T>({
  required Future<T> Function() action,
  int maxAttempts = 5,
  Duration initialDelay = const Duration(milliseconds: 400),
  Duration maxDelay = const Duration(seconds: 20),
  bool Function(Object error)? isRetryable,
  Random? random,
}) async {
  final rng = random ?? Random();
  var delay = initialDelay;
  Object? lastError;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      lastError = e;
      if (attempt == maxAttempts - 1) rethrow;
      if (isRetryable != null && !isRetryable(e)) rethrow;
      final jitter = Duration(milliseconds: rng.nextInt(200));
      await Future<void>.delayed(delay + jitter);
      final next = Duration(milliseconds: (delay.inMilliseconds * 2).clamp(0, maxDelay.inMilliseconds));
      delay = next;
    }
  }
  throw lastError ?? StateError('backoff');
}
