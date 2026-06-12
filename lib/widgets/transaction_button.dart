import 'package:flutter/material.dart';

class TransactionButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final bool enabled;
  final VoidCallback? onSubmit;

  const TransactionButton({
    super.key,
    required this.label,
    required this.onSubmit,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  State<TransactionButton> createState() => _TransactionButtonState();
}

class _TransactionButtonState extends State<TransactionButton> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final busy = widget.isLoading;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: widget.enabled && !busy ? widget.onSubmit : null,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
