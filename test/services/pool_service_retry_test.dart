import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nodus_protocol/services/pool_service.dart';
import 'package:nodus_protocol/services/retry_interceptor.dart';

/// One scripted step of a fake HTTP exchange: either return a [ResponseBody]
/// or throw (to simulate a connection-level failure).
typedef _Step = Future<ResponseBody> Function(RequestOptions options);

/// A minimal [HttpClientAdapter] that replays a fixed sequence of responses,
/// one per call. Once the sequence is exhausted the last step repeats. This
/// lets a test say "fail with 503 twice, then succeed" without any extra
/// mocking dependency.
class _SequenceHttpAdapter implements HttpClientAdapter {
  _SequenceHttpAdapter(this.steps);

  final List<_Step> steps;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final step = steps[callCount < steps.length ? callCount : steps.length - 1];
    callCount++;
    return step(options);
  }

  @override
  void close({bool force = false}) {}
}

_Step _respond(int statusCode, String body) => (options) async =>
    ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

_Step _connectionError() => (options) async =>
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );

const String _statsBody = '{"data":{'
    '"reserves":{"reserve_0":"1000","reserve_1":"2000","token_0":"XLM",'
    '"token_1":"USDC","lp_total_supply":"1500","timestamp_last":1234567890},'
    '"price_token0_in_token1":2.0,"price_token1_in_token0":0.5,'
    '"k_invariant":"2000000","fee_bps":30}}';

Dio _dioWith(_SequenceHttpAdapter adapter, {int maxAttempts = 3}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
  dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      maxAttempts: maxAttempts,
      // Keep the suite fast; backoff timing is not what we assert here.
      initialDelay: const Duration(milliseconds: 1),
    ),
  );
  return dio;
}

void main() {
  group('RetryInterceptor.isRetryable', () {
    DioException error(DioExceptionType type, {int? statusCode}) {
      final options = RequestOptions(path: '/x');
      return DioException(
        requestOptions: options,
        type: type,
        response: statusCode == null
            ? null
            : Response(requestOptions: options, statusCode: statusCode),
      );
    }

    test('retries transient transport failures', () {
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.connectionTimeout)),
        isTrue,
      );
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.sendTimeout)),
        isTrue,
      );
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.receiveTimeout)),
        isTrue,
      );
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.connectionError)),
        isTrue,
      );
    });

    test('retries HTTP 5xx responses', () {
      expect(
        RetryInterceptor.isRetryable(
          error(DioExceptionType.badResponse, statusCode: 503),
        ),
        isTrue,
      );
      expect(
        RetryInterceptor.isRetryable(
          error(DioExceptionType.badResponse, statusCode: 500),
        ),
        isTrue,
      );
    });

    test('does NOT retry 4xx responses (401/403/404)', () {
      for (final code in [400, 401, 403, 404]) {
        expect(
          RetryInterceptor.isRetryable(
            error(DioExceptionType.badResponse, statusCode: code),
          ),
          isFalse,
          reason: '$code should not be retried',
        );
      }
    });

    test('does NOT retry cancellation, certificate errors, or transform timeouts', () {
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.cancel)),
        isFalse,
      );
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.badCertificate)),
        isFalse,
      );
      expect(
        RetryInterceptor.isRetryable(error(DioExceptionType.transformTimeout)),
        isFalse,
      );
    });
  });

  group('PoolService.getStats with retry', () {
    test('recovers after two transient 503s then a 200', () async {
      final adapter = _SequenceHttpAdapter([
        _respond(503, '{"error":"unavailable"}'),
        _respond(503, '{"error":"unavailable"}'),
        _respond(200, _statsBody),
      ]);
      final service = PoolService(dio: _dioWith(adapter));

      final stats = await service.getStats();

      expect(adapter.callCount, 3, reason: 'one original call + two retries');
      expect(stats.feeBps, 30);
      expect(stats.reserves.token0, 'XLM');
    });

    test('recovers after a transient connection error', () async {
      final adapter = _SequenceHttpAdapter([
        _connectionError(),
        _respond(200, _statsBody),
      ]);
      final service = PoolService(dio: _dioWith(adapter));

      final stats = await service.getStats();

      expect(adapter.callCount, 2);
      expect(stats.reserves.token1, 'USDC');
    });

    test('gives up after maxAttempts on persistent 5xx', () async {
      final adapter = _SequenceHttpAdapter([
        _respond(503, '{"error":"unavailable"}'),
      ]);
      final service = PoolService(dio: _dioWith(adapter));

      await expectLater(
        service.getStats(),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            503,
          ),
        ),
      );
      expect(adapter.callCount, 3, reason: 'original + two retries, then stop');
    });

    test('does NOT retry a 401 (left to the auth/refresh interceptor)',
        () async {
      final adapter = _SequenceHttpAdapter([
        _respond(401, '{"error":"unauthorized"}'),
        _respond(200, _statsBody),
      ]);
      final service = PoolService(dio: _dioWith(adapter));

      await expectLater(
        service.getStats(),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      expect(adapter.callCount, 1, reason: '401 must not be retried');
    });

    test('does NOT retry a 404', () async {
      final adapter = _SequenceHttpAdapter([
        _respond(404, '{"error":"not found"}'),
        _respond(200, _statsBody),
      ]);
      final service = PoolService(dio: _dioWith(adapter));

      await expectLater(service.getStats(), throwsA(isA<DioException>()));
      expect(adapter.callCount, 1, reason: '404 must not be retried');
    });
  });
}
