import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/wallet_models.dart';

class WalletAppState extends ChangeNotifier {
  WalletAppState()
    : _wallets = _seedWallets,
      _networks = _seedNetworks,
      _tokens = _seedTokens,
      _activities = _seedActivities;

  static final _createdAt = DateTime(2026, 4, 30, 10, 15);

  static final List<WalletProfile> _seedWallets = [
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
  ];

  static final List<ChainNetwork> _seedNetworks = [
    const ChainNetwork(
      id: 'ethereum',
      name: 'Ethereum',
      nativeSymbol: 'ETH',
      rpcUrl: 'https://mainnet.infura.io/v3/demo',
      explorerUrl: 'https://etherscan.io',
      colorValue: 0xFF5B6EE1,
    ),
    const ChainNetwork(
      id: 'bnb',
      name: 'BNB Chain',
      nativeSymbol: 'BNB',
      rpcUrl: 'https://bsc-dataseed.binance.org',
      explorerUrl: 'https://bscscan.com',
      colorValue: 0xFFD4A916,
    ),
    const ChainNetwork(
      id: 'polygon',
      name: 'Polygon',
      nativeSymbol: 'POL',
      rpcUrl: 'https://polygon-rpc.com',
      explorerUrl: 'https://polygonscan.com',
      colorValue: 0xFF7B3FE4,
    ),
    const ChainNetwork(
      id: 'arbitrum',
      name: 'Arbitrum',
      nativeSymbol: 'ETH',
      rpcUrl: 'https://arb1.arbitrum.io/rpc',
      explorerUrl: 'https://arbiscan.io',
      colorValue: 0xFF2D74C4,
    ),
    const ChainNetwork(
      id: 'base',
      name: 'Base',
      nativeSymbol: 'ETH',
      rpcUrl: 'https://mainnet.base.org',
      explorerUrl: 'https://basescan.org',
      colorValue: 0xFF2364E8,
    ),
  ];

  static final List<TokenAsset> _seedTokens = [
    const TokenAsset(
      id: 'eth-main',
      name: 'Ethereum',
      symbol: 'ETH',
      balance: 1.2845,
      fiatValue: 4218.30,
      networkId: 'ethereum',
      contractAddress: 'Native asset',
      colorValue: 0xFF5B6EE1,
    ),
    const TokenAsset(
      id: 'usdc-main',
      name: 'USD Coin',
      symbol: 'USDC',
      balance: 2480.75,
      fiatValue: 2480.75,
      networkId: 'ethereum',
      contractAddress: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48',
      colorValue: 0xFF2775CA,
    ),
    const TokenAsset(
      id: 'airdrop-main',
      name: 'Airdrop Claim',
      symbol: 'DROP',
      balance: 12000,
      fiatValue: 0.02,
      networkId: 'ethereum',
      contractAddress: '0x000000000000000000000000000000000000dEaD',
      colorValue: 0xFFB3261E,
      isRisky: true,
      riskLabel: 'Unverified token',
    ),
    const TokenAsset(
      id: 'bnb-main',
      name: 'BNB',
      symbol: 'BNB',
      balance: 4.92,
      fiatValue: 2968.44,
      networkId: 'bnb',
      contractAddress: 'Native asset',
      colorValue: 0xFFD4A916,
    ),
    const TokenAsset(
      id: 'pol-main',
      name: 'Polygon Ecosystem Token',
      symbol: 'POL',
      balance: 850.10,
      fiatValue: 612.07,
      networkId: 'polygon',
      contractAddress: 'Native asset',
      colorValue: 0xFF7B3FE4,
    ),
    const TokenAsset(
      id: 'arb-main',
      name: 'Arbitrum',
      symbol: 'ARB',
      balance: 920.45,
      fiatValue: 1049.31,
      networkId: 'arbitrum',
      contractAddress: '0x912CE59144191C1204E64559FE8253a0e49E6548',
      colorValue: 0xFF2D74C4,
    ),
    const TokenAsset(
      id: 'base-eth',
      name: 'Ethereum',
      symbol: 'ETH',
      balance: 0.428,
      fiatValue: 1406.12,
      networkId: 'base',
      contractAddress: 'Native asset',
      colorValue: 0xFF2364E8,
    ),
  ];

  static final List<ActivityRecord> _seedActivities = [
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
  ];

  final List<WalletProfile> _wallets;
  final List<ChainNetwork> _networks;
  final List<TokenAsset> _tokens;
  final List<ActivityRecord> _activities;

  int _activeWalletIndex = 0;
  String _activeNetworkId = 'ethereum';
  bool _hideBalances = false;
  bool _isRefreshing = false;
  String? _assetError;
  DateTime? _lastRefreshedAt;
  bool _biometricEnabled = true;
  bool _screenshotProtectionEnabled = true;
  bool _notificationsEnabled = true;
  int _autoLockMinutes = 5;

  List<WalletProfile> get wallets => List.unmodifiable(_wallets);
  List<ChainNetwork> get networks => List.unmodifiable(_networks);
  List<TokenAsset> get tokens => List.unmodifiable(_tokens);
  List<ActivityRecord> get activities => List.unmodifiable(_activities);

  WalletProfile get currentWallet => _wallets[_activeWalletIndex];
  WalletAccount get currentAccount => currentWallet.activeAccount;
  ChainNetwork get currentNetwork => networkById(_activeNetworkId);
  bool get hideBalances => _hideBalances;
  bool get isRefreshing => _isRefreshing;
  String? get assetError => _assetError;
  DateTime? get lastRefreshedAt => _lastRefreshedAt;
  bool get biometricEnabled => _biometricEnabled;
  bool get screenshotProtectionEnabled => _screenshotProtectionEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  int get autoLockMinutes => _autoLockMinutes;

  double get totalAssetsUsd => _tokens
      .where((token) => !token.isHidden)
      .fold(0, (sum, token) => sum + token.fiatValue);

  List<TokenAsset> get visibleTokens => _tokens
      .where((token) => !token.isHidden && token.networkId == _activeNetworkId)
      .toList(growable: false);

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
  }

  void switchWallet(String id) {
    final index = _wallets.indexWhere((wallet) => wallet.id == id);
    if (index == -1) {
      return;
    }
    _activeWalletIndex = index;
    notifyListeners();
  }

  void switchAccount(String id) {
    final wallet = currentWallet;
    if (!wallet.accounts.any((account) => account.id == id)) {
      return;
    }
    _wallets[_activeWalletIndex] = wallet.copyWith(activeAccountId: id);
    notifyListeners();
  }

  void renameCurrentWallet(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _wallets[_activeWalletIndex] = currentWallet.copyWith(name: trimmed);
    notifyListeners();
  }

  void toggleHideBalances() {
    _hideBalances = !_hideBalances;
    notifyListeners();
  }

  Future<void> refreshAssets() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    _assetError = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    _lastRefreshedAt = DateTime.now();
    _isRefreshing = false;
    notifyListeners();
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
  }

  void addToken({
    required String name,
    required String symbol,
    required String contractAddress,
    double balance = 0,
  }) {
    final now = DateTime.now().microsecondsSinceEpoch;
    _tokens.insert(
      0,
      TokenAsset(
        id: 'custom-$now',
        name: name.trim(),
        symbol: symbol.trim().toUpperCase(),
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
  }

  void submitTransfer(PendingTransfer transfer) {
    final suffix = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    _activities.insert(
      0,
      ActivityRecord(
        id: 'activity-$suffix',
        type: ActivityType.send,
        status: ActivityStatus.pending,
        title: 'Send ${transfer.token.symbol}',
        from: transfer.from,
        to: transfer.to,
        networkId: transfer.network.id,
        tokenSymbol: transfer.token.symbol,
        amount: transfer.amount,
        gasFee: transfer.gasFee,
        txHash:
            '0x$suffix${Random().nextInt(1 << 32).toRadixString(16).padLeft(8, '0')}',
        occurredAt: DateTime.now(),
        riskNote: transfer.riskWarning,
      ),
    );
    notifyListeners();
  }

  void createWallet({required String name}) {
    final now = DateTime.now().microsecondsSinceEpoch;
    final accountId = 'account-$now';
    _wallets.add(
      WalletProfile(
        id: 'wallet-$now',
        name: name.trim().isEmpty
            ? 'Wallet ${_wallets.length + 1}'
            : name.trim(),
        activeAccountId: accountId,
        createdAt: DateTime.now(),
        accounts: [
          WalletAccount(
            id: accountId,
            name: 'Main Account',
            address:
                '0x${now.toRadixString(16).padLeft(40, '0').substring(0, 40)}',
          ),
        ],
      ),
    );
    _activeWalletIndex = _wallets.length - 1;
    notifyListeners();
  }

  void importWallet({required String name}) {
    createWallet(name: name.trim().isEmpty ? 'Imported Wallet' : name.trim());
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
        nativeSymbol: nativeSymbol.trim().toUpperCase(),
        rpcUrl: rpcUrl.trim(),
        explorerUrl: explorerUrl.trim(),
        colorValue: 0xFF3E7C59,
        isCustom: true,
      ),
    );
    notifyListeners();
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
  }

  void updateSecurity({
    bool? biometricEnabled,
    bool? screenshotProtectionEnabled,
    int? autoLockMinutes,
  }) {
    _biometricEnabled = biometricEnabled ?? _biometricEnabled;
    _screenshotProtectionEnabled =
        screenshotProtectionEnabled ?? _screenshotProtectionEnabled;
    _autoLockMinutes = autoLockMinutes ?? _autoLockMinutes;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void clearCache() {
    _lastRefreshedAt = null;
    notifyListeners();
  }
}
