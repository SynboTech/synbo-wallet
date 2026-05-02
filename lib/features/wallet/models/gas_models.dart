import 'package:flutter/foundation.dart';

/// EIP-1559 Gas 估算结果
@immutable
class GasEstimate {
  const GasEstimate({
    required this.type,
    required this.gasLimit,
    required this.estimatedBaseFee,
    required this.suggestedMaxFeePerGas,
    required this.suggestedMaxPriorityFeePerGas,
  });

  /// 气体估算类型：EIP-1559 或 Legacy
  final GasEstimateType type;
  final BigInt gasLimit;
  final BigInt estimatedBaseFee;
  final BigInt suggestedMaxFeePerGas;
  final BigInt suggestedMaxPriorityFeePerGas;

  /// Legacy 专用
  BigInt get gasPrice => suggestedMaxFeePerGas;

  bool get isEIP1559 => type == GasEstimateType.feeMarket;
}

enum GasEstimateType {
  /// 传统 gasPrice 模式（type = 0）
  legacy,

  /// EIP-1559 fee market 模式（type = 2）
  feeMarket,
}

/// Gas 建议级别（用于 UI 显示）
enum GasOption { slow, average, fast }

extension GasOptionExtension on GasOption {
  BigInt getPriorityFee(GasEstimate estimate) {
    return switch (this) {
      GasOption.slow =>
        (estimate.suggestedMaxPriorityFeePerGas * BigInt.from(80)) ~/
            BigInt.from(100),
      GasOption.average => estimate.suggestedMaxPriorityFeePerGas,
      GasOption.fast =>
        (estimate.suggestedMaxPriorityFeePerGas * BigInt.from(150)) ~/
            BigInt.from(100),
    };
  }

  BigInt getMaxFee(GasEstimate estimate) {
    return switch (this) {
      GasOption.slow =>
        estimate.estimatedBaseFee +
            ((estimate.suggestedMaxFeePerGas - estimate.estimatedBaseFee) *
                    BigInt.from(80)) ~/
                BigInt.from(100),
      GasOption.average => estimate.suggestedMaxFeePerGas,
      GasOption.fast =>
        estimate.estimatedBaseFee +
            ((estimate.suggestedMaxFeePerGas - estimate.estimatedBaseFee) *
                    BigInt.from(150)) ~/
                BigInt.from(100),
    };
  }

  BigInt getLegacyGasPrice(GasEstimate estimate) {
    return switch (this) {
      GasOption.slow =>
        (estimate.gasPrice * BigInt.from(80)) ~/ BigInt.from(100),
      GasOption.average => estimate.gasPrice,
      GasOption.fast =>
        (estimate.gasPrice * BigInt.from(150)) ~/ BigInt.from(100),
    };
  }
}
