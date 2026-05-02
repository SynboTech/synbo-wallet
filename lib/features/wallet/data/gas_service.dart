import 'dart:typed_data';
import 'package:web3dart/web3dart.dart';

import '../models/gas_models.dart';

/// Gas 估算服务
/// 负责获取网络 gas 建议、管理 EIP-1559 支持检测
class GasService {
  GasService();

  /// 检查网络是否支持 EIP-1559
  /// 通过检查区块的 baseFeePerGas 是否存在来判断
  Future<bool> supportsEIP1559(Web3Client client) async {
    try {
      final block = await client.getBlockInformation();
      // 如果 block 有 baseFeePerGas，说明网络支持 EIP-1559
      return block.baseFeePerGas != null;
    } catch (_) {
      return false;
    }
  }

  /// 估算交易 Gas（自动选择 EIP-1559 或 Legacy）
  Future<GasEstimate> estimateGas({
    required Web3Client client,
    required int chainId,
    required EthereumAddress from,
    EthereumAddress? to,
    BigInt? value,
    Uint8List? data,
    BigInt? gasPrice,
  }) async {
    final supports1559 = await supportsEIP1559(client);

    // 先获取基础估算
    final estimatedGas = await client.estimateGas(
      sender: from,
      to: to,
      value: value != null ? EtherAmount.inWei(value) : null,
      data: data,
      gasPrice: gasPrice != null ? EtherAmount.inWei(gasPrice) : null,
    );

    // 估算结果缓冲（+10%），防止 gas 不足导致 revert
    final gasLimit = (estimatedGas * BigInt.from(110)) ~/ BigInt.from(100);

    if (supports1559) {
      return _estimateEIP1559(client: client, gasLimit: gasLimit);
    } else {
      return _estimateLegacy(client: client, gasLimit: gasLimit);
    }
  }

  Future<GasEstimate> _estimateEIP1559({
    required Web3Client client,
    required BigInt gasLimit,
  }) async {
    try {
      // 获取 baseFee（从最新区块）
      final baseFee = await _fetchBaseFee(client);

      // 获取 priority fee（从最近几笔交易估算）
      final priorityFee = await _estimatePriorityFee(client);

      // 计算 maxFee = baseFee + priorityFee
      final maxFee = baseFee != null
          ? baseFee + priorityFee
          : priorityFee * BigInt.from(2);

      return GasEstimate(
        type: GasEstimateType.feeMarket,
        gasLimit: gasLimit,
        estimatedBaseFee: baseFee ?? priorityFee,
        suggestedMaxFeePerGas: maxFee,
        suggestedMaxPriorityFeePerGas: priorityFee,
      );
    } catch (_) {
      // 回退到 legacy
      return _estimateLegacy(client: client, gasLimit: gasLimit);
    }
  }

  Future<GasEstimate> _estimateLegacy({
    required Web3Client client,
    required BigInt gasLimit,
  }) async {
    final gasPrice = await client.getGasPrice();
    return GasEstimate(
      type: GasEstimateType.legacy,
      gasLimit: gasLimit,
      estimatedBaseFee: BigInt.zero,
      suggestedMaxFeePerGas: gasPrice.getInWei,
      suggestedMaxPriorityFeePerGas: BigInt.zero,
    );
  }

  /// 获取当前 baseFee（通过请求最新区块）
  Future<BigInt?> _fetchBaseFee(Web3Client client) async {
    try {
      final block = await client.getBlockInformation();
      return block.baseFeePerGas?.getInWei;
    } catch (_) {
      return null;
    }
  }

  /// 估算 priority fee（通过获取历史区块的 baseFee 来估算）
  Future<BigInt> _estimatePriorityFee(Web3Client client) async {
    try {
      final latestBlock = await client.getBlockNumber();
      final recentBaseFees = <BigInt>[];

      for (var i = 1; i <= 5; i++) {
        final blockNum = latestBlock - i;
        try {
          final block = await client.getBlockInformation(
            blockNumber: '0x${blockNum.toRadixString(16)}',
          );
          if (block.baseFeePerGas != null) {
            recentBaseFees.add(block.baseFeePerGas!.getInWei);
          }
        } catch (_) {
          // 忽略获取失败的区块
        }
      }

      if (recentBaseFees.isEmpty) {
        // 默认 2 gwei
        return BigInt.from(2 * 1000000000);
      }

      // 取中位数 baseFee 作为参考，priority fee 通常是 0.5-2 gwei
      recentBaseFees.sort();
      final medianBaseFee = recentBaseFees[recentBaseFees.length ~/ 2];
      // priority fee 取 baseFee 的 10% 或至少 1 gwei
      final priorityFee = medianBaseFee ~/ BigInt.from(10);
      return priorityFee < BigInt.from(1000000000)
          ? BigInt.from(1000000000) // 至少 1 gwei
          : priorityFee;
    } catch (_) {
      return BigInt.from(2 * 1000000000);
    }
  }
}
