import 'package:flutter/foundation.dart';

@immutable
class ChainNetwork {
  const ChainNetwork({
    required this.id,
    required this.name,
    required this.nativeSymbol,
    required this.rpcUrl,
    required this.explorerUrl,
    required this.colorValue,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String nativeSymbol;
  final String rpcUrl;
  final String explorerUrl;
  final int colorValue;
  final bool isCustom;

  ChainNetwork copyWith({
    String? name,
    String? nativeSymbol,
    String? rpcUrl,
    String? explorerUrl,
    int? colorValue,
    bool? isCustom,
  }) {
    return ChainNetwork(
      id: id,
      name: name ?? this.name,
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
  final double balance;
  final double fiatValue;
  final String networkId;
  final String contractAddress;
  final int colorValue;
  final bool isRisky;
  final String? riskLabel;
  final bool isHidden;

  TokenAsset copyWith({
    double? balance,
    double? fiatValue,
    bool? isRisky,
    String? riskLabel,
    bool? isHidden,
  }) {
    return TokenAsset(
      id: id,
      name: name,
      symbol: symbol,
      balance: balance ?? this.balance,
      fiatValue: fiatValue ?? this.fiatValue,
      networkId: networkId,
      contractAddress: contractAddress,
      colorValue: colorValue,
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
    required this.amount,
    required this.gasFee,
    required this.riskWarning,
  });

  final String from;
  final String to;
  final ChainNetwork network;
  final TokenAsset token;
  final double amount;
  final double gasFee;
  final String riskWarning;

  double get total =>
      token.symbol == network.nativeSymbol ? amount + gasFee : amount;
}

enum WalletSetupMode { create, importExisting }
