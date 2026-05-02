import 'package:flutter/foundation.dart';

@immutable
class ChainNetwork {
  const ChainNetwork({
    required this.id,
    required this.name,
    required this.chainId,
    required this.nativeSymbol,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.colorValue,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final int chainId;
  final String nativeSymbol;
  final String rpcUrl;
  final String explorerUrl;
  final int colorValue;
  final bool isCustom;

  ChainNetwork copyWith({
    String? name,
    int? chainId,
    String? nativeSymbol,
    String? rpcUrl,
    String? explorerUrl,
    int? colorValue,
    bool? isCustom,
  }) {
    return ChainNetwork(
      id: id,
      name: name ?? this.name,
      chainId: chainId ?? this.chainId,
      nativeSymbol: nativeSymbol ?? this.nativeSymbol,
      rpcUrl: rpcUrl ?? this.rpcUrl,
      explorerUrl: explorerUrl ?? this.explorerUrl,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

@immutable
class WalletAccount {
  const WalletAccount({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;
}

@immutable
class WalletProfile {
  const WalletProfile({
    required this.id,
    required this.name,
    required this.accounts,
    required this.activeAccountId,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<WalletAccount> accounts;
  final String activeAccountId;
  final DateTime createdAt;

  WalletAccount get activeAccount =>
      accounts.firstWhere((account) => account.id == activeAccountId);

  WalletProfile copyWith({
    String? name,
    List<WalletAccount>? accounts,
    String? activeAccountId,
  }) {
    return WalletProfile(
      id: id,
      name: name ?? this.name,
      accounts: accounts ?? this.accounts,
      activeAccountId: activeAccountId ?? this.activeAccountId,
      createdAt: createdAt,
    );
  }
}

@immutable
class TokenAsset {
  const TokenAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.balance,
    required this.fiatValue,
    required this.networkId,
    required this.contractAddress,
    required this.colorValue,
    this.isRisky = false,
    this.riskLabel,
    this.isHidden = false,
  });

  final String id;
  final String name;
  final String symbol;
  final int decimals;
  final double balance;
  final double fiatValue;
  final String networkId;
  final String contractAddress;
  final int colorValue;
  final bool isRisky;
  final String? riskLabel;
  final bool isHidden;

  TokenAsset copyWith({
    String? name,
    String? symbol,
    int? decimals,
    double? balance,
    double? fiatValue,
    String? networkId,
    String? contractAddress,
    int? colorValue,
    bool? isRisky,
    String? riskLabel,
    bool? isHidden,
  }) {
    return TokenAsset(
      id: id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      balance: balance ?? this.balance,
      fiatValue: fiatValue ?? this.fiatValue,
      networkId: networkId ?? this.networkId,
      contractAddress: contractAddress ?? this.contractAddress,
      colorValue: colorValue ?? this.colorValue,
      isRisky: isRisky ?? this.isRisky,
      riskLabel: riskLabel ?? this.riskLabel,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

enum ActivityType { send, receive, signature, approval }

enum ActivityStatus { pending, success, failed }

enum ActivityFilter { all, send, receive, pending, failed, signature, approval }

@immutable
class ActivityRecord {
  const ActivityRecord({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.from,
    required this.to,
    required this.networkId,
    required this.tokenSymbol,
    required this.amount,
    required this.gasFee,
    required this.txHash,
    required this.occurredAt,
    this.riskNote,
    this.dappName,
  });

  final String id;
  final ActivityType type;
  final ActivityStatus status;
  final String title;
  final String from;
  final String to;
  final String networkId;
  final String tokenSymbol;
  final double amount;
  final double gasFee;
  final String txHash;
  final DateTime occurredAt;
  final String? riskNote;
  final String? dappName;

  ActivityRecord copyWith({
    ActivityType? type,
    ActivityStatus? status,
    String? title,
    String? from,
    String? to,
    String? networkId,
    String? tokenSymbol,
    double? amount,
    double? gasFee,
    String? txHash,
    DateTime? occurredAt,
    String? riskNote,
    String? dappName,
  }) {
    return ActivityRecord(
      id: id,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      from: from ?? this.from,
      to: to ?? this.to,
      networkId: networkId ?? this.networkId,
      tokenSymbol: tokenSymbol ?? this.tokenSymbol,
      amount: amount ?? this.amount,
      gasFee: gasFee ?? this.gasFee,
      txHash: txHash ?? this.txHash,
      occurredAt: occurredAt ?? this.occurredAt,
      riskNote: riskNote ?? this.riskNote,
      dappName: dappName ?? this.dappName,
    );
  }

  bool matches(ActivityFilter filter) {
    return switch (filter) {
      ActivityFilter.all => true,
      ActivityFilter.send => type == ActivityType.send,
      ActivityFilter.receive => type == ActivityType.receive,
      ActivityFilter.pending => status == ActivityStatus.pending,
      ActivityFilter.failed => status == ActivityStatus.failed,
      ActivityFilter.signature => type == ActivityType.signature,
      ActivityFilter.approval => type == ActivityType.approval,
    };
  }
}

@immutable
class PendingTransfer {
  const PendingTransfer({
    required this.from,
    required this.to,
    required this.network,
    required this.token,
    required this.amountText,
    required this.amount,
    required this.amountInBaseUnits,
    required this.valueInWei,
    required this.gasFee,
    required this.gasFeeWei,
    required this.gasPriceWei,
    required this.gasLimit,
    required this.nonce,
    required this.chainId,
    this.data,
    required this.riskWarning,
    // EIP-1559 支持
    this.isEIP1559 = false,
    this.maxFeePerGas,
    this.maxPriorityFeePerGas,
    this.estimatedBaseFee,
    // Speed Up / Cancel
    this.originalTxHash,
    this.isSpeedUp = false,
    this.isCancel = false,
  });

  final String from;
  final String to;
  final ChainNetwork network;
  final TokenAsset token;
  final String amountText;
  final double amount;
  final BigInt amountInBaseUnits;
  final BigInt valueInWei;
  final double gasFee;
  final BigInt gasFeeWei;
  final BigInt gasPriceWei;
  final int gasLimit;
  final int nonce;
  final int chainId;
  final List<int>? data;
  final String riskWarning;

  // EIP-1559 字段
  final bool isEIP1559;
  final BigInt? maxFeePerGas;
  final BigInt? maxPriorityFeePerGas;
  final BigInt? estimatedBaseFee;

  // Speed Up / Cancel
  final String? originalTxHash;
  final bool isSpeedUp;
  final bool isCancel;

  bool get isNativeTransfer => data == null;

  bool get isReplacement => isSpeedUp || isCancel || originalTxHash != null;

  double get total =>
      token.symbol == network.nativeSymbol ? amount + gasFee : amount;
}

enum WalletSetupMode { create, importExisting }
