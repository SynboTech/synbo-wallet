import 'package:flutter/material.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../models/wallet_models.dart';
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
              onPressed: () {
                state.submitTransfer(transfer);
                Navigator.of(context).popUntil((route) => route.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction submitted')),
                );
              },
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
}
