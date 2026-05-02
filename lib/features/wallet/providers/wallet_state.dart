import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../../../app/wallet_dependencies.dart';
import '../../security/data/security_repository.dart';
import '../data/wallet_chain_read_gateway.dart';
import '../data/wallet_data_repository.dart';
import '../data/wallet_vault_repository.dart';
import '../models/wallet_models.dart';

class WalletAppState extends ChangeNotifier {
  WalletAppState({required WalletAppDependencies dependencies})
    : _dependencies = dependencies,
      _httpClient = dependencies.httpClient;

  static const bootstrapPassword = '12345678';
  static const _defaultSecuritySettings = SecuritySettingsSnapshot(
    hideBalances: false,
    biometricEnabled: false,
    screenshotProtectionEnabled: true,
    notificationsEnabled: true,
    autoLockMinutes: 5,
  );
  static const _developmentSeedMnemonic =
      'test test test test test test test test test test test junk';

  final WalletAppDependencies _dependencies;
  final Client _httpClient;

  late List<WalletProfile> _wallets;
  late List<ChainNetwork> _networks;
  late List<TokenAsset> _tokens;
  late List<ActivityRecord> _activities;
  late Map<String, int> _activitySyncBlocks;
  late String _activeWalletId;
  late String _activeNetworkId;

  bool _isInitialized = false;
  bool _isUnlocked = false;
  bool _hideBalances = false;
  bool _isRefreshing = false;
  String? _assetError;
  DateTime? _lastRefreshedAt;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _screenshotProtectionEnabled = true;
  bool _notificationsEnabled = true;
  int _autoLockMinutes = 5;
  DateTime? _backgroundedAt;

  bool get isInitialized => _isInitialized;
  bool get isUnlocked => _isUnlocked;
  bool get hideBalances => _hideBalances;
  bool get isRefreshing => _isRefreshing;
  String? get assetError => _assetError;
  DateTime? get lastRefreshedAt => _lastRefreshedAt;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  bool get canUseBiometrics => _biometricEnabled && _biometricAvailable;
  bool get screenshotProtectionEnabled => _screenshotProtectionEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  int get autoLockMinutes => _autoLockMinutes;
  bool get isReadyForSensitiveActions => _isUnlocked && _isInitialized;

  List<WalletProfile> get wallets => List.unmodifiable(_wallets);
  List<ChainNetwork> get networks => List.unmodifiable(_networks);
  List<TokenAsset> get tokens => List.unmodifiable(_tokens);
  List<ActivityRecord> get activities => List.unmodifiable(_activities);

  WalletProfile get currentWallet => _wallets.firstWhere(
    (wallet) => wallet.id == _activeWalletId,
    orElse: () => _wallets.first,
  );

  WalletAccount get currentAccount => currentWallet.activeAccount;

  ChainNetwork get currentNetwork => networkById(_activeNetworkId);

  double get totalAssetsUsd => _tokens
      .where((token) => !token.isHidden)
      .fold(0, (sum, token) => sum + token.fiatValue);

  List<TokenAsset> get visibleTokens => _tokens
      .where((token) => !token.isHidden && token.networkId == _activeNetworkId)
      .toList(growable: false);

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    final snapshot = await _dependencies.dataRepository.load();
    final securityProfile = await _dependencies.securityRepository.readProfile(
      bootstrapPassword: bootstrapPassword,
      fallbackSettings: _defaultSecuritySettings,
    );
    _wallets = snapshot.wallets.toList(growable: true);
    _networks = snapshot.networks.toList(growable: true);
    _tokens = snapshot.tokens.toList(growable: true);
    _activities = snapshot.activities.toList(growable: true);
    _activitySyncBlocks = Map<String, int>.from(snapshot.activitySyncBlocks);
    _activeWalletId = snapshot.activeWalletId;
    _activeNetworkId = snapshot.activeNetworkId;
    _lastRefreshedAt = snapshot.lastRefreshedAt;
    await _ensureWalletVaults();
    _hideBalances = securityProfile.settings.hideBalances;
    _biometricEnabled = securityProfile.settings.biometricEnabled;
    _screenshotProtectionEnabled =
        securityProfile.settings.screenshotProtectionEnabled;
    _notificationsEnabled = securityProfile.settings.notificationsEnabled;
    _autoLockMinutes = securityProfile.settings.autoLockMinutes;
    _biometricAvailable = await _dependencies.deviceSecurityService
        .isBiometricAvailable();
    await _dependencies.deviceSecurityService.setScreenshotProtection(
      _screenshotProtectionEnabled,
    );
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> unlock(String password) async {
    final isValid = await _dependencies.securityRepository.verifyPassword(
      password,
    );
    if (!isValid) {
      return false;
    }
    _isUnlocked = true;
    notifyListeners();
    return true;
  }

  Future<bool> unlockWithBiometrics() async {
    if (!canUseBiometrics) {
      return false;
    }
    final authenticated = await _dependencies.deviceSecurityService
        .authenticate(reason: '使用生物识别解锁钱包');
    if (!authenticated) {
      return false;
    }
    _isUnlocked = true;
    notifyListeners();
    return true;
  }

  void lock() {
    if (!_isUnlocked) {
      return;
    }
    _isUnlocked = false;
    notifyListeners();
  }

  void onLifecycleChanged(AppLifecycleState state) {
    if (!_isInitialized) {
      return;
    }
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _backgroundedAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        if (_backgroundedAt != null && _isUnlocked) {
          final elapsed = DateTime.now().difference(_backgroundedAt!);
          if (elapsed.inMinutes >= _autoLockMinutes) {
            lock();
          }
        }
        _backgroundedAt = null;
      case AppLifecycleState.detached:
        _backgroundedAt = DateTime.now();
    }
  }

  Future<bool> authorizeSensitiveAction({
    String? password,
    String reason = '验证身份以继续操作',
  }) async {
    if (password != null && password.trim().isNotEmpty) {
      return _dependencies.securityRepository.verifyPassword(password);
    }
    if (!canUseBiometrics) {
      return false;
    }
    return _dependencies.deviceSecurityService.authenticate(reason: reason);
  }

  Future<void> configurePassword(String password) async {
    final trimmed = password.trim();
    if (trimmed.length < 8) {
      return;
    }
    await _dependencies.securityRepository.writePassword(trimmed);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.trim().length < 8) {
      return false;
    }
    final verified = await _dependencies.securityRepository.verifyPassword(
      currentPassword,
    );
    if (!verified) {
      return false;
    }
    await _dependencies.securityRepository.writePassword(newPassword.trim());
    return true;
  }

  ChainNetwork networkById(String id) => _networks.firstWhere(
    (network) => network.id == id,
    orElse: () => _networks.first,
  );

  TokenAsset? tokenById(String id) {
    for (final token in _tokens) {
      if (token.id == id) {
        return token;
      }
    }
    return null;
  }

  List<ActivityRecord> activitiesForFilter(ActivityFilter filter) {
    return _activities
        .where((activity) => activity.matches(filter))
        .toList(growable: false);
  }

  List<ActivityRecord> activitiesForToken(TokenAsset token) {
    return _activities
        .where(
          (activity) =>
              activity.tokenSymbol == token.symbol &&
              activity.networkId == token.networkId,
        )
        .toList(growable: false);
  }

  ActivityRecord? activityById(String id) {
    for (final activity in _activities) {
      if (activity.id == id) {
        return activity;
      }
    }
    return null;
  }

  void switchNetwork(String id) {
    _activeNetworkId = id;
    notifyListeners();
    unawaited(_persistData());
    unawaited(refreshAssets());
  }

  void switchWallet(String id) {
    final index = _wallets.indexWhere((wallet) => wallet.id == id);
    if (index == -1) {
      return;
    }
    _activeWalletId = _wallets[index].id;
    notifyListeners();
    unawaited(_persistData());
    unawaited(refreshAssets());
  }

  void switchAccount(String id) {
    final wallet = currentWallet;
    if (!wallet.accounts.any((account) => account.id == id)) {
      return;
    }
    final index = _wallets.indexWhere((item) => item.id == wallet.id);
    _wallets[index] = wallet.copyWith(activeAccountId: id);
    notifyListeners();
    unawaited(_persistData());
    unawaited(refreshAssets());
  }

  void renameCurrentWallet(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final index = _wallets.indexWhere(
      (wallet) => wallet.id == currentWallet.id,
    );
    _wallets[index] = currentWallet.copyWith(name: trimmed);
    notifyListeners();
    unawaited(_persistData());
  }

  Future<void> toggleHideBalances() async {
    _hideBalances = !_hideBalances;
    notifyListeners();
    await _persistSecurity();
  }

  Future<void> refreshAssets() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    _assetError = null;
    notifyListeners();
    try {
      final result = await _dependencies.chainReadGateway.refresh(
        accountAddress: currentAccount.address,
        network: currentNetwork,
        tokens: _tokens,
        activities: _activities,
        fromBlock: _activitySyncBlocks[currentNetwork.id],
      );
      _mergeNetworkTokens(result.tokens);
      _mergeNetworkActivities(result.activities);
      if (result.syncedFromBlock != null) {
        _activitySyncBlocks[currentNetwork.id] = result.syncedFromBlock!;
      }
      _lastRefreshedAt = DateTime.now();
    } on ChainReadException catch (error) {
      _assetError = error.message;
    } finally {
      _isRefreshing = false;
      notifyListeners();
      await _persistData();
    }
  }

  void toggleTokenHidden(String tokenId) {
    final index = _tokens.indexWhere((token) => token.id == tokenId);
    if (index == -1) {
      return;
    }
    _tokens[index] = _tokens[index].copyWith(
      isHidden: !_tokens[index].isHidden,
    );
    notifyListeners();
    unawaited(_persistData());
  }

  void addToken({
    required String name,
    required String symbol,
    required String contractAddress,
    int decimals = 18,
    double balance = 0,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;
    _tokens.insert(
      0,
      TokenAsset(
        id: 'custom-$now',
        name: name.trim(),
        symbol: symbol.trim().toUpperCase(),
        decimals: decimals,
        balance: balance,
        fiatValue: 0,
        networkId: _activeNetworkId,
        contractAddress: contractAddress.trim(),
        colorValue: 0xFF1F6B68,
        isRisky: true,
        riskLabel: 'Custom token',
      ),
    );
    notifyListeners();
    unawaited(_persistData());
  }

  Future<PendingTransfer> prepareTransfer({
    required TokenAsset token,
    required String toAddress,
    required String amountText,
  }) async {
    final vaultRecord = await _loadVaultRecord(currentWallet.id);
    try {
      return await _dependencies.transactionGateway.prepareTransfer(
        fromAddress: currentAccount.address,
        privateKeyHex: vaultRecord.privateKeyHex,
        toAddress: toAddress,
        network: networkById(token.networkId),
        token: token,
        amountText: amountText,
      );
    } on TransactionPreparationException catch (error) {
      _assetError = error.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> submitTransfer(PendingTransfer transfer) async {
    final vaultRecord = await _loadVaultRecord(currentWallet.id);
    try {
      final activity = await _dependencies.transactionGateway.submitTransfer(
        transfer: transfer,
        privateKeyHex: vaultRecord.privateKeyHex,
      );
      _activities.insert(0, activity);
      notifyListeners();
      await _persistData();
    } on TransactionSubmissionException catch (error) {
      _assetError = error.message;
      notifyListeners();
      rethrow;
    }
  }

  /// Speed Up 交易：使用相同 nonce 但更高的 gas 价格
  Future<PendingTransfer> speedUpTransaction({
    required ActivityRecord pendingActivity,
    double speedUpFactor = 1.5,
  }) async {
    if (pendingActivity.status != ActivityStatus.pending) {
      throw const TransactionPreparationException(
        'Only pending transactions can be sped up.',
      );
    }

    await _loadVaultRecord(currentWallet.id);
    final network = networkById(pendingActivity.networkId);

    final client = Web3Client(network.rpcUrl, _httpClient);
    try {
      final originalTx = await client.getTransactionByHash(
        pendingActivity.txHash,
      );
      if (originalTx == null) {
        throw const TransactionPreparationException(
          'Original transaction not found.',
        );
      }

      final nonce = originalTx.nonce;

      // 获取原始 gas 价格并计算新的
      final oldGasPrice = originalTx.gasPrice.getInWei;
      final newGasPrice =
          (oldGasPrice * BigInt.from((speedUpFactor * 100).toInt())) ~/
          BigInt.from(100);

      // 获取 token 信息
      final token = _tokens.firstWhere(
        (t) =>
            t.symbol == pendingActivity.tokenSymbol &&
            t.networkId == pendingActivity.networkId,
        orElse: () => TokenAsset(
          id: 'unknown',
          name: pendingActivity.tokenSymbol,
          symbol: pendingActivity.tokenSymbol,
          decimals: 18,
          balance: 0,
          fiatValue: 0,
          networkId: pendingActivity.networkId,
          contractAddress: 'Native asset',
          colorValue: 0xFF8A8D8E,
        ),
      );

      // 计算新 gas fee
      final gasLimit = originalTx.gas;
      final gasFeeWei = (newGasPrice * BigInt.from(gasLimit));

      return PendingTransfer(
        from: pendingActivity.from,
        to: pendingActivity.to,
        network: network,
        token: token,
        amountText: pendingActivity.amount.toString(),
        amount: pendingActivity.amount,
        amountInBaseUnits: _parseAmount(pendingActivity.amount, token.decimals),
        valueInWei: _isNativeToken(token)
            ? _parseAmount(pendingActivity.amount, token.decimals)
            : BigInt.zero,
        gasFee: _formatWeiAsDouble(gasFeeWei, 18),
        gasFeeWei: gasFeeWei,
        gasPriceWei: newGasPrice,
        gasLimit: gasLimit,
        nonce: nonce,
        chainId: network.chainId > 0 ? network.chainId : 1,
        data: originalTx.input,
        riskWarning:
            'Speed up: replacing transaction with higher gas. Original tx: ${pendingActivity.txHash}',
        isEIP1559: false, // 简化处理，使用 legacy
        maxFeePerGas: null,
        maxPriorityFeePerGas: null,
        originalTxHash: pendingActivity.txHash,
        isSpeedUp: true,
      );
    } finally {
      await client.dispose();
    }
  }

  /// Cancel 交易：发送 0 金额给自己来取消 pending 交易
  Future<PendingTransfer> cancelTransaction({
    required ActivityRecord pendingActivity,
    double speedUpFactor = 1.5,
  }) async {
    if (pendingActivity.status != ActivityStatus.pending) {
      throw const TransactionPreparationException(
        'Only pending transactions can be cancelled.',
      );
    }

    await _loadVaultRecord(currentWallet.id);
    final network = networkById(pendingActivity.networkId);

    final client = Web3Client(network.rpcUrl, _httpClient);
    try {
      final originalTx = await client.getTransactionByHash(
        pendingActivity.txHash,
      );
      if (originalTx == null) {
        throw const TransactionPreparationException(
          'Original transaction not found.',
        );
      }
      final nonce = originalTx.nonce;

      // 计算新的 gas 价格
      final oldGasPrice = originalTx.gasPrice.getInWei;
      final newGasPrice =
          (oldGasPrice * BigInt.from((speedUpFactor * 100).toInt())) ~/
          BigInt.from(100);

      return PendingTransfer(
        from: pendingActivity.from,
        to: pendingActivity.from, // 发送给自己
        network: network,
        token: TokenAsset(
          id: '${network.id}-native',
          name: network.name,
          symbol: network.nativeSymbol,
          decimals: 18,
          balance: 0,
          fiatValue: 0,
          networkId: network.id,
          contractAddress: 'Native asset',
          colorValue: network.colorValue,
        ),
        amountText: '0',
        amount: 0,
        amountInBaseUnits: BigInt.zero,
        valueInWei: BigInt.zero,
        gasFee: _formatWeiAsDouble(
          newGasPrice * BigInt.from(originalTx.gas),
          18,
        ),
        gasFeeWei: newGasPrice * BigInt.from(originalTx.gas),
        gasPriceWei: newGasPrice,
        gasLimit: originalTx.gas,
        nonce: nonce,
        chainId: network.chainId > 0 ? network.chainId : 1,
        data: null,
        riskWarning:
            'Cancel: sending 0 to yourself to cancel the pending transaction. Original tx: ${pendingActivity.txHash}',
        isEIP1559: false,
        originalTxHash: pendingActivity.txHash,
        isCancel: true,
      );
    } finally {
      await client.dispose();
    }
  }

  BigInt _parseAmount(double amount, int decimals) {
    final value = amount * pow(10, decimals);
    return BigInt.from(value.toInt());
  }

  double _formatWeiAsDouble(BigInt wei, int decimals) {
    if (wei == BigInt.zero) return 0;
    final digits = wei.abs().toString();
    if (digits.length <= decimals) {
      return double.parse('0.${digits.padLeft(decimals + 1, '0')}');
    }
    final splitIndex = digits.length - decimals;
    return double.parse(
      '${digits.substring(0, splitIndex)}.${digits.substring(splitIndex)}',
    );
  }

  bool _isNativeToken(TokenAsset token) {
    return token.contractAddress == 'Native asset';
  }

  Future<String> generateRecoveryPhrase() async {
    return _dependencies.importGateway.generateMnemonic();
  }

  Future<void> createWallet({
    required String name,
    required String mnemonic,
  }) async {
    final now = DateTime.now().microsecondsSinceEpoch;
    final walletId = 'wallet-$now';
    final accountId = 'account-$now';
    final vaultRecord = _dependencies.importGateway.derivePrimaryAccount(
      walletId: walletId,
      mnemonic: mnemonic,
    );
    final wallet = WalletProfile(
      id: walletId,
      name: name.trim().isEmpty ? 'Wallet ${_wallets.length + 1}' : name.trim(),
      activeAccountId: accountId,
      createdAt: DateTime.now(),
      accounts: [
        WalletAccount(
          id: accountId,
          name: 'Main Account',
          address: vaultRecord.address,
        ),
      ],
    );
    _wallets.add(wallet);
    _activeWalletId = wallet.id;
    notifyListeners();
    await _dependencies.vaultRepository.saveRecord(vaultRecord);
    await _persistData();
  }

  Future<void> importWallet({
    required String name,
    required String mnemonic,
  }) async {
    final now = DateTime.now().microsecondsSinceEpoch;
    final walletId = 'wallet-$now';
    final accountId = 'account-$now';
    final vaultRecord = _dependencies.importGateway.derivePrimaryAccount(
      walletId: walletId,
      mnemonic: mnemonic,
    );
    final wallet = WalletProfile(
      id: walletId,
      name: name.trim().isEmpty ? 'Imported Wallet' : name.trim(),
      activeAccountId: accountId,
      createdAt: DateTime.now(),
      accounts: [
        WalletAccount(
          id: accountId,
          name: 'Main Account',
          address: vaultRecord.address,
        ),
      ],
    );
    _wallets.add(wallet);
    _activeWalletId = wallet.id;
    notifyListeners();
    await _dependencies.vaultRepository.saveRecord(vaultRecord);
    await _persistData();
  }

  bool isValidRecoveryPhrase(String mnemonic) {
    return _dependencies.importGateway.isValidMnemonic(mnemonic);
  }

  void addCustomNetwork({
    required String name,
    required String nativeSymbol,
    required String rpcUrl,
    required String explorerUrl,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;
    _networks.add(
      ChainNetwork(
        id: 'custom-$now',
        name: name.trim(),
        chainId: 0,
        nativeSymbol: nativeSymbol.trim().toUpperCase(),
        rpcUrl: rpcUrl.trim(),
        explorerUrl: explorerUrl.trim(),
        colorValue: 0xFF3E7C59,
        isCustom: true,
      ),
    );
    notifyListeners();
    unawaited(_persistData());
  }

  void updateNetwork({
    required String id,
    required String name,
    required String nativeSymbol,
    required String rpcUrl,
    required String explorerUrl,
  }) {
    final index = _networks.indexWhere((network) => network.id == id);
    if (index == -1) {
      return;
    }
    final network = _networks[index];
    _networks[index] = network.copyWith(
      name: network.isCustom ? name.trim() : network.name,
      nativeSymbol: network.isCustom
          ? nativeSymbol.trim().toUpperCase()
          : network.nativeSymbol,
      rpcUrl: rpcUrl.trim(),
      explorerUrl: explorerUrl.trim(),
    );
    notifyListeners();
    unawaited(_persistData());
  }

  void updateCustomNetwork({
    required String id,
    required String name,
    required String nativeSymbol,
    required String rpcUrl,
    required String explorerUrl,
  }) {
    final index = _networks.indexWhere(
      (network) => network.id == id && network.isCustom,
    );
    if (index == -1) {
      return;
    }
    updateNetwork(
      id: id,
      name: name,
      nativeSymbol: nativeSymbol,
      rpcUrl: rpcUrl,
      explorerUrl: explorerUrl,
    );
  }

  void removeCustomNetwork(String id) {
    final index = _networks.indexWhere(
      (network) => network.id == id && network.isCustom,
    );
    if (index == -1) {
      return;
    }
    _networks.removeAt(index);
    if (_activeNetworkId == id) {
      _activeNetworkId = _networks.first.id;
    }
    notifyListeners();
    unawaited(_persistData());
  }

  Future<bool> setBiometricEnabled(bool value) async {
    if (value) {
      _biometricAvailable = await _dependencies.deviceSecurityService
          .isBiometricAvailable();
      if (!_biometricAvailable) {
        notifyListeners();
        return false;
      }
      final approved = await _dependencies.deviceSecurityService.authenticate(
        reason: '启用生物识别保护钱包',
      );
      if (!approved) {
        return false;
      }
    }
    _biometricEnabled = value;
    notifyListeners();
    await _persistSecurity();
    return true;
  }

  Future<void> updateSecurity({
    bool? screenshotProtectionEnabled,
    int? autoLockMinutes,
  }) async {
    _screenshotProtectionEnabled =
        screenshotProtectionEnabled ?? _screenshotProtectionEnabled;
    _autoLockMinutes = autoLockMinutes ?? _autoLockMinutes;
    notifyListeners();
    await _dependencies.deviceSecurityService.setScreenshotProtection(
      _screenshotProtectionEnabled,
    );
    await _persistSecurity();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _persistSecurity();
  }

  Future<void> clearCache() async {
    _lastRefreshedAt = null;
    _activitySyncBlocks = {};
    notifyListeners();
    await _persistData();
  }

  Future<List<String>> recoveryWordsForWallet([String? walletId]) async {
    final record = await _loadVaultRecord(walletId ?? currentWallet.id);
    return record.mnemonic.split(RegExp(r'\s+'));
  }

  Future<int?> verificationWordIndexForWallet([String? walletId]) async {
    final words = await recoveryWordsForWallet(walletId);
    if (words.isEmpty) {
      return null;
    }
    return words.length >= 11 ? 10 : words.length - 1;
  }

  Future<void> _persistData() {
    return _dependencies.dataRepository.save(
      WalletDataSnapshot(
        wallets: List<WalletProfile>.unmodifiable(_wallets),
        networks: List<ChainNetwork>.unmodifiable(_networks),
        tokens: List<TokenAsset>.unmodifiable(_tokens),
        activities: List<ActivityRecord>.unmodifiable(_activities),
        activitySyncBlocks: Map<String, int>.unmodifiable(_activitySyncBlocks),
        activeWalletId: currentWallet.id,
        activeNetworkId: _activeNetworkId,
        lastRefreshedAt: _lastRefreshedAt,
      ),
    );
  }

  Future<void> _persistSecurity() {
    return _dependencies.securityRepository.writeSettings(
      SecuritySettingsSnapshot(
        hideBalances: _hideBalances,
        biometricEnabled: _biometricEnabled,
        screenshotProtectionEnabled: _screenshotProtectionEnabled,
        notificationsEnabled: _notificationsEnabled,
        autoLockMinutes: _autoLockMinutes,
      ),
    );
  }

  Future<void> _ensureWalletVaults() async {
    for (var index = 0; index < _wallets.length; index++) {
      final wallet = _wallets[index];
      final existingRecord = await _dependencies.vaultRepository.readRecord(
        wallet.id,
      );
      if (existingRecord != null) {
        continue;
      }

      final vaultRecord = _dependencies.importGateway.derivePrimaryAccount(
        walletId: wallet.id,
        mnemonic: _developmentSeedMnemonic,
      );
      await _dependencies.vaultRepository.saveRecord(vaultRecord);
      _wallets[index] = wallet.copyWith(
        activeAccountId: '${wallet.id}-main',
        accounts: [
          WalletAccount(
            id: '${wallet.id}-main',
            name: 'Main Account',
            address: vaultRecord.address,
          ),
        ],
      );
    }
  }

  Future<WalletVaultRecord> _loadVaultRecord(String walletId) async {
    final record = await _dependencies.vaultRepository.readRecord(walletId);
    if (record == null) {
      throw const WalletImportException(
        'The wallet vault record is missing. Re-import the wallet before signing transactions.',
      );
    }
    return record;
  }

  void _mergeNetworkTokens(List<TokenAsset> refreshedTokens) {
    final refreshedById = {
      for (final token in refreshedTokens) token.id: token,
    };
    final merged = <TokenAsset>[];
    final seen = <String>{};

    for (final token in _tokens) {
      if (token.networkId != _activeNetworkId) {
        merged.add(token);
        continue;
      }

      final refreshed = refreshedById[token.id];
      if (refreshed != null) {
        merged.add(
          refreshed.copyWith(
            fiatValue: token.fiatValue,
            isHidden: token.isHidden,
            isRisky: token.isRisky,
            riskLabel: token.riskLabel,
          ),
        );
        seen.add(token.id);
      } else {
        merged.add(token);
      }
    }

    for (final token in refreshedTokens) {
      if (!seen.contains(token.id)) {
        merged.add(token);
      }
    }

    _tokens = merged;
  }

  void _mergeNetworkActivities(List<ActivityRecord> refreshedActivities) {
    final refreshedById = {
      for (final activity in refreshedActivities) activity.id: activity,
    };
    final refreshedByHash = <String, ActivityRecord>{
      for (final activity in refreshedActivities) activity.txHash: activity,
    };
    final merged = <ActivityRecord>[];
    final seenIds = <String>{};

    for (final activity in _activities) {
      if (activity.networkId != _activeNetworkId) {
        merged.add(activity);
        continue;
      }

      final byId = refreshedById[activity.id];
      if (byId != null) {
        merged.add(byId);
        seenIds.add(byId.id);
        continue;
      }

      final byHash = refreshedByHash[activity.txHash];
      if (byHash != null &&
          byHash.type == activity.type &&
          byHash.tokenSymbol == activity.tokenSymbol) {
        merged.add(
          activity.copyWith(
            status: byHash.status,
            title: byHash.title,
            from: byHash.from,
            to: byHash.to,
            amount: byHash.amount,
            gasFee: byHash.gasFee > 0 ? byHash.gasFee : activity.gasFee,
            occurredAt: byHash.occurredAt,
            riskNote: byHash.riskNote ?? activity.riskNote,
          ),
        );
        seenIds.add(byHash.id);
        continue;
      }

      merged.add(activity);
    }

    for (final activity in refreshedActivities) {
      if (!seenIds.contains(activity.id) &&
          !merged.any((item) => item.id == activity.id)) {
        merged.add(activity);
      }
    }

    merged.sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    _activities = merged;
  }
}
