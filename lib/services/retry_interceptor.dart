import 'package:dio/dio.dart';

/// A Dio [Interceptor] that retries *transient* failures with exponential
/// backoff.
///
/// Transient failures are connection/timeout errors and HTTP 5xx responses —
/// the kind that commonly resolve themselves on a retry (a flaky mobile
/// connection, a brief backend hiccup, a load-balancer 503).
///
/// Permanent failures are never retried: 4xx responses (e.g. 400, 401, 403,
/// 404), cancelled requests and TLS/certificate errors. Retrying those would
/// only add latency — the outcome will not change. In particular 401 is left
/// alone so the existing token-refresh interceptor can handle it.
///
/// The current attempt number is tracked in [RequestOptions.extra] so that the
/// retried request, which flows back through the full interceptor chain, is
/// counted correctly instead of restarting from scratch.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 300),
  });

  /// The client used to replay the failed request.
  final Dio dio;

  /// Total number of attempts, including the first one. `3` means the original
  /// call plus up to two retries.
  final int maxAttempts;

  /// Delay before the first retry. Each subsequent retry doubles it
  /// (300ms, 600ms, 1200ms, ...).
  final Duration initialDelay;

  static const String _attemptKey = '_retry_attempt';

  /// Whether [err] represents a transient failure worth retrying.
  static bool isRetryable(DioException err) => switch (err.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.transformTimeout ||
        DioExceptionType.connectionError =>
          true,
        DioExceptionType.badResponse => (err.response?.statusCode ?? 0) >= 500,
        DioExceptionType.cancel ||
        DioExceptionType.badCertificate ||
        DioExceptionType.unknown =>
          false,
      };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 1;

    if (!isRetryable(err) || attempt >= maxAttempts) {
      handler.next(err);
      return;
    }

    // Exponential backoff: initialDelay * 2^(attempt - 1).
    final delay = initialDelay * (1 << (attempt - 1));
    await Future<void>.delayed(delay);

    final options = err.requestOptions..extra[_attemptKey] = attempt + 1;

    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      // Retries are exhausted (or the replay hit a non-retryable error); the
      // attempt counter on `options.extra` was already advanced, so the nested
      // call stopped at the limit. Surface the final error to the caller.
      handler.next(e);
    }
  }
}
