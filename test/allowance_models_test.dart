import 'package:flutter_test/flutter_test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:multi_chain_wallet/features/wallet/models/allowance_models.dart';
import 'package:multi_chain_wallet/features/wallet/models/wallet_models.dart';

void main() {
  group('TokenAllowance', () {
    test('should create with correct values', () {
      final allowance = TokenAllowance(
        tokenContract: EthereumAddress.fromHex('0x1234567890123456789012345678901234567890'),
        spender: EthereumAddress.fromHex('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'),
        allowance: BigInt.from(1000000),
        tokenSymbol: 'USDT',
        tokenDecimals: 6,
        networkId: 'ethereum',
        networkName: 'Ethereum',
      );

      expect(allowance.tokenSymbol, 'USDT');
      expect(allowance.hasAllowance, true);
      expect(allowance.formattedAllowance, '1.000000');
    });

    test('should return false for zero allowance', () {
      final allowance = TokenAllowance(
        tokenContract: EthereumAddress.fromHex('0x1234567890123456789012345678901234567890'),
        spender: EthereumAddress.fromHex('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'),
        allowance: BigInt.zero,
        tokenSymbol: 'USDT',
        tokenDecimals: 6,
        networkId: 'ethereum',
        networkName: 'Ethereum',
      );

      expect(allowance.hasAllowance, false);
      expect(allowance.formattedAllowance, '0');
    });

    test('should handle infinite allowance', () {
      final allowance = TokenAllowance(
        tokenContract: EthereumAddress.fromHex('0x1234567890123456789012345678901234567890'),
        spender: EthereumAddress.fromHex('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'),
        allowance: TokenAllowance.infiniteAllowance,
        tokenSymbol: 'USDC',
        tokenDecimals: 6,
        networkId: 'polygon',
        networkName: 'Polygon',
      );

      expect(allowance.hasAllowance, true);
    });
  });

  group('AllowanceRequest', () {
    late TokenAllowance token;

    setUp(() {
      token = TokenAllowance(
        tokenContract: EthereumAddress.fromHex('0x1234567890123456789012345678901234567890'),
        spender: EthereumAddress.fromHex('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'),
        allowance: BigInt.from(5000000),
        tokenSymbol: 'USDT',
        tokenDecimals: 6,
        networkId: 'ethereum',
        networkName: 'Ethereum',
      );
    });

    test('should create approve request', () {
      final request = AllowanceRequest(
        token: token,
        spender: token.spender,
        amount: BigInt.from(10000000),
        type: AllowanceRequestType.approve,
      );

      expect(request.type, AllowanceRequestType.approve);
      expect(request.isUnlimited, false);
      expect(request.amountText, '10.000000');
    });

    test('should create revoke request', () {
      final request = AllowanceRequest(
        token: token,
        spender: token.spender,
        amount: BigInt.zero,
        type: AllowanceRequestType.revoke,
      );

      expect(request.type, AllowanceRequestType.revoke);
      expect(request.amountText, '0');
    });

    test('should detect unlimited approval', () {
      final request = AllowanceRequest(
        token: token,
        spender: token.spender,
        amount: TokenAllowance.infiniteAllowance,
        type: AllowanceRequestType.approve,
      );

      expect(request.isUnlimited, true);
      expect(request.amountText, 'Unlimited');
    });
  });

  group('PendingApproval', () {
    test('should create pending approval', () {
      final token = TokenAllowance(
        tokenContract: EthereumAddress.fromHex('0x1234567890123456789012345678901234567890'),
        spender: EthereumAddress.fromHex('0xabcdefabcdefabcdefabcdefabcdefabcdefabcd'),
        allowance: BigInt.from(1000000),
        tokenSymbol: 'DAI',
        tokenDecimals: 18,
        networkId: 'ethereum',
        networkName: 'Ethereum',
      );

      final request = AllowanceRequest(
        token: token,
        spender: token.spender,
        amount: BigInt.from(1000000000000000000), // 1 DAI
        type: AllowanceRequestType.approve,
      );

      final network = ChainNetwork(
        id: 'ethereum',
        name: 'Ethereum',
        chainId: 1,
        nativeSymbol: 'ETH',
        rpcUrl: 'https://eth.llamarpc.com',
        explorerUrl: 'https://etherscan.io',
        colorValue: 0x627EEA,
      );

      final gasEstimate = GasEstimate(
        gasLimit: BigInt.from(46000),
        suggestedGasPrice: EtherAmount.inWei(BigInt.from(20000000000)),
      );

      final pending = PendingApproval(
        allowanceRequest: request,
        network: network,
        gasEstimate: gasEstimate,
        riskWarning: 'Test risk warning',
      );

      expect(pending.spenderLabel, contains('0x'));
      expect(pending.tokenSymbol, 'DAI');
      expect(pending.network.name, 'Ethereum');
      expect(pending.gasEstimate.gasLimit, BigInt.from(46000));
    });
  });
}