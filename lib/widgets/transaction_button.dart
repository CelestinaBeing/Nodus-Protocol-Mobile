import 'package:flutter/material.dart';

class TransactionButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final Future<void> Function() onSubmit;

  const TransactionButton({
    super.key,
    required this.label,
    this.enabled = true,
    required this.onSubmit,
  });

  @override
  State<TransactionButton> createState() => _TransactionButtonState();
}

class _TransactionButtonState extends State<TransactionButton> {
  bool _loading = false;

  Future<void> _handle() async {
    setState(() => _loading = true);
    try {
      await widget.onSubmit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: widget.enabled && !_loading ? _handle : null,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(widget.label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
