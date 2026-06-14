import 'package:flutter/foundation.dart';

import '../models/pool_stats.dart';

enum TxStatus { pending, success, failed }

class TxRecord {
  const TxRecord({
    required this.id,
    required this.description,
    required this.status,
    this.unsignedTx,
    required this.createdAt,
  });

  final String id;
  final String description;
  final TxStatus status;
  final UnsignedTx? unsignedTx;
  final DateTime createdAt;

  TxRecord copyWith({TxStatus? status}) => TxRecord(
        id: id,
        description: description,
        status: status ?? this.status,
        unsignedTx: unsignedTx,
        createdAt: createdAt,
      );
}

class TransactionProvider extends ChangeNotifier {
  final List<TxRecord> _transactions = [];

  List<TxRecord> get transactions => List.unmodifiable(_transactions);

  List<TxRecord> get pending =>
      _transactions.where((t) => t.status == TxStatus.pending).toList();

  void add(TxRecord tx) {
    _transactions.insert(0, tx);
    notifyListeners();
  }

  void updateStatus(String id, TxStatus status) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _transactions[idx] = _transactions[idx].copyWith(status: status);
      notifyListeners();
    }
  }

  void clear() {
    _transactions.clear();
    notifyListeners();
  }
}
