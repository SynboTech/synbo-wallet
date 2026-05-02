import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../models/wallet_models.dart';

@immutable
class ChainReadResult {
  const ChainReadResult({
    required this.tokens,
    required this.activities,
    required this.latestBlock,
    this.syncedFromBlock,
  });

  final List<TokenAsset> tokens;
  final List<ActivityRecord> activities;
  final int latestBlock;
  final int? syncedFromBlock;
}

abstract class ChainReadGateway {
  Future<ChainReadResult> refresh({
    required String accountAddress,
    required ChainNetwork network,
    required List<TokenAsset> tokens,
    required List<ActivityRecord> activities,
    int? fromBlock,
  });
}

class NoopChainReadGateway implements ChainReadGateway {
  const NoopChainReadGateway();

  @override
  Future<ChainReadResult> refresh({
    required String accountAddress,
    required ChainNetwork network,
    required List<TokenAsset> tokens,
    required List<ActivityRecord> activities,
    int? fromBlock,
  }) async {
    return ChainReadResult(
      tokens: tokens,
      activities: activities,
      latestBlock: fromBlock ?? 0,
      syncedFromBlock: fromBlock,
    );
  }
}

class EvmChainReadGateway implements ChainReadGateway {
  EvmChainReadGateway({http.Client? httpClient, this.logLookback = 1200})
    : _httpClient = httpClient ?? http.Client();

  static const _nativeAssetContractAddress = 'Native asset';
  static const _erc20ReadAbi =
      '[{"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"stateMutability":"view","type":"function"}]';

  final http.Client _httpClient;
  final int logLookback;

  @override
  Future<ChainReadResult> refresh({
    required String accountAddress,
    required ChainNetwork network,
    required List<TokenAsset> tokens,
    required List<ActivityRecord> activities,
    int? fromBlock,
  }) async {
    final client = Web3Client(network.rpcUrl, _httpClient);
    final account = EthereumAddress.fromHex(accountAddress);
    final latestBlock = await client.getBlockNumber();
    final syncFromBlock = max(
      0,
      min(fromBlock ?? max(0, latestBlock - logLookback), latestBlock),
    );

    try {
      final scopedTokens = _ensureNativeToken(
        network: network,
        tokens: tokens.where((token) => token.networkId == network.id).toList(),
      );
      final refreshedTokens = <TokenAsset>[];
      for (final token in scopedTokens) {
        refreshedTokens.add(
          await _refreshToken(
            client: client,
            account: account,
            network: network,
            token: token,
          ),
        );
      }

      final scopedActivities = activities
          .where((activity) => activity.networkId == network.id)
          .toList(growable: true);
      final txGasFees = <String, double>{};
      await _syncPendingReceipts(
        client: client,
        activities: scopedActivities,
        txGasFees: txGasFees,
      );
      await _syncTokenLogs(
        client: client,
        account: account,
        network: network,
        tokens: refreshedTokens,
        activities: scopedActivities,
        fromBlock: syncFromBlock,
        toBlock: latestBlock,
        txGasFees: txGasFees,
      );

      scopedActivities.sort(
        (left, right) => right.occurredAt.compareTo(left.occurredAt),
      );
      return ChainReadResult(
        tokens: refreshedTokens,
        activities: scopedActivities,
        latestBlock: latestBlock,
        syncedFromBlock: latestBlock,
      );
    } on ArgumentError catch (error) {
      throw ChainReadException(error.message?.toString() ?? 'Invalid address.');
    } catch (error) {
      throw ChainReadException(_mapReadError(error));
    } finally {
      await client.dispose();
    }
  }

  List<TokenAsset> _ensureNativeToken({
    required ChainNetwork network,
    required List<TokenAsset> tokens,
  }) {
    if (tokens.any(_isNativeToken)) {
      return tokens;
    }
    return [
      TokenAsset(
        id: '${network.id}-native',
        name: network.name,
        symbol: network.nativeSymbol,
        decimals: 18,
        balance: 0,
        fiatValue: 0,
        networkId: network.id,
        contractAddress: _nativeAssetContractAddress,
        colorValue: network.colorValue,
      ),
      ...tokens,
    ];
  }

  Future<TokenAsset> _refreshToken({
    required Web3Client client,
    required EthereumAddress account,
    required ChainNetwork network,
    required TokenAsset token,
  }) async {
    if (_isNativeToken(token)) {
      final balance = await client.getBalance(account);
      return token.copyWith(
        name: network.name,
        symbol: network.nativeSymbol,
        decimals: 18,
        balance: _formatUnits(balance.getInWei, 18),
      );
    }

    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20ReadAbi, 'ERC20Read'),
      EthereumAddress.fromHex(token.contractAddress),
    );
    final metadata = await Future.wait<Object>([
      _safeCallString(
        client: client,
        contract: contract,
        function: contract.function('name'),
        fallback: token.name,
      ),
      _safeCallString(
        client: client,
        contract: contract,
        function: contract.function('symbol'),
        fallback: token.symbol,
      ),
      _safeCallInt(
        client: client,
        contract: contract,
        function: contract.function('decimals'),
        fallback: token.decimals,
      ),
    ]);
    final decimals = metadata[2] as int;
    final balanceValues = await client.call(
      contract: contract,
      function: contract.function('balanceOf'),
      params: [account],
    );
    final rawBalance = (balanceValues.first as BigInt?) ?? BigInt.zero;

    return token.copyWith(
      name: (metadata[0] as String).trim().isEmpty
          ? token.name
          : metadata[0] as String,
      symbol: (metadata[1] as String).trim().isEmpty
          ? token.symbol
          : (metadata[1] as String).toUpperCase(),
      decimals: decimals,
      balance: _formatUnits(rawBalance, decimals),
    );
  }

  Future<void> _syncPendingReceipts({
    required Web3Client client,
    required List<ActivityRecord> activities,
    required Map<String, double> txGasFees,
  }) async {
    for (var index = 0; index < activities.length; index++) {
      final activity = activities[index];
      if (activity.status != ActivityStatus.pending ||
          !_isTransactionHash(activity.txHash)) {
        continue;
      }

      final receipt = await client.getTransactionReceipt(activity.txHash);
      if (receipt == null) {
        continue;
      }

      final gasFee = _receiptGasFee(receipt);
      txGasFees[activity.txHash.toLowerCase()] = gasFee;
      activities[index] = activity.copyWith(
        status: (receipt.status ?? true)
            ? ActivityStatus.success
            : ActivityStatus.failed,
        gasFee: gasFee > 0 ? gasFee : activity.gasFee,
        occurredAt: receipt.blockNumber.isPending
            ? activity.occurredAt
            : DateTime.now(),
        riskNote: (receipt.status ?? true)
            ? activity.riskNote
            : 'The network reported this transaction as failed.',
      );
    }
  }

  Future<void> _syncTokenLogs({
    required Web3Client client,
    required EthereumAddress account,
    required ChainNetwork network,
    required List<TokenAsset> tokens,
    required List<ActivityRecord> activities,
    required int fromBlock,
    required int toBlock,
    required Map<String, double> txGasFees,
  }) async {
    if (fromBlock > toBlock) {
      return;
    }

    final accountTopic = _topicForAddress(account);
    final knownById = {
      for (final activity in activities) activity.id: activity,
    };
    final knownByHash = <String, ActivityRecord>{
      for (final activity in activities)
        if (_isTransactionHash(activity.txHash))
          activity.txHash.toLowerCase(): activity,
    };

    for (final token in tokens.where((token) => !_isNativeToken(token))) {
      final contract = EthereumAddress.fromHex(token.contractAddress);
      final transferOutgoingLogs = await client.getLogs(
        FilterOptions(
          address: contract,
          fromBlock: BlockNum.exact(fromBlock),
          toBlock: BlockNum.exact(toBlock),
          topics: [
            [_transferTopic],
            [accountTopic],
          ],
        ),
      );
      final transferIncomingLogs = await client.getLogs(
        FilterOptions(
          address: contract,
          fromBlock: BlockNum.exact(fromBlock),
          toBlock: BlockNum.exact(toBlock),
          topics: [
            [_transferTopic],
            const <String?>[],
            [accountTopic],
          ],
        ),
      );
      final approvalLogs = await client.getLogs(
        FilterOptions(
          address: contract,
          fromBlock: BlockNum.exact(fromBlock),
          toBlock: BlockNum.exact(toBlock),
          topics: [
            [_approvalTopic],
            [accountTopic],
          ],
        ),
      );

      final mergedLogs = <FilterEvent>[
        ...transferOutgoingLogs,
        ...transferIncomingLogs,
        ...approvalLogs,
      ];

      for (final log in mergedLogs) {
        final activity = await _activityFromLog(
          client: client,
          log: log,
          network: network,
          token: token,
          accountTopic: accountTopic,
          txGasFees: txGasFees,
        );
        if (activity == null) {
          continue;
        }

        final existingById = knownById[activity.id];
        if (existingById != null) {
          final merged = existingById.copyWith(
            status: activity.status,
            gasFee: activity.gasFee > 0 ? activity.gasFee : existingById.gasFee,
            riskNote: activity.riskNote ?? existingById.riskNote,
          );
          final index = activities.indexWhere((item) => item.id == merged.id);
          if (index != -1) {
            activities[index] = merged;
          }
          knownById[merged.id] = merged;
          knownByHash[merged.txHash.toLowerCase()] = merged;
          continue;
        }

        final txHashKey = activity.txHash.toLowerCase();
        final existingByHash = knownByHash[txHashKey];
        if (existingByHash != null &&
            existingByHash.type == activity.type &&
            existingByHash.tokenSymbol == activity.tokenSymbol) {
          final merged = existingByHash.copyWith(
            status: activity.status,
            gasFee: activity.gasFee > 0
                ? activity.gasFee
                : existingByHash.gasFee,
            title: activity.title,
            amount: activity.amount,
            from: activity.from,
            to: activity.to,
            riskNote: activity.riskNote ?? existingByHash.riskNote,
          );
          final index = activities.indexWhere((item) => item.id == merged.id);
          if (index != -1) {
            activities[index] = merged;
          }
          knownById[merged.id] = merged;
          knownByHash[txHashKey] = merged;
          continue;
        }

        activities.add(activity);
        knownById[activity.id] = activity;
        knownByHash[txHashKey] = activity;
      }
    }
  }

  Future<ActivityRecord?> _activityFromLog({
    required Web3Client client,
    required FilterEvent log,
    required ChainNetwork network,
    required TokenAsset token,
    required String accountTopic,
    required Map<String, double> txGasFees,
  }) async {
    final topics = log.topics;
    final txHash = log.transactionHash;
    if (topics == null || topics.isEmpty || txHash == null) {
      return null;
    }

    final topic0 = topics.first?.toLowerCase();
    final amount = _decodeUint256(log.data);
    if (topic0 == _transferTopic) {
      if (topics.length < 3) {
        return null;
      }
      final isSend = topics[1]?.toLowerCase() == accountTopic.toLowerCase();
      final gasFee = await _resolveGasFee(
        client: client,
        txHash: txHash,
        txGasFees: txGasFees,
      );
      return ActivityRecord(
        id: 'log-${network.id}-${txHash.toLowerCase()}-${log.logIndex ?? 0}',
        type: isSend ? ActivityType.send : ActivityType.receive,
        status: ActivityStatus.success,
        title: '${isSend ? 'Send' : 'Receive'} ${token.symbol}',
        from: _decodeAddressTopic(topics[1]),
        to: _decodeAddressTopic(topics[2]),
        networkId: network.id,
        tokenSymbol: token.symbol,
        amount: _formatUnits(amount, token.decimals),
        gasFee: gasFee,
        txHash: txHash,
        occurredAt: DateTime.now(),
      );
    }

    if (topic0 == _approvalTopic) {
      if (topics.length < 3) {
        return null;
      }
      final gasFee = await _resolveGasFee(
        client: client,
        txHash: txHash,
        txGasFees: txGasFees,
      );
      return ActivityRecord(
        id: 'approval-${network.id}-${txHash.toLowerCase()}-${log.logIndex ?? 0}',
        type: ActivityType.approval,
        status: ActivityStatus.success,
        title: 'Approve ${token.symbol}',
        from: _decodeAddressTopic(topics[1]),
        to: _decodeAddressTopic(topics[2]),
        networkId: network.id,
        tokenSymbol: token.symbol,
        amount: _formatUnits(amount, token.decimals),
        gasFee: gasFee,
        txHash: txHash,
        occurredAt: DateTime.now(),
        riskNote:
            'Token allowance detected on-chain. Confirm the spender and revoke if no longer needed.',
      );
    }

    return null;
  }

  Future<String> _safeCallString({
    required Web3Client client,
    required DeployedContract contract,
    required ContractFunction function,
    required String fallback,
  }) async {
    try {
      final values = await client.call(
        contract: contract,
        function: function,
        params: const [],
      );
      final value = values.first;
      return value is String ? value : fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<int> _safeCallInt({
    required Web3Client client,
    required DeployedContract contract,
    required ContractFunction function,
    required int fallback,
  }) async {
    try {
      final values = await client.call(
        contract: contract,
        function: function,
        params: const [],
      );
      final value = values.first;
      if (value is BigInt) {
        return value.toInt();
      }
      if (value is int) {
        return value;
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<double> _resolveGasFee({
    required Web3Client client,
    required String txHash,
    required Map<String, double> txGasFees,
  }) async {
    final normalizedHash = txHash.toLowerCase();
    final cached = txGasFees[normalizedHash];
    if (cached != null) {
      return cached;
    }
    final receipt = await client.getTransactionReceipt(txHash);
    if (receipt == null) {
      return 0;
    }
    final gasFee = _receiptGasFee(receipt);
    txGasFees[normalizedHash] = gasFee;
    return gasFee;
  }

  double _receiptGasFee(TransactionReceipt receipt) {
    final gasUsed = receipt.gasUsed;
    final gasPrice = receipt.effectiveGasPrice?.getInWei;
    if (gasUsed == null || gasPrice == null) {
      return 0;
    }
    return _formatUnits(gasUsed * gasPrice, 18);
  }

  bool _isNativeToken(TokenAsset token) {
    return token.contractAddress == _nativeAssetContractAddress;
  }

  bool _isTransactionHash(String value) {
    return RegExp(r'^0x[a-fA-F0-9]{64}$').hasMatch(value);
  }

  BigInt _decodeUint256(String? data) {
    if (data == null || data == '0x' || data.isEmpty) {
      return BigInt.zero;
    }
    return hexToInt(data);
  }

  String _decodeAddressTopic(String? topic) {
    final normalized = (topic ?? '').replaceFirst('0x', '');
    if (normalized.length < 40) {
      return '';
    }
    return EthereumAddress.fromHex(
      '0x${normalized.substring(normalized.length - 40)}',
    ).hexEip55;
  }

  String _topicForAddress(EthereumAddress address) {
    final hex = bytesToHex(address.addressBytes, include0x: false);
    return '0x${hex.padLeft(64, '0')}';
  }

  double _formatUnits(BigInt value, int decimals) {
    if (value == BigInt.zero) {
      return 0;
    }

    final negative = value.isNegative;
    var digits = value.abs().toString();
    if (digits.length <= decimals) {
      digits = digits.padLeft(decimals + 1, '0');
    }
    final splitIndex = digits.length - decimals;
    final normalized =
        '${digits.substring(0, splitIndex)}.${digits.substring(splitIndex)}';
    return double.parse('${negative ? '-' : ''}$normalized');
  }

  String _mapReadError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('invalid json rpc response') ||
        message.contains('clientexception') ||
        message.contains('socket') ||
        message.contains('network')) {
      return 'Unable to refresh on-chain data from the selected RPC endpoint.';
    }
    if (message.contains('missing trie node') ||
        message.contains('header not found')) {
      return 'The selected RPC endpoint could not serve the requested chain history.';
    }
    return 'Unable to read chain data. ${error.toString()}';
  }

  static final String _transferTopic = bytesToHex(
    keccakUtf8('Transfer(address,address,uint256)'),
    include0x: true,
  ).toLowerCase();

  static final String _approvalTopic = bytesToHex(
    keccakUtf8('Approval(address,address,uint256)'),
    include0x: true,
  ).toLowerCase();
}

class ChainReadException implements Exception {
  const ChainReadException(this.message);

  final String message;

  @override
  String toString() => message;
}
