import 'package:flutter/material.dart';

import '../models/pool_stats.dart';
import '../utils/formatters.dart';

class PoolCard extends StatelessWidget {
  const PoolCard({super.key, required this.pool, this.onTap});

  final PoolStats pool;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(pool.pairLabel,
                      style:
                          tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${pool.feePercent.toStringAsFixed(2)}% fee',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _StatRow(
                label: '${pool.reserves.token0} Reserve',
                value: formatReserve(
                    pool.reserves.reserve0, pool.reserves.token0),
              ),
              const SizedBox(height: 4),
              _StatRow(
                label: '${pool.reserves.token1} Reserve',
                value: formatReserve(
                    pool.reserves.reserve1, pool.reserves.token1),
              ),
              const SizedBox(height: 4),
              _StatRow(
                label: 'Price (${pool.reserves.token0}/${pool.reserves.token1})',
                value: pool.priceToken0InToken1.toStringAsFixed(6),
              ),
              const SizedBox(height: 4),
              _StatRow(
                label: 'LP Supply',
                value: compactNumber(pool.reserves.lpTotalSupply),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

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
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
