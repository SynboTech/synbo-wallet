import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../../../shared/widgets/section_header.dart';
import '../../activity/widgets/activity_record_tile.dart';
import '../providers/wallet_state_scope.dart';
import 'receive_page.dart';
import 'send_flow_page.dart';

class TokenDetailPage extends StatelessWidget {
  const TokenDetailPage({super.key, required this.tokenId});

  final String tokenId;

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final token = state.tokenById(tokenId);
    if (token == null) {
      return const Scaffold(body: Center(child: Text('Token not found')));
    }
    final network = state.networkById(token.networkId);
    final activities = state.activitiesForToken(token);

    return Scaffold(
      appBar: AppBar(
        title: Text(token.symbol),
        actions: [
          IconButton(
            tooltip: token.isHidden ? 'Show token' : 'Hide token',
            onPressed: () {
              state.toggleTokenHidden(token.id);
              Navigator.of(context).pop();
            },
            icon: Icon(
              token.isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(
                          token.colorValue,
                        ).withValues(alpha: 0.16),
                        child: Text(
                          token.symbol.characters.first,
                          style: TextStyle(
                            color: Color(token.colorValue),
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              token.name,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${token.symbol} · ${network.name}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    state.hideBalances
                        ? '••••'
                        : formatTokenAmount(token.balance),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.hideBalances
                        ? '••••'
                        : formatCurrency(token.fiatValue),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (token.isRisky) ...[
              const SizedBox(height: 12),
              RiskBanner(
                message: token.riskLabel ?? 'This token is marked as risky.',
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SendFlowPage(initialTokenId: token.id),
                      ),
                    ),
                    icon: const Icon(Icons.north_east_rounded),
                    label: const Text('Send'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReceivePage(tokenId: token.id),
                      ),
                    ),
                    icon: const Icon(Icons.south_west_rounded),
                    label: const Text('Receive'),
                  ),
                ),
              ],
            ),
            SectionHeader(title: 'Token Details'),
            AppCard(
              child: Column(
                children: [
                  InfoRow(label: 'Network', value: network.name),
                  InfoRow(label: 'Symbol', value: token.symbol),
                  InfoRow(
                    label: 'Contract',
                    value: token.contractAddress,
                    trailing: IconButton(
                      tooltip: 'Copy contract',
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      onPressed: () => _copy(context, token.contractAddress),
                    ),
                  ),
                  InfoRow(
                    label: 'Explorer',
                    value: network.explorerUrl,
                    trailing: IconButton(
                      tooltip: 'Open explorer',
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Explorer: ${network.explorerUrl}'),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            SectionHeader(title: 'Token Activity'),
            if (activities.isEmpty)
              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No token activity',
                message: 'New transfers and approvals will appear here.',
              )
            else
              ...activities.map(
                (activity) => ActivityRecordTile(activity: activity),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied')));
    }
  }
}
