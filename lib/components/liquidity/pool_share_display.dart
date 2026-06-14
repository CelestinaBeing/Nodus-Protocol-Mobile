import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/token.dart';
import '../../providers/pool_provider.dart';

class PoolShareDisplay extends StatelessWidget {
  const PoolShareDisplay({
    super.key,
    this.tokenA,
    this.tokenB,
    this.amountA = 0,
    this.amountB = 0,
  });

  final Token? tokenA;
  final Token? tokenB;
  final double amountA;
  final double amountB;

  @override
  Widget build(BuildContext context) {
    final pool = context.watch<PoolProvider>();
    final stats = pool.pools.isNotEmpty ? pool.pools.first : null;

    String shareStr = '—';
    if (stats != null && amountA > 0) {
      final r0 = double.tryParse(stats.reserves.reserve0) ?? 0;
      final totalNew = r0 + amountA;
      final share = totalNew > 0 ? (amountA / totalNew) * 100 : 0.0;
      shareStr = '${share.toStringAsFixed(4)}%';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Pool share',
            value: shareStr,
          ),
          if (stats != null) ...[
            const Divider(height: 16),
            _Row(
              label:
                  '${stats.reserves.token0} per ${stats.reserves.token1}',
              value: stats.priceToken0InToken1.toStringAsFixed(6),
            ),
            const SizedBox(height: 4),
            _Row(
              label:
                  '${stats.reserves.token1} per ${stats.reserves.token0}',
              value: stats.priceToken1InToken0.toStringAsFixed(6),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
