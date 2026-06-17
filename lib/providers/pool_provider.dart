import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/pool_stats.dart';
import '../services/pool_service.dart';

class PoolProvider extends ChangeNotifier {
  final _service = PoolService();

  List<PoolStats> _pools = [];
  bool _isLoading = false;
  String? _error;
  int _retryCount = 0;
  static const _maxAutoRetries = 3;

  List<PoolStats> get pools => _pools;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _pools.isNotEmpty;

  Future<void> loadPools({bool isRetry = false}) async {
    // Guard against overlapping retries
    if (_isLoading) return;

    _isLoading = true;
    if (!isRetry) _error = null;
    notifyListeners();

    try {
      final stats = await _service.getStats();
      _pools = [stats];
      _error = null;
      _retryCount = 0;
    } catch (e) {
      final userFriendlyMessage = _userFriendlyError(e);
      _error = userFriendlyMessage;

      // Log the raw error for debugging
      if (kDebugMode) {
        print('PoolProvider.loadPools error: $e');
      }

      // Auto-retry with exponential backoff for transient errors
      if (_retryCount < _maxAutoRetries && _isTransientError(e)) {
        _retryCount++;
        final delay = Duration(seconds: 2 * _retryCount); // 2s, 4s, 6s
        _isLoading = false;
        notifyListeners();

        await Future.delayed(delay);
        await loadPools(isRetry: true);
        return;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// User-initiated retry - resets retry count and clears error
  Future<void> retry() async {
    _retryCount = 0;
    _error = null;
    await loadPools();
  }

  /// Convert technical errors to user-friendly messages
  String _userFriendlyError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
          return 'Connection timed out. Check your internet connection.';
        case DioExceptionType.receiveTimeout:
          return 'Server is taking too long to respond. Please try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network.';
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode != null && statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
          return 'Unable to load pool data. Please try again.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        case DioExceptionType.unknown:
          if (e.error.toString().contains('SocketException')) {
            return 'No internet connection. Please check your network.';
          }
          return 'An unexpected error occurred. Please try again.';
        default:
          return 'Unable to load pool data. Please try again.';
      }
    }
    return 'An unexpected error occurred. Please try again.';
  }

  /// Check if error is transient (network issue) and should be retried
  bool _isTransientError(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.type == DioExceptionType.unknown &&
              e.error.toString().contains('SocketException'));
    }
    return false;
  }

  Future<PriceQuote?> getQuote({
    required String amountIn,
    required String tokenIn,
    required String tokenOut,
  }) async {
    try {
      return await _service.getQuote(
        amountIn: amountIn,
        tokenIn: tokenIn,
        tokenOut: tokenOut,
      );
    } catch (_) {
      return null;
    }
  }
}
