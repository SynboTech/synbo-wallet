import 'dart:convert';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';

import '../models/wallet_models.dart';
import 'gas_service.dart';
import 'wallet_vault_repository.dart';

@immutable
class WalletDataSnapshot {
  const WalletDataSnapshot({
    required this.wallets,
    required this.networks,
    required this.tokens,
    required this.activities,
    required this.activitySyncBlocks,
    required this.activeWalletId,
    required this.activeNetworkId,
    this.lastRefreshedAt,
  });

  final List<WalletProfile> wallets;
  final List<ChainNetwork> networks;
  final List<TokenAsset> tokens;
  final List<ActivityRecord> activities;
  final Map<String, int> activitySyncBlocks;
  final String activeWalletId;
  final String activeNetworkId;
  final DateTime? lastRefreshedAt;

  WalletDataSnapshot copyWith({
    List<WalletProfile>? wallets,
    List<ChainNetwork>? networks,
    List<TokenAsset>? tokens,
    List<ActivityRecord>? activities,
    Map<String, int>? activitySyncBlocks,
    String? activeWalletId,
    String? activeNetworkId,
    DateTime? lastRefreshedAt,
  }) {
    return WalletDataSnapshot(
      wallets: wallets ?? this.wallets,
      networks: networks ?? this.networks,
      tokens: tokens ?? this.tokens,
      activities: activities ?? this.activities,
      activitySyncBlocks: activitySyncBlocks ?? this.activitySyncBlocks,
      activeWalletId: activeWalletId ?? this.activeWalletId,
      activeNetworkId: activeNetworkId ?? this.activeNetworkId,
      lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    );
  }
}

abstract class WalletDataRepository {
  Future<WalletDataSnapshot> load();
  Future<void> save(WalletDataSnapshot snapshot);
}

class SecureStorageWalletDataRepository implements WalletDataRepository {
  SecureStorageWalletDataRepository({
    FlutterSecureStorage? storage,
    WalletDataSnapshot Function()? seedFactory,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _seedFactory = seedFactory ?? WalletSeedFixture.snapshot;

  static const _snapshotKey = 'wallet.data.snapshot.v1';

  final FlutterSecureStorage _storage;
  final WalletDataSnapshot Function() _seedFactory;

  @override
  Future<WalletDataSnapshot> load() async {
    final rawSnapshot = await _storage.read(key: _snapshotKey);
    if (rawSnapshot == null || rawSnapshot.trim().isEmpty) {
      final seedSnapshot = _seedFactory();
      await save(seedSnapshot);
      return seedSnapshot;
    }

    try {
      final decoded = jsonDecode(rawSnapshot) as Map<String, dynamic>;
      return _WalletSnapshotCodec.fromJson(decoded);
    } catch (_) {
      final seedSnapshot = _seedFactory();
      await save(seedSnapshot);
      return seedSnapshot;
    }
  }

  @override
  Future<void> save(WalletDataSnapshot snapshot) {
    return _storage.write(
      key: _snapshotKey,
      value: jsonEncode(_WalletSnapshotCodec.toJson(snapshot)),
    );
  }
}

class SeedWalletDataRepository implements WalletDataRepository {
  SeedWalletDataRepository({WalletDataSnapshot? initialSnapshot})
    : _snapshot = initialSnapshot ?? WalletSeedFixture.snapshot();

  WalletDataSnapshot _snapshot;

  @override
  Future<WalletDataSnapshot> load() async {
    return _snapshot;
  }

  @override
  Future<void> save(WalletDataSnapshot snapshot) async {
    _snapshot = snapshot;
  }
}

abstract class WalletImportGateway {
  String generateMnemonic();
  bool isValidMnemonic(String mnemonic);
  WalletVaultRecord derivePrimaryAccount({
    required String walletId,
    required String mnemonic,
  });
}

class EvmWalletImportGateway implements WalletImportGateway {
  static const defaultDerivationPath = "m/44'/60'/0'/0/0";

  @override
  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  WalletVaultRecord derivePrimaryAccount({
    required String walletId,
    required String mnemonic,
  }) {
    final normalizedMnemonic = mnemonic.trim().toLowerCase();
    if (!isValidMnemonic(normalizedMnemonic)) {
      throw const WalletImportException('Recovery phrase is invalid.');
    }

    final seed = bip39.mnemonicToSeed(normalizedMnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child = root.derivePath(defaultDerivationPath);
    final privateKeyBytes = child.privateKey;
    if (privateKeyBytes == null) {
      throw const WalletImportException(
        'Unable to derive the primary account.',
      );
    }

    final credentials = EthPrivateKey(privateKeyBytes);
    return WalletVaultRecord(
      walletId: walletId,
      mnemonic: normalizedMnemonic,
      derivationPath: defaultDerivationPath,
      privateKeyHex: bytesToHex(privateKeyBytes, include0x: true),
      address: credentials.address.hexEip55,
    );
  }

  @override
  bool isValidMnemonic(String mnemonic) {
    return bip39.validateMnemonic(mnemonic.trim().toLowerCase());
  }
}

abstract class TransactionGateway {
  Future<PendingTransfer> prepareTransfer({
    required String fromAddress,
    required String privateKeyHex,
    required String toAddress,
    required ChainNetwork network,
    required TokenAsset token,
    required String amountText,
  });

  Future<ActivityRecord> submitTransfer({
    required PendingTransfer transfer,
    required String privateKeyHex,
  });
}

class EvmTransactionGateway implements TransactionGateway {
  EvmTransactionGateway({http.Client? httpClient, GasService? gasService})
    : _httpClient = httpClient ?? http.Client(),
      _gasService = gasService ?? GasService();

  static const _erc20TransferAbi =
      '[{"constant":false,"inputs":[{"name":"to","type":"address"},{"name":"value","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"type":"function"}]';

  final http.Client _httpClient;
  final GasService _gasService;

  @override
  Future<PendingTransfer> prepareTransfer({
    required String fromAddress,
    required String privateKeyHex,
    required String toAddress,
    required ChainNetwork network,
    required TokenAsset token,
    required String amountText,
  }) async {
    final normalizedAddress = _normalizeAddress(toAddress);
    final amountInBaseUnits = _parseAmountInput(amountText, token.decimals);
    final client = Web3Client(network.rpcUrl, _httpClient);

    try {
      final sender = EthereumAddress.fromHex(fromAddress);
      final recipient = EthereumAddress.fromHex(normalizedAddress);
      final credentials = EthPrivateKey.fromHex(privateKeyHex);
      if (credentials.address.hexEip55 != sender.hexEip55) {
        throw const TransactionPreparationException(
          'The selected wallet address does not match the stored signing key.',
        );
      }

      final chainId = network.chainId > 0
          ? network.chainId
          : await client.getChainId().then((value) => value.toInt());

      // 构建交易数据（用于估算 gas）
      final transaction = _buildTransaction(
        sender: sender,
        recipient: recipient,
        token: token,
        amountInBaseUnits: amountInBaseUnits,
        nonce: 0, // 临时 nonce，后面会获取真实 nonce
      );

      // EIP-1559 Gas 估算
      final gasEstimate = await _gasService.estimateGas(
        client: client,
        chainId: chainId,
        from: sender,
        to: transaction.to,
        value: transaction.value?.getInWei,
        data: transaction.data,
      );

      // 获取真实 nonce
      final nonce = await client.getTransactionCount(
        sender,
        atBlock: const BlockNum.pending(),
      );

      final gasLimit = gasEstimate.gasLimit.toInt();

      // 计算 gas fee
      final BigInt gasFeeWei;
      final BigInt gasPriceWei;
      final BigInt? maxFeePerGas;
      final BigInt? maxPriorityFeePerGas;
      final BigInt? estimatedBaseFee;
      final bool isEIP1559;

      if (gasEstimate.isEIP1559) {
        isEIP1559 = true;
        maxFeePerGas = gasEstimate.suggestedMaxFeePerGas;
        maxPriorityFeePerGas = gasEstimate.suggestedMaxPriorityFeePerGas;
        estimatedBaseFee = gasEstimate.estimatedBaseFee;
        gasPriceWei = gasEstimate.suggestedMaxFeePerGas; // 兼容 legacy 字段
        gasFeeWei =
            (maxFeePerGas + maxPriorityFeePerGas) * gasEstimate.gasLimit;
      } else {
        isEIP1559 = false;
        maxFeePerGas = null;
        maxPriorityFeePerGas = null;
        estimatedBaseFee = null;
        gasPriceWei = gasEstimate.suggestedMaxFeePerGas;
        gasFeeWei = gasPriceWei * gasEstimate.gasLimit;
      }

      return PendingTransfer(
        from: sender.hexEip55,
        to: recipient.hexEip55,
        network: network,
        token: token,
        amountText: amountText.trim(),
        amount: _formatBaseUnitsAsDouble(amountInBaseUnits, token.decimals),
        amountInBaseUnits: amountInBaseUnits,
        valueInWei: _isNativeToken(token) ? amountInBaseUnits : BigInt.zero,
        gasFee: _formatBaseUnitsAsDouble(gasFeeWei, 18),
        gasFeeWei: gasFeeWei,
        gasPriceWei: gasPriceWei,
        gasLimit: gasLimit,
        nonce: nonce,
        chainId: chainId,
        data: transaction.data,
        riskWarning: _riskWarning(
          token: token,
          network: network,
          toAddress: normalizedAddress,
        ),
        // EIP-1559 字段
        isEIP1559: isEIP1559,
        maxFeePerGas: maxFeePerGas,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        estimatedBaseFee: estimatedBaseFee,
      );
    } on WalletImportException {
      rethrow;
    } on TransactionPreparationException {
      rethrow;
    } on ArgumentError catch (error) {
      throw TransactionPreparationException(
        error.message?.toString() ?? 'The address or amount is invalid.',
      );
    } on FormatException catch (error) {
      throw TransactionPreparationException(error.message);
    } catch (error) {
      throw TransactionPreparationException(_mapTransactionError(error));
    } finally {
      await client.dispose();
    }
  }

  @override
  Future<ActivityRecord> submitTransfer({
    required PendingTransfer transfer,
    required String privateKeyHex,
  }) async {
    final client = Web3Client(transfer.network.rpcUrl, _httpClient);
    try {
      final credentials = EthPrivateKey.fromHex(privateKeyHex);

      // 根据交易类型选择 Transaction 构建方式
      Transaction transaction;
      if (transfer.isEIP1559) {
        transaction = Transaction(
          from: EthereumAddress.fromHex(transfer.from),
          to: transfer.isNativeTransfer
              ? EthereumAddress.fromHex(transfer.to)
              : EthereumAddress.fromHex(transfer.token.contractAddress),
          nonce: transfer.nonce,
          maxFeePerGas: EtherAmount.inWei(transfer.maxFeePerGas!),
          maxPriorityFeePerGas: EtherAmount.inWei(
            transfer.maxPriorityFeePerGas!,
          ),
          maxGas: transfer.gasLimit,
          value: EtherAmount.inWei(transfer.valueInWei),
          data: transfer.data == null
              ? null
              : Uint8List.fromList(transfer.data!),
          // type: 2 is implied by maxFeePerGas/maxPriorityFeePerGas
        );
      } else {
        transaction = Transaction(
          from: EthereumAddress.fromHex(transfer.from),
          to: transfer.isNativeTransfer
              ? EthereumAddress.fromHex(transfer.to)
              : EthereumAddress.fromHex(transfer.token.contractAddress),
          nonce: transfer.nonce,
          gasPrice: EtherAmount.inWei(transfer.gasPriceWei),
          maxGas: transfer.gasLimit,
          value: EtherAmount.inWei(transfer.valueInWei),
          data: transfer.data == null
              ? null
              : Uint8List.fromList(transfer.data!),
        );
      }

      final txHash = await client.sendTransaction(
        credentials,
        transaction,
        chainId: transfer.chainId,
      );
      final activitySuffix = DateTime.now().microsecondsSinceEpoch
          .toRadixString(16);

      return ActivityRecord(
        id: 'activity-$activitySuffix',
        type: transfer.isCancel
            ? ActivityType.send
            : (transfer.isSpeedUp ? ActivityType.send : ActivityType.send),
        status: ActivityStatus.pending,
        title: transfer.isSpeedUp
            ? 'Speed Up ${transfer.token.symbol}'
            : (transfer.isCancel
                  ? 'Cancel ${transfer.token.symbol}'
                  : 'Send ${transfer.token.symbol}'),
        from: transfer.from,
        to: transfer.to,
        networkId: transfer.network.id,
        tokenSymbol: transfer.token.symbol,
        amount: transfer.amount,
        gasFee: transfer.gasFee,
        txHash: txHash,
        occurredAt: DateTime.now(),
        riskNote: transfer.riskWarning,
        dappName: transfer.isReplacement
            ? (transfer.isSpeedUp
                  ? 'Speed Up'
                  : (transfer.isCancel ? 'Cancel' : null))
            : null,
      );
    } catch (error) {
      throw TransactionSubmissionException(_mapTransactionError(error));
    } finally {
      await client.dispose();
    }
  }

  Transaction _buildTransaction({
    required EthereumAddress sender,
    required EthereumAddress recipient,
    required TokenAsset token,
    required BigInt amountInBaseUnits,
    required int nonce,
  }) {
    if (_isNativeToken(token)) {
      return Transaction(
        from: sender,
        to: recipient,
        nonce: nonce,
        value: EtherAmount.inWei(amountInBaseUnits),
      );
    }

    final contract = DeployedContract(
      ContractAbi.fromJson(_erc20TransferAbi, 'ERC20'),
      EthereumAddress.fromHex(token.contractAddress),
    );
    final transferFunction = contract.function('transfer');

    return Transaction.callContract(
      contract: contract,
      function: transferFunction,
      parameters: [recipient, amountInBaseUnits],
      from: sender,
      nonce: nonce,
      value: EtherAmount.zero(),
    );
  }

  bool _isNativeToken(TokenAsset token) {
    return token.contractAddress == 'Native asset';
  }

  String _normalizeAddress(String rawAddress) {
    final address = EthereumAddress.fromHex(rawAddress.trim());
    return address.hexEip55;
  }

  BigInt _parseAmountInput(String amountText, int decimals) {
    final normalized = amountText.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Amount is required.');
    }

    final parts = normalized.split('.');
    if (parts.length > 2) {
      throw const FormatException('Amount format is invalid.');
    }

    final wholePart = parts[0].isEmpty ? '0' : parts[0];
    final fractionPart = parts.length == 2 ? parts[1] : '';
    if (!RegExp(r'^\d+$').hasMatch(wholePart) ||
        (fractionPart.isNotEmpty && !RegExp(r'^\d+$').hasMatch(fractionPart))) {
      throw const FormatException('Amount contains invalid characters.');
    }
    if (fractionPart.length > decimals) {
      throw FormatException(
        'This token supports up to $decimals decimal places.',
      );
    }

    final paddedFraction = fractionPart.padRight(decimals, '0');
    final rawUnits = '$wholePart$paddedFraction';
    final normalizedUnits = rawUnits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final parsed = BigInt.parse(
      normalizedUnits.isEmpty ? '0' : normalizedUnits,
    );
    if (parsed <= BigInt.zero) {
      throw const FormatException('Amount must be greater than 0.');
    }
    return parsed;
  }

  double _formatBaseUnitsAsDouble(BigInt value, int decimals) {
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

  String _riskWarning({
    required TokenAsset token,
    required ChainNetwork network,
    required String toAddress,
  }) {
    if (token.isRisky) {
      return 'This token is marked as unverified. Confirm the contract, recipient, network, amount, gas fee, and total before signing.';
    }
    if (!toAddress.startsWith('0x') || toAddress.length != 42) {
      return 'The recipient format looks unusual. Confirm the full address and selected network before signing.';
    }
    return 'Verify the recipient, network, amount, token, gas fee, and total before confirming. Transfers cannot be reversed.';
  }

  String _mapTransactionError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('insufficient funds')) {
      return 'Insufficient native token balance to cover the transfer and gas fee.';
    }
    if (message.contains('nonce too low')) {
      return 'The account nonce is out of date. Refresh the wallet and try again.';
    }
    if (message.contains('replacement transaction underpriced')) {
      return 'A pending transaction with the same nonce already exists at a higher gas price.';
    }
    if (message.contains('execution reverted')) {
      return 'The network rejected this transaction during simulation.';
    }
    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('clientexception')) {
      return 'Unable to reach the RPC endpoint. Check the selected network configuration.';
    }
    return 'The transaction could not be prepared or submitted. ${error.toString()}';
  }
}

class WalletImportException implements Exception {
  const WalletImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TransactionPreparationException implements Exception {
  const TransactionPreparationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TransactionSubmissionException implements Exception {
  const TransactionSubmissionException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class WalletSeedFixture {
  static final _createdAt = DateTime(2026, 4, 30, 10, 15);

  static WalletDataSnapshot snapshot() {
    return WalletDataSnapshot(
      wallets: [
        WalletProfile(
          id: 'wallet-1',
          name: 'Wallet 1',
          activeAccountId: 'account-1',
          createdAt: _createdAt,
          accounts: const [
            WalletAccount(
              id: 'account-1',
              name: 'Main Account',
              address: '0x12F36A8c91b4eF9a2A436E81eC2D4b478A3B7089',
            ),
            WalletAccount(
              id: 'account-2',
              name: 'Savings',
              address: '0x8C421fA7057180eF5e401aE6eaa47334C9dA41F0',
            ),
          ],
        ),
      ],
      networks: const [
        ChainNetwork(
          id: 'ethereum',
          name: 'Ethereum',
          chainId: 1,
          nativeSymbol: 'ETH',
          rpcUrl: 'https://mainnet.infura.io/v3/demo',
          explorerUrl: 'https://etherscan.io',
          colorValue: 0xFF5B6EE1,
        ),
        ChainNetwork(
          id: 'bnb',
          name: 'BNB Chain',
          chainId: 56,
          nativeSymbol: 'BNB',
          rpcUrl: 'https://bsc-dataseed.binance.org',
          explorerUrl: 'https://bscscan.com',
          colorValue: 0xFFD4A916,
        ),
        ChainNetwork(
          id: 'polygon',
          name: 'Polygon',
          chainId: 137,
          nativeSymbol: 'POL',
          rpcUrl: 'https://polygon-rpc.com',
          explorerUrl: 'https://polygonscan.com',
          colorValue: 0xFF7B3FE4,
        ),
        ChainNetwork(
          id: 'arbitrum',
          name: 'Arbitrum',
          chainId: 42161,
          nativeSymbol: 'ETH',
          rpcUrl: 'https://arb1.arbitrum.io/rpc',
          explorerUrl: 'https://arbiscan.io',
          colorValue: 0xFF2D74C4,
        ),
        ChainNetwork(
          id: 'base',
          name: 'Base',
          chainId: 8453,
          nativeSymbol: 'ETH',
          rpcUrl: 'https://mainnet.base.org',
          explorerUrl: 'https://basescan.org',
          colorValue: 0xFF2364E8,
        ),
      ],
      tokens: const [
        TokenAsset(
          id: 'eth-main',
          name: 'Ethereum',
          symbol: 'ETH',
          decimals: 18,
          balance: 1.2845,
          fiatValue: 4218.30,
          networkId: 'ethereum',
          contractAddress: 'Native asset',
          colorValue: 0xFF5B6EE1,
        ),
        TokenAsset(
          id: 'usdc-main',
          name: 'USD Coin',
          symbol: 'USDC',
          decimals: 6,
          balance: 2480.75,
          fiatValue: 2480.75,
          networkId: 'ethereum',
          contractAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
          colorValue: 0xFF2775CA,
        ),
        TokenAsset(
          id: 'airdrop-main',
          name: 'Airdrop Claim',
          symbol: 'DROP',
          decimals: 18,
          balance: 12000,
          fiatValue: 0.02,
          networkId: 'ethereum',
          contractAddress: '0x000000000000000000000000000000000000dEaD',
          colorValue: 0xFFB3261E,
          isRisky: true,
          riskLabel: 'Unverified token',
        ),
        TokenAsset(
          id: 'bnb-main',
          name: 'BNB',
          symbol: 'BNB',
          decimals: 18,
          balance: 4.92,
          fiatValue: 2968.44,
          networkId: 'bnb',
          contractAddress: 'Native asset',
          colorValue: 0xFFD4A916,
        ),
        TokenAsset(
          id: 'pol-main',
          name: 'Polygon Ecosystem Token',
          symbol: 'POL',
          decimals: 18,
          balance: 850.10,
          fiatValue: 612.07,
          networkId: 'polygon',
          contractAddress: 'Native asset',
          colorValue: 0xFF7B3FE4,
        ),
        TokenAsset(
          id: 'arb-main',
          name: 'Arbitrum',
          symbol: 'ARB',
          decimals: 18,
          balance: 920.45,
          fiatValue: 1049.31,
          networkId: 'arbitrum',
          contractAddress: '0x912CE59144191C1204E64559FE8253a0e49E6548',
          colorValue: 0xFF2D74C4,
        ),
        TokenAsset(
          id: 'base-eth',
          name: 'Ethereum',
          symbol: 'ETH',
          decimals: 18,
          balance: 0.428,
          fiatValue: 1406.12,
          networkId: 'base',
          contractAddress: 'Native asset',
          colorValue: 0xFF2364E8,
        ),
      ],
      activities: [
        ActivityRecord(
          id: 'act-1',
          type: ActivityType.send,
          status: ActivityStatus.success,
          title: 'Send ETH',
          from: '0x12F36A8c91b4eF9a2A436E81eC2D4b478A3B7089',
          to: '0xD8dA6BF26964aF9D7eEd9e03E53415D37aA96045',
          networkId: 'ethereum',
          tokenSymbol: 'ETH',
          amount: 0.12,
          gasFee: 0.0032,
          txHash:
              '0x9b6f2d3a0c5e4f8b1c2d31a9123b60745fc98d53c7b1f9e32b3f71b10a621e44',
          occurredAt: DateTime(2026, 4, 30, 9, 42),
        ),
        ActivityRecord(
          id: 'act-2',
          type: ActivityType.receive,
          status: ActivityStatus.success,
          title: 'Receive USDC',
          from: '0x8A91f4472BC2b3D4a61df9A512eE38C456dD1072',
          to: '0x12F36A8c91b4eF9a2A436E81eC2D4b478A3B7089',
          networkId: 'ethereum',
          tokenSymbol: 'USDC',
          amount: 420.00,
          gasFee: 0.0,
          txHash:
              '0x4a7c2e9f8311ef042d74881d5e7f710e8a4fbe2ef52cb6a79fb96ce5d502aa17',
          occurredAt: DateTime(2026, 4, 29, 16, 8),
        ),
        ActivityRecord(
          id: 'act-3',
          type: ActivityType.send,
          status: ActivityStatus.pending,
          title: 'Send POL',
          from: '0x12F36A8c91b4eF9a2A436E81eC2D4b478A3B7089',
          to: '0x2A4381e6D28D74C8B1419A7D3d6D02Ab17e64d42',
          networkId: 'polygon',
          tokenSymbol: 'POL',
          amount: 75.0,
          gasFee: 0.018,
          txHash:
              '0x2fb49c840ca56e90e60399f3dc6ef4d8b152ad6d3dc60a5d9d8cebb0f9cc11a5',
          occurredAt: DateTime(2026, 4, 30, 10, 3),
          riskNote: 'Pending network confirmation',
        ),
        ActivityRecord(
          id: 'act-4',
          type: ActivityType.signature,
          status: ActivityStatus.success,
          title: 'Message signature',
          from: '0x12F36A8c91b4eF9a2A436E81eC2D4b478A3B7089',
          to: 'app.safe.example',
          networkId: 'ethereum',
          tokenSymbol: 'SIGN',
          amount: 0,
          gasFee: 0,
          txHash: 'local-signature-202604300915',
          occurredAt: DateTime(2026, 4, 30, 9, 15),
          dappName: 'Safe App',
        ),
        ActivityRecord(
          id: 'act-5',
          type: ActivityType.approval,
          status: ActivityStatus.failed,
          title: 'Token approval blocked',
          from: '0x12F36A8c91b4eF9a2A436E81eC2D4b478A3B7089',
          to: '0x000000000000000000000000000000000000dEaD',
          networkId: 'ethereum',
          tokenSymbol: 'DROP',
          amount: 12000,
          gasFee: 0.0011,
          txHash:
              '0x7ce0b5117e853e37acd43a5326f6f22cc4e6bb4c2c2d33e8098f050a0c7e7172',
          occurredAt: DateTime(2026, 4, 28, 13, 25),
          riskNote: 'Suspicious spender address',
          dappName: 'Unknown App',
        ),
      ],
      activitySyncBlocks: const {},
      activeWalletId: 'wallet-1',
      activeNetworkId: 'ethereum',
    );
  }
}

abstract final class _WalletSnapshotCodec {
  static WalletDataSnapshot fromJson(Map<String, dynamic> json) {
    return WalletDataSnapshot(
      wallets: (json['wallets'] as List<dynamic>? ?? const [])
          .map((wallet) => _walletFromJson(wallet as Map<String, dynamic>))
          .toList(growable: false),
      networks: (json['networks'] as List<dynamic>? ?? const [])
          .map((network) => _networkFromJson(network as Map<String, dynamic>))
          .toList(growable: false),
      tokens: (json['tokens'] as List<dynamic>? ?? const [])
          .map((token) => _tokenFromJson(token as Map<String, dynamic>))
          .toList(growable: false),
      activities: (json['activities'] as List<dynamic>? ?? const [])
          .map(
            (activity) => _activityFromJson(activity as Map<String, dynamic>),
          )
          .toList(growable: false),
      activitySyncBlocks:
          (json['activitySyncBlocks'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
          ),
      activeWalletId: json['activeWalletId'] as String? ?? '',
      activeNetworkId: json['activeNetworkId'] as String? ?? '',
      lastRefreshedAt: _dateTimeOrNull(json['lastRefreshedAt'] as String?),
    );
  }

  static Map<String, Object?> toJson(WalletDataSnapshot snapshot) {
    return {
      'wallets': snapshot.wallets.map(_walletToJson).toList(growable: false),
      'networks': snapshot.networks.map(_networkToJson).toList(growable: false),
      'tokens': snapshot.tokens.map(_tokenToJson).toList(growable: false),
      'activities': snapshot.activities
          .map(_activityToJson)
          .toList(growable: false),
      'activitySyncBlocks': snapshot.activitySyncBlocks,
      'activeWalletId': snapshot.activeWalletId,
      'activeNetworkId': snapshot.activeNetworkId,
      'lastRefreshedAt': snapshot.lastRefreshedAt?.toIso8601String(),
    };
  }

  static WalletProfile _walletFromJson(Map<String, dynamic> json) {
    return WalletProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      activeAccountId: json['activeAccountId'] as String? ?? '',
      createdAt:
          _dateTimeOrNull(json['createdAt'] as String?) ?? DateTime.now(),
      accounts: (json['accounts'] as List<dynamic>? ?? const [])
          .map((account) => _accountFromJson(account as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _walletToJson(WalletProfile wallet) {
    return {
      'id': wallet.id,
      'name': wallet.name,
      'activeAccountId': wallet.activeAccountId,
      'createdAt': wallet.createdAt.toIso8601String(),
      'accounts': wallet.accounts.map(_accountToJson).toList(growable: false),
    };
  }

  static WalletAccount _accountFromJson(Map<String, dynamic> json) {
    return WalletAccount(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  static Map<String, Object?> _accountToJson(WalletAccount account) {
    return {'id': account.id, 'name': account.name, 'address': account.address};
  }

  static ChainNetwork _networkFromJson(Map<String, dynamic> json) {
    return ChainNetwork(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      chainId: json['chainId'] as int? ?? 0,
      nativeSymbol: json['nativeSymbol'] as String? ?? '',
      rpcUrl: json['rpcUrl'] as String? ?? '',
      explorerUrl: json['explorerUrl'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF5B6EE1,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  static Map<String, Object?> _networkToJson(ChainNetwork network) {
    return {
      'id': network.id,
      'name': network.name,
      'chainId': network.chainId,
      'nativeSymbol': network.nativeSymbol,
      'rpcUrl': network.rpcUrl,
      'explorerUrl': network.explorerUrl,
      'colorValue': network.colorValue,
      'isCustom': network.isCustom,
    };
  }

  static TokenAsset _tokenFromJson(Map<String, dynamic> json) {
    return TokenAsset(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      decimals: json['decimals'] as int? ?? 18,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      fiatValue: (json['fiatValue'] as num?)?.toDouble() ?? 0,
      networkId: json['networkId'] as String? ?? '',
      contractAddress: json['contractAddress'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF5B6EE1,
      isRisky: json['isRisky'] as bool? ?? false,
      riskLabel: json['riskLabel'] as String?,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  static Map<String, Object?> _tokenToJson(TokenAsset token) {
    return {
      'id': token.id,
      'name': token.name,
      'symbol': token.symbol,
      'decimals': token.decimals,
      'balance': token.balance,
      'fiatValue': token.fiatValue,
      'networkId': token.networkId,
      'contractAddress': token.contractAddress,
      'colorValue': token.colorValue,
      'isRisky': token.isRisky,
      'riskLabel': token.riskLabel,
      'isHidden': token.isHidden,
    };
  }

  static ActivityRecord _activityFromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String? ?? '',
      type: ActivityType.values.byName(
        json['type'] as String? ?? ActivityType.send.name,
      ),
      status: ActivityStatus.values.byName(
        json['status'] as String? ?? ActivityStatus.pending.name,
      ),
      title: json['title'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      networkId: json['networkId'] as String? ?? '',
      tokenSymbol: json['tokenSymbol'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      gasFee: (json['gasFee'] as num?)?.toDouble() ?? 0,
      txHash: json['txHash'] as String? ?? '',
      occurredAt:
          _dateTimeOrNull(json['occurredAt'] as String?) ?? DateTime.now(),
      riskNote: json['riskNote'] as String?,
      dappName: json['dappName'] as String?,
    );
  }

  static Map<String, Object?> _activityToJson(ActivityRecord activity) {
    return {
      'id': activity.id,
      'type': activity.type.name,
      'status': activity.status.name,
      'title': activity.title,
      'from': activity.from,
      'to': activity.to,
      'networkId': activity.networkId,
      'tokenSymbol': activity.tokenSymbol,
      'amount': activity.amount,
      'gasFee': activity.gasFee,
      'txHash': activity.txHash,
      'occurredAt': activity.occurredAt.toIso8601String(),
      'riskNote': activity.riskNote,
      'dappName': activity.dappName,
    };
  }

  static DateTime? _dateTimeOrNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
