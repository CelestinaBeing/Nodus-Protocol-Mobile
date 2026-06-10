import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/token.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/pool_service.dart';
import '../../widgets/token_input.dart';
import '../../widgets/transaction_button.dart';
import 'estimated_lp_tokens.dart';
import 'pool_share_display.dart';

class AddLiquidityForm extends StatefulWidget {
  const AddLiquidityForm({super.key});

  @override
  State<AddLiquidityForm> createState() => _AddLiquidityFormState();
}

class _AddLiquidityFormState extends State<AddLiquidityForm> {
  final _tokenAController = TextEditingController();
  final _tokenBController = TextEditingController();
  final _service = PoolService();
  double _slippage = 0.5;

  final Token _tokenA = Token.xlm;
  final Token _tokenB = Token.usdc;

  @override
  void dispose() {
    _tokenAController.dispose();
    _tokenBController.dispose();
    super.dispose();
  }

  void _onTokenAChanged(String value) {
    setState(() {});
  }

  void _onTokenBChanged(String value) {
    setState(() {});
  }

  Future<void> _submit() async {
    final wallet = context.read<WalletProvider>();
    final txProvider = context.read<TransactionProvider>();

    if (wallet.state != WalletState.connected || wallet.address == null) {
      throw Exception('Please connect your wallet first');
    }
    final amountA = double.tryParse(_tokenAController.text);
    final amountB = double.tryParse(_tokenBController.text);
    if (amountA == null || amountA <= 0 || amountB == null || amountB <= 0) {
      throw Exception('Enter valid amounts for both tokens');
    }

    final minA = amountA * (1 - _slippage / 100);
    final minB = amountB * (1 - _slippage / 100);
    final deadline =
        (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 300;

    final unsignedTx = await _service.buildAddLiquidity({
      'from': wallet.address,
      'to': wallet.address,
      'amount_0_desired': amountA.toStringAsFixed(7),
      'amount_1_desired': amountB.toStringAsFixed(7),
      'amount_0_min': minA.toStringAsFixed(7),
      'amount_1_min': minB.toStringAsFixed(7),
      'deadline': deadline,
    });

    txProvider.add(TxRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description:
          'Add ${_tokenAController.text} ${_tokenA.symbol} + ${_tokenBController.text} ${_tokenB.symbol}',
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
      _tokenAController.clear();
      _tokenBController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TokenInput(
            token: _tokenA,
            controller: _tokenAController,
            onChanged: _onTokenAChanged,
          ),
          const SizedBox(height: 8),
          const Icon(Icons.add),
          const SizedBox(height: 8),
          TokenInput(
            token: _tokenB,
            controller: _tokenBController,
            onChanged: _onTokenBChanged,
          ),
          const SizedBox(height: 16),
          EstimatedLpTokens(
            amountA: double.tryParse(_tokenAController.text) ?? 0.0,
            amountB: double.tryParse(_tokenBController.text) ?? 0.0,
          ),
          const SizedBox(height: 16),
          PoolShareDisplay(
            tokenA: _tokenA,
            tokenB: _tokenB,
            amountA: double.tryParse(_tokenAController.text) ?? 0.0,
            amountB: double.tryParse(_tokenBController.text) ?? 0.0,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Slippage:'),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('0.1%'),
                selected: _slippage == 0.1,
                onSelected: (_) => setState(() => _slippage = 0.1),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('0.5%'),
                selected: _slippage == 0.5,
                onSelected: (_) => setState(() => _slippage = 0.5),
              ),
              const SizedBox(width: 4),
              ChoiceChip(
                label: const Text('1%'),
                selected: _slippage == 1.0,
                onSelected: (_) => setState(() => _slippage = 1.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TransactionButton(
            label: 'Add Liquidity',
            enabled: wallet.state == WalletState.connected,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}
