import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../providers/wallet_state_scope.dart';

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key, this.tokenId});

  final String? tokenId;

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final token = tokenId == null ? null : state.tokenById(tokenId!);
    final account = state.currentAccount;
    final network = token == null
        ? state.currentNetwork
        : state.networkById(token.networkId);

    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 184,
                    height: 184,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 132,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    compactAddress(account.address),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    token == null
                        ? network.name
                        : '${token.symbol} on ${network.name}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _copy(context, account.address),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy Address'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  InfoRow(label: 'Wallet', value: state.currentWallet.name),
                  InfoRow(label: 'Account', value: account.name),
                  InfoRow(label: 'Network', value: network.name),
                  InfoRow(label: 'Address', value: account.address),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Address copied')));
    }
  }
}
