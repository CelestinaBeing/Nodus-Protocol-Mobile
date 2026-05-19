import 'package:flutter/material.dart';

import '../../widgets/token_input.dart';
import '../../widgets/transaction_button.dart';
import 'estimated_lp_tokens.dart';
import 'pool_share_display.dart';

class RemoveLiquidityForm extends StatefulWidget {
  const RemoveLiquidityForm({super.key});

  @override
  State<RemoveLiquidityForm> createState() => _RemoveLiquidityFormState();
}

class _RemoveLiquidityFormState extends State<RemoveLiquidityForm> {
  final _lpController = TextEditingController();
  double _slippage = 0.5;

  @override
  void dispose() {
    _lpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Submit remove liquidity transaction
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TokenInput(
            token: null,
            controller: _lpController,
            hintText: 'LP Token Amount',
          ),
          const SizedBox(height: 16),
          EstimatedLpTokens(
            lpAmount: double.tryParse(_lpController.text) ?? 0.0,
            isRemoving: true,
          ),
          const SizedBox(height: 16),
          const PoolShareDisplay(),
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
            label: 'Remove Liquidity',
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}
