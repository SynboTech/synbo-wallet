import 'package:flutter_test/flutter_test.dart';
import 'package:multi_chain_wallet/features/wallet/models/gas_models.dart';

void main() {
  group('GasEstimate', () {
    test('should create legacy gas estimate', () {
      final estimate = GasEstimate(
        type: GasEstimateType.legacy,
        gasLimit: BigInt.from(21000),
        estimatedBaseFee: BigInt.zero,
        suggestedMaxFeePerGas: BigInt.from(20000000000), // 20 Gwei
        suggestedMaxPriorityFeePerGas: BigInt.zero,
      );

      expect(estimate.type, GasEstimateType.legacy);
      expect(estimate.gasLimit, BigInt.from(21000));
      expect(estimate.isEIP1559, false);
    });

    test('should create EIP-1559 gas estimate', () {
      final estimate = GasEstimate(
        type: GasEstimateType.feeMarket,
        gasLimit: BigInt.from(100000),
        estimatedBaseFee: BigInt.from(30000000000), // 30 Gwei
        suggestedMaxFeePerGas: BigInt.from(35000000000), // 35 Gwei
        suggestedMaxPriorityFeePerGas: BigInt.from(5000000000), // 5 Gwei
      );

      expect(estimate.type, GasEstimateType.feeMarket);
      expect(estimate.isEIP1559, true);
      expect(estimate.suggestedMaxFeePerGas > estimate.estimatedBaseFee, true);
    });

    test('should return gasPrice for legacy', () {
      final estimate = GasEstimate(
        type: GasEstimateType.legacy,
        gasLimit: BigInt.from(21000),
        estimatedBaseFee: BigInt.zero,
        suggestedMaxFeePerGas: BigInt.from(20000000000), // 20 Gwei
        suggestedMaxPriorityFeePerGas: BigInt.zero,
      );

      expect(estimate.gasPrice, BigInt.from(20000000000));
    });
  });

  group('GasOption', () {
    test('should calculate slow priority fee', () {
      final estimate = GasEstimate(
        type: GasEstimateType.feeMarket,
        gasLimit: BigInt.from(100000),
        estimatedBaseFee: BigInt.from(30000000000),
        suggestedMaxFeePerGas: BigInt.from(35000000000),
        suggestedMaxPriorityFeePerGas: BigInt.from(5000000000),
      );

      final priorityFee = GasOption.slow.getPriorityFee(estimate);
      // slow = 80% of original
      expect(priorityFee, BigInt.from(4000000000));
    });

    test('should calculate fast priority fee', () {
      final estimate = GasEstimate(
        type: GasEstimateType.feeMarket,
        gasLimit: BigInt.from(100000),
        estimatedBaseFee: BigInt.from(30000000000),
        suggestedMaxFeePerGas: BigInt.from(35000000000),
        suggestedMaxPriorityFeePerGas: BigInt.from(5000000000),
      );

      final priorityFee = GasOption.fast.getPriorityFee(estimate);
      // fast = 150% of original
      expect(priorityFee, BigInt.from(7500000000));
    });

    test('should calculate legacy gas price for slow', () {
      final estimate = GasEstimate(
        type: GasEstimateType.legacy,
        gasLimit: BigInt.from(21000),
        estimatedBaseFee: BigInt.zero,
        suggestedMaxFeePerGas: BigInt.from(20000000000),
        suggestedMaxPriorityFeePerGas: BigInt.zero,
      );

      final gasPrice = GasOption.slow.getLegacyGasPrice(estimate);
      // slow = 80% of gasPrice
      expect(gasPrice, BigInt.from(16000000000));
    });

    test('should get max fee for fast option', () {
      final estimate = GasEstimate(
        type: GasEstimateType.feeMarket,
        gasLimit: BigInt.from(100000),
        estimatedBaseFee: BigInt.from(30000000000),
        suggestedMaxFeePerGas: BigInt.from(35000000000),
        suggestedMaxPriorityFeePerGas: BigInt.from(5000000000),
      );

      final maxFee = GasOption.fast.getMaxFee(estimate);
      // fast = estimatedBaseFee + 150% of (suggestedMaxFeePerGas - estimatedBaseFee)
      final expectedBaseFee = BigInt.from(30000000000);
      final diff = BigInt.from(5000000000);
      final expected = expectedBaseFee + (diff * BigInt.from(150) ~/ BigInt.from(100));
      expect(maxFee, expected);
    });
  });

  group('GasEstimateType', () {
    test('should have correct values', () {
      expect(GasEstimateType.values.length, 2);
      expect(GasEstimateType.legacy, isNotNull);
      expect(GasEstimateType.feeMarket, isNotNull);
    });
  });
}