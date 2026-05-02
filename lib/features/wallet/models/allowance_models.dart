import 'package:flutter/foundation.dart';
import 'package:web3dart/web3dart.dart';

import 'wallet_models.dart';

/// ERC20 Allowance 信息
@immutable
class TokenAllowance {
  const TokenAllowance({
    required this.tokenContract,
    required this.spender,
    required this.allowance,
    required this.tokenSymbol,
    required this.tokenDecimals,
    required this.networkId,
    required this.networkName,
  });

  /// Token 合约地址
  final EthereumAddress tokenContract;

  /// 被授权的 spender 地址
  final EthereumAddress spender;

  /// 当前 allowance 金额
  final BigInt allowance;

  /// Token 符号（如 USDT、USDC）
  final String tokenSymbol;

  /// Token decimals
  final int tokenDecimals;

  /// 网络 ID
  final String networkId;

  /// 网络名称
  final String networkName;

  /// 最大 ERC20 allowance (2^256 - 1)
  static BigInt get infiniteAllowance => BigInt.parse(
    '115792089237316195423570985008687907853269984665640564039457584007913129639935',
  );

  /// 是否已授权（allowance > 0）
  bool get hasAllowance => allowance > BigInt.zero;

  /// 格式化 allowance 为可读字符串
  String get formattedAllowance {
    if (allowance == BigInt.zero) return '0';
    final digits = allowance.toString();
    if (digits.length <= tokenDecimals) {
      return '0.${digits.padLeft(tokenDecimals + 1, '0')}';
    }
    final splitIndex = digits.length - tokenDecimals;
    return '${digits.substring(0, splitIndex)}.${digits.substring(splitIndex)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenAllowance &&
          runtimeType == other.runtimeType &&
          tokenContract == other.tokenContract &&
          spender == other.spender &&
          networkId == other.networkId;

  @override
  int get hashCode => Object.hash(tokenContract, spender, networkId);
}

/// Allowance 请求类型
enum AllowanceRequestType {
  /// 授权（approve）
  approve,

  /// 撤销授权（revoke）
  revoke,
}

/// Allowance 操作请求
@immutable
class AllowanceRequest {
  const AllowanceRequest({
    required this.token,
    required this.spender,
    required this.amount,
    required this.type,
  });

  final TokenAllowance token;
  final EthereumAddress spender;
  final BigInt amount;
  final AllowanceRequestType type;

  /// 是否是无限授权
  bool get isUnlimited => amount == TokenAllowance.infiniteAllowance;

  /// 返回 "Max" 用于无限授权显示
  String get amountText => isUnlimited ? 'Unlimited' : _formatAmount(amount);

  String _formatAmount(BigInt amount) {
    if (amount == BigInt.zero) return '0';
    final digits = amount.toString();
    if (digits.length <= token.tokenDecimals) {
      return '0.${digits.padLeft(token.tokenDecimals + 1, '0')}';
    }
    final splitIndex = digits.length - token.tokenDecimals;
    return '${digits.substring(0, splitIndex)}.${digits.substring(splitIndex)}';
  }
}

/// Pending Approval 请求（用于交易确认）
@immutable
class PendingApproval {
  const PendingApproval({
    required this.allowanceRequest,
    required this.network,
    required this.gasEstimate,
    required this.riskWarning,
  });

  final AllowanceRequest allowanceRequest;
  final ChainNetwork network;
  final GasEstimate gasEstimate;
  final String riskWarning;

  /// spender 名称（可扩展为 ENS 解析）
  String get spenderLabel => spender.hex;

  EthereumAddress get spender => allowanceRequest.spender;

  String get tokenSymbol => allowanceRequest.token.tokenSymbol;

  String get amountText => allowanceRequest.amountText;

  bool get isRevoke => allowanceRequest.type == AllowanceRequestType.revoke;
}

/// Gas 估算结果（简化版，用于 Approval 交易）
@immutable
class GasEstimate {
  const GasEstimate({required this.gasLimit, required this.suggestedGasPrice});

  final BigInt gasLimit;
  final EtherAmount suggestedGasPrice;

  String get formattedGasPrice {
    final gwei = suggestedGasPrice.getInWei / BigInt.from(1000000000);
    return '${gwei.toStringAsFixed(2)} Gwei';
  }

  String get formattedFee {
    final feeWei = gasLimit * suggestedGasPrice.getInWei;
    final eth = feeWei / BigInt.from(1000000000000000000);
    return '${eth.toStringAsFixed(8)} ETH';
  }
}
