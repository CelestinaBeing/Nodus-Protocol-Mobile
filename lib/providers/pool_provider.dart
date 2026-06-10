import 'package:flutter/foundation.dart';
import '../models/pool_stats.dart';
import '../services/pool_service.dart';

class PoolProvider extends ChangeNotifier {
  final _service = PoolService();

  List<PoolStats> _pools = [];
  bool _isLoading = false;
  String? _error;

  List<PoolStats> get pools => _pools;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPools() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await _service.getStats();
      _pools = [stats];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
