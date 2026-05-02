import 'package:flutter/foundation.dart';

import 'transaction_tracker.dart';

/// Pending 交易状态
enum PendingTransactionStatus { pending, confirmed, failed, dropped }

/// Pending 交易信息（供 UI 使用）
@immutable
class TrackedPendingTransaction {
  const TrackedPendingTransaction({
    required this.txHash,
    required this.networkRpcUrl,
    required this.submittedAt,
    required this.status,
    this.confirmedAt,
    this.failedReason,
  });

  final String txHash;
  final String networkRpcUrl;
  final DateTime submittedAt;
  final PendingTransactionStatus status;
  final DateTime? confirmedAt;
  final String? failedReason;
}

/// 交易跟踪器单例
/// 负责管理全局的交易跟踪状态
class PendingTransactionMonitor {
  PendingTransactionMonitor._();

  static final PendingTransactionMonitor _instance =
      PendingTransactionMonitor._();
  static PendingTransactionMonitor get instance => _instance;

  final _tracker = TransactionTracker();
  final _trackedTxs = <String, TrackedPendingTransaction>{};

  /// 添加待跟踪交易
  void addTransaction({required String txHash, required String networkRpcUrl}) {
    _tracker.addPendingTransaction(
      PendingTransaction(
        txHash: txHash,
        from: '',
        networkRpcUrl: networkRpcUrl,
        submittedAt: DateTime.now(),
      ),
    );
    _trackedTxs[txHash] = TrackedPendingTransaction(
      txHash: txHash,
      networkRpcUrl: networkRpcUrl,
      submittedAt: DateTime.now(),
      status: PendingTransactionStatus.pending,
    );
  }

  /// 移除交易
  void removeTransaction(String txHash) {
    _tracker.removeTransaction(txHash);
    _trackedTxs.remove(txHash);
  }

  /// 获取交易状态
  TrackedPendingTransaction? getTransaction(String txHash) {
    return _trackedTxs[txHash];
  }

  /// 获取所有 pending 交易
  List<TrackedPendingTransaction> get pendingTransactions => _trackedTxs.values
      .where((tx) => tx.status == PendingTransactionStatus.pending)
      .toList();

  // Reserved for future tracker callback integration
  // ignore: unused_element
  void _updateStatusInternal(String txHash, PendingTxStatus status) {
    final existing = _trackedTxs[txHash];
    if (existing == null) return;

    _trackedTxs[txHash] = TrackedPendingTransaction(
      txHash: txHash,
      networkRpcUrl: existing.networkRpcUrl,
      submittedAt: existing.submittedAt,
      status: _mapStatus(status),
      confirmedAt: status == PendingTxStatus.confirmed ? DateTime.now() : null,
    );
  }

  PendingTransactionStatus _mapStatus(PendingTxStatus status) {
    return switch (status) {
      PendingTxStatus.pending => PendingTransactionStatus.pending,
      PendingTxStatus.confirmed => PendingTransactionStatus.confirmed,
      PendingTxStatus.failed => PendingTransactionStatus.failed,
      PendingTxStatus.dropped => PendingTransactionStatus.dropped,
    };
  }

  /// 释放资源
  void dispose() {
    _tracker.dispose();
  }
}
