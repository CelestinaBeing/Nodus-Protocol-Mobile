import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pool_provider.dart';

class EstimatedLpTokens extends StatelessWidget {
  final double amountA;
  final double amountB;
  final double? lpAmount;
  final bool isRemoving;

  const EstimatedLpTokens({
    super.key,
    this.amountA = 0,
    this.amountB = 0,
    this.lpAmount,
    this.isRemoving = false,
  });

  @override
  Widget build(BuildContext context) {
    final pool = context.watch<PoolProvider>();
    final stats = pool.pools.isNotEmpty ? pool.pools.first : null;

    String estimate = '—';
    if (stats != null) {
      if (isRemoving && lpAmount != null && lpAmount! > 0) {
        final totalSupply =
            double.tryParse(stats.reserves.lpTotalSupply) ?? 1.0;
        final share = lpAmount! / totalSupply;
        final r0 = double.tryParse(stats.reserves.reserve0) ?? 0;
        final r1 = double.tryParse(stats.reserves.reserve1) ?? 0;
        estimate =
            '≈ ${(share * r0).toStringAsFixed(4)} ${stats.reserves.token0}'
            ' + ${(share * r1).toStringAsFixed(4)} ${stats.reserves.token1}';
      } else if (!isRemoving && (amountA > 0 || amountB > 0)) {
        final r0 = double.tryParse(stats.reserves.reserve0) ?? 1;
        final totalSupply =
            double.tryParse(stats.reserves.lpTotalSupply) ?? 1.0;
        final lpEstimate = (amountA / r0) * totalSupply;
        estimate = '≈ ${lpEstimate.toStringAsFixed(6)} LP';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isRemoving ? 'You will receive' : 'Estimated LP tokens',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(estimate,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
