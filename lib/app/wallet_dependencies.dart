import 'package:http/http.dart';

import '../features/security/data/security_repository.dart';
import '../features/security/services/device_security_service.dart';
import '../features/wallet/data/wallet_chain_read_gateway.dart';
import '../features/wallet/data/wallet_data_repository.dart';
import '../features/wallet/data/wallet_vault_repository.dart';

class WalletAppDependencies {
  WalletAppDependencies({
    required this.dataRepository,
    required this.vaultRepository,
    required this.securityRepository,
    required this.deviceSecurityService,
    required this.chainReadGateway,
    required this.transactionGateway,
    required this.importGateway,
    required this.httpClient,
  });

  final WalletDataRepository dataRepository;
  final WalletVaultRepository vaultRepository;
  final SecurityRepository securityRepository;
  final DeviceSecurityService deviceSecurityService;
  final ChainReadGateway chainReadGateway;
  final TransactionGateway transactionGateway;
  final WalletImportGateway importGateway;
  final Client httpClient;

  factory WalletAppDependencies.production() {
    return WalletAppDependencies(
      dataRepository: SecureStorageWalletDataRepository(),
      vaultRepository: SecureStorageWalletVaultRepository(),
      securityRepository: SecureStorageSecurityRepository(),
      deviceSecurityService: PlatformDeviceSecurityService(),
      chainReadGateway: EvmChainReadGateway(),
      transactionGateway: EvmTransactionGateway(),
      importGateway: EvmWalletImportGateway(),
      httpClient: Client(),
    );
  }

  factory WalletAppDependencies.testing() {
    return WalletAppDependencies(
      dataRepository: SeedWalletDataRepository(),
      vaultRepository: MemoryWalletVaultRepository(),
      securityRepository: MemorySecurityRepository(initialPassword: '12345678'),
      deviceSecurityService: const NoopDeviceSecurityService(),
      chainReadGateway: const NoopChainReadGateway(),
      transactionGateway: EvmTransactionGateway(),
      importGateway: EvmWalletImportGateway(),
      httpClient: Client(),
    );
  }
}
