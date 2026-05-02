import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@immutable
class WalletVaultRecord {
  const WalletVaultRecord({
    required this.walletId,
    required this.mnemonic,
    required this.derivationPath,
    required this.privateKeyHex,
    required this.address,
  });

  final String walletId;
  final String mnemonic;
  final String derivationPath;
  final String privateKeyHex;
  final String address;

  Map<String, Object?> toJson() {
    return {
      'walletId': walletId,
      'mnemonic': mnemonic,
      'derivationPath': derivationPath,
      'privateKeyHex': privateKeyHex,
      'address': address,
    };
  }

  factory WalletVaultRecord.fromJson(Map<String, dynamic> json) {
    return WalletVaultRecord(
      walletId: json['walletId'] as String? ?? '',
      mnemonic: json['mnemonic'] as String? ?? '',
      derivationPath: json['derivationPath'] as String? ?? '',
      privateKeyHex: json['privateKeyHex'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}

abstract class WalletVaultRepository {
  Future<void> saveRecord(WalletVaultRecord record);
  Future<WalletVaultRecord?> readRecord(String walletId);
}

class SecureStorageWalletVaultRepository implements WalletVaultRepository {
  SecureStorageWalletVaultRepository({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _vaultKey = 'wallet.vault.records.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<WalletVaultRecord?> readRecord(String walletId) async {
    final records = await _readAll();
    return records[walletId];
  }

  @override
  Future<void> saveRecord(WalletVaultRecord record) async {
    final records = await _readAll();
    records[record.walletId] = record;
    await _storage.write(
      key: _vaultKey,
      value: jsonEncode(
        records.map(
          (key, value) => MapEntry<String, Object?>(key, value.toJson()),
        ),
      ),
    );
  }

  Future<Map<String, WalletVaultRecord>> _readAll() async {
    final raw = await _storage.read(key: _vaultKey);
    if (raw == null || raw.trim().isEmpty) {
      return <String, WalletVaultRecord>{};
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        WalletVaultRecord.fromJson(value as Map<String, dynamic>),
      ),
    );
  }
}

class MemoryWalletVaultRepository implements WalletVaultRepository {
  final Map<String, WalletVaultRecord> _records = <String, WalletVaultRecord>{};

  @override
  Future<WalletVaultRecord?> readRecord(String walletId) async {
    return _records[walletId];
  }

  @override
  Future<void> saveRecord(WalletVaultRecord record) async {
    _records[record.walletId] = record;
  }
}
