class PoolReserves {
  const PoolReserves({
    required this.reserve0,
    required this.reserve1,
    required this.token0,
    required this.token1,
    required this.lpTotalSupply,
    required this.timestampLast,
  });

  factory PoolReserves.fromJson(Map<String, dynamic> json) => PoolReserves(
        reserve0: json['reserve_0'] as String,
        reserve1: json['reserve_1'] as String,
        token0: json['token_0'] as String,
        token1: json['token_1'] as String,
        lpTotalSupply: json['lp_total_supply'] as String,
        timestampLast: (json['timestamp_last'] as num).toInt(),
      );

  final String reserve0;
  final String reserve1;
  final String token0;
  final String token1;
  final String lpTotalSupply;
  final int timestampLast;
}

class PoolStats {
  const PoolStats({
    required this.reserves,
    required this.priceToken0InToken1,
    required this.priceToken1InToken0,
    required this.kInvariant,
    required this.feeBps,
  });

  factory PoolStats.fromJson(Map<String, dynamic> json) => PoolStats(
        reserves: PoolReserves.fromJson(
            json['reserves'] as Map<String, dynamic>),
        priceToken0InToken1:
            (json['price_token0_in_token1'] as num).toDouble(),
        priceToken1InToken0:
            (json['price_token1_in_token0'] as num).toDouble(),
        kInvariant: json['k_invariant'] as String,
        feeBps: (json['fee_bps'] as num).toInt(),
      );

  final PoolReserves reserves;
  final double priceToken0InToken1;
  final double priceToken1InToken0;
  final String kInvariant;
  final int feeBps;

  double get feePercent => feeBps / 100;

  String get pairLabel => '${reserves.token0}/${reserves.token1}';
}

class PriceQuote {
  const PriceQuote({
    required this.amountIn,
    required this.amountOut,
    required this.tokenIn,
    required this.tokenOut,
    required this.feeBps,
    required this.priceImpactBps,
    required this.effectivePrice,
  });

  factory PriceQuote.fromJson(Map<String, dynamic> json) => PriceQuote(
        amountIn: json['amount_in'] as String,
        amountOut: json['amount_out'] as String,
        tokenIn: json['token_in'] as String,
        tokenOut: json['token_out'] as String,
        feeBps: (json['fee_bps'] as num).toInt(),
        priceImpactBps: (json['price_impact_bps'] as num).toInt(),
        effectivePrice: (json['effective_price'] as num).toDouble(),
      );

  final String amountIn;
  final String amountOut;
  final String tokenIn;
  final String tokenOut;
  final int feeBps;
  final int priceImpactBps;
  final double effectivePrice;

  double get priceImpactPercent => priceImpactBps / 100;
}

class UnsignedTx {
  const UnsignedTx({
    required this.contractId,
    required this.function,
    required this.args,
    required this.note,
  });

  factory UnsignedTx.fromJson(Map<String, dynamic> json) => UnsignedTx(
        contractId: json['contract_id'] as String,
        function: json['function'] as String,
        args: json['args'],
        note: json['note'] as String,
      );

  final String contractId;
  final String function;
  final dynamic args;
  final String note;
}
