import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pool_stats.dart';
import '../../models/token.dart';
import '../../providers/pool_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/pool_service.dart';
import '../../widgets/token_input.dart';
import '../../widgets/transaction_button.dart';

class SwapCard extends StatefulWidget {
  const SwapCard({super.key});

  @override
  State<SwapCard> createState() => _SwapCardState();
}

class _SwapCardState extends State<SwapCard> {
  final _amountController = TextEditingController();
  final _service = PoolService();

  Token _tokenIn = Token.xlm;
  Token _tokenOut = Token.usdc;
  PriceQuote? _quote;
  bool _loadingQuote = false;
  double _slippage = 0.5;

  // Debounce timer to prevent API spam
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void dispose() {
    _amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onAmountChanged(String value) async {
    // Cancel previous debounce timer
    _debounce?.cancel();

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      setState(() {
        _quote = null;
        _loadingQuote = false;
      });
      return;
    }

    // Set loading state immediately for UX feedback
    setState(() => _loadingQuote = true);

    // Debounce: wait for user to stop typing before making API call
    _debounce = Timer(_debounceDuration, () async {
      if (!mounted) return;
      
      try {
        final q = await context.read<PoolProvider>().getQuote(
              amountIn: value,
              tokenIn: _tokenIn.symbol,
              tokenOut: _tokenOut.symbol,
            );
        if (mounted) {
          setState(() {
            _quote = q;
            _loadingQuote = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _quote = null;
            _loadingQuote = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to get quote: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _flipTokens() {
    // Cancel any pending API calls
    _debounce?.cancel();

    setState(() {
      final tmp = _tokenIn;
      _tokenIn = _tokenOut;
      _tokenOut = tmp;
      _quote = null;
      _loadingQuote = false;
      _amountController.clear();
    });
  }

  Future<void> _submit() async {
    final wallet = context.read<WalletProvider>();
    final txProvider = context.read<TransactionProvider>();

    if (wallet.state != WalletState.connected || wallet.address == null) {
      throw Exception('Please connect your wallet first');
    }
    if (_quote == null) {
      throw Exception('Enter an amount to get a quote');
    }

    final amountOut = double.parse(_quote!.amountOut);
    final minOut = amountOut * (1 - _slippage / 100);
    final deadline =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 300;

    final (amount0Out, amount1Out) = _tokenIn == Token.xlm
        ? ('0', minOut.toStringAsFixed(7))
        : (minOut.toStringAsFixed(7), '0');

    final unsignedTx = await _service.buildSwap({
      'to': wallet.address,
      'amount_0_out': amount0Out,
      'amount_1_out': amount1Out,
      'deadline': deadline,
    });

    txProvider.add(TxRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description:
          'Swap ${_quote!.amountIn} ${_tokenIn.symbol} → ${_tokenOut.symbol}',
      status: TxStatus.pending,
      unsignedTx: unsignedTx,
      createdAt: DateTime.now(),
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction built: ${unsignedTx.note}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TokenInput(
          token: _tokenIn,
          controller: _amountController,
          onChanged: _onAmountChanged,
          hintText: '0.00',
        ),
        const SizedBox(height: 8),
        Center(
          child: IconButton(
            onPressed: _flipTokens,
            icon: const Icon(Icons.swap_vert),
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.outline.withAlpha(80)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_tokenOut.symbol,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (_loadingQuote)
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
              else
                Text(
                  _quote?.amountOut ?? '0.00',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ),
        if (_quote != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Price impact',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey)),
              Text(
                '${_quote!.priceImpactPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: _quote!.priceImpactBps > 100
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Slippage:'),
            const SizedBox(width: 8),
            for (final s in [0.1, 0.5, 1.0]) ...[
              ChoiceChip(
                label: Text('${s.toString().replaceAll('.0', '')}%'),
                selected: _slippage == s,
                onSelected: (_) => setState(() => _slippage = s),
              ),
              const SizedBox(width: 4),
            ],
          ],
        ),
        const SizedBox(height: 24),
        TransactionButton(
          label: 'Swap',
          enabled: wallet.state == WalletState.connected && _quote != null,
          onSubmit: _submit,
        ),
      ],
    );
  }
}
