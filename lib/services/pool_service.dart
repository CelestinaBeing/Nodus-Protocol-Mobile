import '../models/pool_stats.dart';
import 'api_client.dart';

class PoolService {
  final _dio = apiClient.dio;

  Future<PoolReserves> getReserves() async {
    final resp = await _dio.get('/pool/reserves');
    return PoolReserves.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<PriceQuote> getQuote({
    required String amountIn,
    required String tokenIn,
    required String tokenOut,
  }) async {
    final resp = await _dio.get('/pool/quote', queryParameters: {
      'amount_in': amountIn,
      'token_in': tokenIn,
      'token_out': tokenOut,
    });
    return PriceQuote.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<String> getLpBalance(String address) async {
    final resp = await _dio.get(
      '/pool/lp-balance',
      queryParameters: {'address': address},
    );
    return resp.data['data']['lp_balance'] as String;
  }

  Future<PoolStats> getStats() async {
    final resp = await _dio.get('/pool/stats');
    return PoolStats.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<UnsignedTx> buildSwap(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/pool/build/swap', data: payload);
    return UnsignedTx.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<UnsignedTx> buildAddLiquidity(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/pool/build/add-liquidity', data: payload);
    return UnsignedTx.fromJson(resp.data['data'] as Map<String, dynamic>);
  }

  Future<UnsignedTx> buildRemoveLiquidity(Map<String, dynamic> payload) async {
    final resp = await _dio.post('/pool/build/remove-liquidity', data: payload);
    return UnsignedTx.fromJson(resp.data['data'] as Map<String, dynamic>);
  }
}
