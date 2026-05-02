import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

/// Pending 交易跟踪项
@immutable
class PendingTransaction {
  const PendingTransaction({
    required this.txHash,
    required this.from,
    required this.networkRpcUrl,
    required this.submittedAt,
    this.receipt,
    this.status = PendingTxStatus.pending,
  });

  final String txHash;
  final String from;
  final String networkRpcUrl;
  final DateTime submittedAt;
  final TransactionReceipt? receipt;
  final PendingTxStatus status;

  PendingTransaction copyWith({
    TransactionReceipt? receipt,
    PendingTxStatus? status,
  }) {
    return PendingTransaction(
      txHash: txHash,
      from: from,
      networkRpcUrl: networkRpcUrl,
      submittedAt: submittedAt,
      receipt: receipt ?? this.receipt,
      status: status ?? this.status,
    );
  }
}

enum PendingTxStatus { pending, confirmed, failed, dropped }

/// Receipt 轮询结果回调
typedef OnReceiptCallback =
    void Function(String txHash, TransactionReceipt receipt);

/// TransactionTracker
/// 负责轮询 pending 交易的 receipt，支持退避重试
class TransactionTracker {
  TransactionTracker({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  // 待跟踪的交易
  final _pendingTxs = <String, PendingTransaction>{};

  // 轮询任务
  Timer? _pollTimer;

  // 回调
  OnReceiptCallback? _onReceipt;

  // 轮询间隔（毫秒）
  static const _baseInterval = Duration(seconds: 2);

  // 当前退避乘数
  int _backoffMultiplier = 1;

  /// 设置 receipt 回调
  void setOnReceipt(OnReceiptCallback callback) {
    _onReceipt = callback;
  }

  /// 添加待跟踪交易
  void addPendingTransaction(PendingTransaction tx) {
    _pendingTxs[tx.txHash] = tx;
    _ensurePolling();
  }

  /// 移除交易（不再跟踪）
  void removeTransaction(String txHash) {
    _pendingTxs.remove(txHash);
    if (_pendingTxs.isEmpty) {
      _stopPolling();
    }
  }

  /// 获取当前所有 pending 交易
  List<PendingTransaction> get pendingTransactions =>
      _pendingTxs.values.toList();

  /// 启动轮询
  void _ensurePolling() {
    if (_pollTimer?.isActive ?? false) {
      return;
    }
    _backoffMultiplier = 1;
    _pollTimer = Timer.periodic(_baseInterval, (_) => _poll());
  }

  /// 停止轮询
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _backoffMultiplier = 1;
  }

  /// 轮询所有 pending 交易
  Future<void> _poll() async {
    if (_pendingTxs.isEmpty) {
      _stopPolling();
      return;
    }

    final toRemove = <String>[];

    for (final entry in _pendingTxs.entries) {
      final txHash = entry.key;
      final tx = entry.value;

      try {
        final receipt = await _fetchReceipt(tx);
        if (receipt != null) {
          // 判断状态：web3dart 的 status 是 bool?
          final newStatus = receipt.status == true
              ? PendingTxStatus.confirmed
              : (receipt.status == false
                    ? PendingTxStatus.failed
                    : PendingTxStatus.pending);

          // 更新状态
          _pendingTxs[txHash] = tx.copyWith(
            receipt: receipt,
            status: newStatus,
          );

          // 触发回调
          _onReceipt?.call(txHash, receipt);

          // 确认或失败后移除
          if (newStatus != PendingTxStatus.pending) {
            toRemove.add(txHash);
          }
        }
      } catch (e) {
        // 网络错误，继续轮询
      }
    }

    // 清理已完成的交易
    for (final hash in toRemove) {
      _pendingTxs.remove(hash);
    }

    if (_pendingTxs.isEmpty) {
      _stopPolling();
    } else {
      // 退避：如果网络慢，增加轮询间隔
      _applyBackoff();
    }
  }

  /// 获取交易收据
  Future<TransactionReceipt?> _fetchReceipt(PendingTransaction tx) async {
    final client = Web3Client(tx.networkRpcUrl, _httpClient);
    try {
      return await client.getTransactionReceipt(tx.txHash);
    } finally {
      await client.dispose();
    }
  }

  /// 应用退避策略
  void _applyBackoff() {
    if (_backoffMultiplier < 8) {
      _backoffMultiplier *= 2;
    }
  }

  /// 获取当前轮询间隔
  Duration get currentInterval => _baseInterval * _backoffMultiplier;

  /// 释放资源
  void dispose() {
    _stopPolling();
    _httpClient.close();
  }
}
