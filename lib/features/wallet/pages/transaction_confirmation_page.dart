import 'package:flutter/material.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../../security/widgets/sensitive_action_auth_sheet.dart';
import '../models/wallet_models.dart';
import '../providers/wallet_state.dart';
import '../providers/wallet_state_scope.dart';

class TransactionConfirmationPage extends StatelessWidget {
  const TransactionConfirmationPage({super.key, required this.transfer});

  final PendingTransfer transfer;

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Transaction')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RiskBanner(message: transfer.riskWarning),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  InfoRow(label: 'From', value: transfer.from),
                  InfoRow(label: 'To', value: transfer.to),
                  InfoRow(label: 'Network', value: transfer.network.name),
                  InfoRow(label: 'Token', value: transfer.token.symbol),
                  InfoRow(
                    label: 'Amount',
                    value:
                        '${formatTokenAmount(transfer.amount)} ${transfer.token.symbol}',
                  ),
                  // Gas 类型标识
                  InfoRow(
                    label: 'Gas Type',
                    value: transfer.isEIP1559 ? 'EIP-1559' : 'Legacy',
                  ),
                  // Gas 信息
                  if (transfer.isEIP1559) ...[
                    InfoRow(
                      label: 'Max Fee',
                      value: '${_formatGwei(transfer.maxFeePerGas!)} gwei',
                    ),
                    InfoRow(
                      label: 'Priority Fee',
                      value:
                          '${_formatGwei(transfer.maxPriorityFeePerGas!)} gwei',
                    ),
                    if (transfer.estimatedBaseFee != null)
                      InfoRow(
                        label: 'Base Fee',
                        value:
                            '${_formatGwei(transfer.estimatedBaseFee!)} gwei',
                      ),
                  ] else ...[
                    InfoRow(
                      label: 'Gas Price',
                      value: '${_formatGwei(transfer.gasPriceWei)} gwei',
                    ),
                  ],
                  InfoRow(
                    label: 'Gas Limit',
                    value: transfer.gasLimit.toString(),
                  ),
                  InfoRow(
                    label: 'Gas Fee',
                    value:
                        '${formatTokenAmount(transfer.gasFee)} ${transfer.network.nativeSymbol}',
                  ),
                  InfoRow(
                    label: 'Total',
                    value:
                        transfer.token.symbol == transfer.network.nativeSymbol
                        ? '${formatTokenAmount(transfer.total)} ${transfer.token.symbol}'
                        : '${formatTokenAmount(transfer.amount)} ${transfer.token.symbol} + ${formatTokenAmount(transfer.gasFee)} ${transfer.network.nativeSymbol}',
                    valueColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _confirm(context, state),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WalletAppState state) async {
    final approved = await showSensitiveActionAuthSheet(
      context,
      title: '确认转账',
      reason: '继续前请验证身份，确保是您本人在发起交易。',
    );
    if (!approved || !context.mounted) {
      return;
    }
    try {
      await state.submitTransfer(transfer);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction submitted')));
  }

  /// 格式化 gwei (1 gwei = 1e-9 eth)
  String _formatGwei(BigInt wei) {
    final gwei = wei ~/ BigInt.from(1000000000);
    if (gwei < BigInt.from(1000)) {
      return gwei.toString();
    }
    // 显示小数
    final value = gwei.toDouble() / 1000;
    return value.toStringAsFixed(2);
  }
}
