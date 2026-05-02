import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../models/allowance_models.dart';
import '../models/wallet_models.dart';

/// ERC20 Allowance 交互网关
/// 负责查询和修改 Token allowance
abstract class AllowanceGateway {
  /// 查询某个地址对 spender 的 allowance
  Future<TokenAllowance> getAllowance({
    required EthereumAddress tokenAddress,
    required EthereumAddress owner,
    required EthereumAddress spender,
    required ChainNetwork network,
  });

  /// 批量查询多个 spender 的 allowance
  Future<List<TokenAllowance>> getAllowances({
    required EthereumAddress tokenAddress,
    required EthereumAddress owner,
    required List<EthereumAddress> spenders,
    required ChainNetwork network,
  });

  /// 准备 Approval 交易
  Future<PendingApproval> prepareApproval({
    required EthereumAddress tokenAddress,
    required EthereumAddress owner,
    required EthereumAddress spender,
    required BigInt amount,
    required AllowanceRequestType type,
    required ChainNetwork network,
  });

  /// 执行 Approval 交易
  Future<String> executeApproval({
    required EthereumAddress tokenAddress,
    required EthereumAddress spender,
    required String privateKeyHex,
    required BigInt amount,
    required int nonce,
    required int chainId,
    required BigInt gasPrice,
    required String rpcUrl,
  });
}

/// ERC20 Allowance 实现
class EvmAllowanceGateway implements AllowanceGateway {
  EvmAllowanceGateway({required Client httpClient}) : _httpClient = httpClient;

  final Client _httpClient;

  static const _erc20Abi = '''
  [
    {"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"type":"function"},
    {"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"type":"function"},
    {"constant":true,"inputs":[{"name":"account","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},
    {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},
    {"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"}
  ]
  ''';

  @override
  Future<TokenAllowance> getAllowance({
    required EthereumAddress tokenAddress,
    required EthereumAddress owner,
    required EthereumAddress spender,
    required ChainNetwork network,
  }) async {
    final client = Web3Client(network.rpcUrl, _httpClient);
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        tokenAddress,
      );

      // 获取 decimals
      final decimalsResult = await client.call(
        contract: contract,
        function: contract.function('decimals'),
        params: [],
      );
      final decimals = decimalsResult.first as int;

      // 获取 symbol
      final symbolResult = await client.call(
        contract: contract,
        function: contract.function('symbol'),
        params: [],
      );
      final symbol = symbolResult.first as String;

      // 获取 allowance
      final allowanceResult = await client.call(
        contract: contract,
        function: contract.function('allowance'),
        params: [owner, spender],
      );
      final allowance = allowanceResult.first as BigInt;

      return TokenAllowance(
        tokenContract: tokenAddress,
        spender: spender,
        allowance: allowance,
        tokenSymbol: symbol,
        tokenDecimals: decimals,
        networkId: network.id,
        networkName: network.name,
      );
    } finally {
      await client.dispose();
    }
  }

  @override
  Future<List<TokenAllowance>> getAllowances({
    required EthereumAddress tokenAddress,
    required EthereumAddress owner,
    required List<EthereumAddress> spenders,
    required ChainNetwork network,
  }) async {
    final client = Web3Client(network.rpcUrl, _httpClient);
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        tokenAddress,
      );

      // 获取 token 信息
      final decimalsResult = await client.call(
        contract: contract,
        function: contract.function('decimals'),
        params: [],
      );
      final decimals = decimalsResult.first as int;

      final symbolResult = await client.call(
        contract: contract,
        function: contract.function('symbol'),
        params: [],
      );
      final symbol = symbolResult.first as String;

      // 批量查询 allowance
      final allowances = <TokenAllowance>[];
      for (final spender in spenders) {
        final result = await client.call(
          contract: contract,
          function: contract.function('allowance'),
          params: [owner, spender],
        );
        allowances.add(
          TokenAllowance(
            tokenContract: tokenAddress,
            spender: spender,
            allowance: result.first as BigInt,
            tokenSymbol: symbol,
            tokenDecimals: decimals,
            networkId: network.id,
            networkName: network.name,
          ),
        );
      }
      return allowances;
    } finally {
      await client.dispose();
    }
  }

  @override
  Future<PendingApproval> prepareApproval({
    required EthereumAddress tokenAddress,
    required EthereumAddress owner,
    required EthereumAddress spender,
    required BigInt amount,
    required AllowanceRequestType type,
    required ChainNetwork network,
  }) async {
    final client = Web3Client(network.rpcUrl, _httpClient);
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        tokenAddress,
      );

      // 获取 token 信息
      final decimalsResult = await client.call(
        contract: contract,
        function: contract.function('decimals'),
        params: [],
      );
      final decimals = decimalsResult.first as int;

      final symbolResult = await client.call(
        contract: contract,
        function: contract.function('symbol'),
        params: [],
      );
      final symbol = symbolResult.first as String;

      // 估算 gas
      final approveFn = contract.function('approve');
      final txData = approveFn.encodeCall([spender, amount]);

      final gasEstimate = await client.estimateGas(
        sender: owner,
        to: tokenAddress,
        data: txData,
      );

      final gasPrice = await client.getGasPrice();
      final gasLimit = (gasEstimate * BigInt.from(120)) ~/ BigInt.from(100);

      // 创建 token allowance 对象
      final tokenAllowance = TokenAllowance(
        tokenContract: tokenAddress,
        spender: spender,
        allowance: amount,
        tokenSymbol: symbol,
        tokenDecimals: decimals,
        networkId: network.id,
        networkName: network.name,
      );

      final request = AllowanceRequest(
        token: tokenAllowance,
        spender: spender,
        amount: amount,
        type: type,
      );

      final riskWarning = type == AllowanceRequestType.approve
          ? 'Granting allowance allows $spender to spend your $symbol tokens.'
          : 'Revoking will remove $spender\'s permission to spend your $symbol tokens.';

      return PendingApproval(
        allowanceRequest: request,
        network: network,
        gasEstimate: GasEstimate(
          gasLimit: gasLimit,
          suggestedGasPrice: gasPrice,
        ),
        riskWarning: riskWarning,
      );
    } finally {
      await client.dispose();
    }
  }

  @override
  Future<String> executeApproval({
    required EthereumAddress tokenAddress,
    required EthereumAddress spender,
    required String privateKeyHex,
    required BigInt amount,
    required int nonce,
    required int chainId,
    required BigInt gasPrice,
    required String rpcUrl,
  }) async {
    final credentials = EthPrivateKey.fromHex(privateKeyHex);
    final client = Web3Client(rpcUrl, _httpClient);

    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(_erc20Abi, 'ERC20'),
        tokenAddress,
      );

      final approveFn = contract.function('approve');
      final data = approveFn.encodeCall([spender, amount]);

      final tx = Transaction(
        from: credentials.address,
        to: tokenAddress,
        data: data,
        gasPrice: EtherAmount.inWei(gasPrice),
        nonce: nonce,
      );

      final txHash = await client.sendTransaction(
        credentials,
        tx,
        chainId: chainId,
      );

      return txHash;
    } finally {
      await client.dispose();
    }
  }
}
