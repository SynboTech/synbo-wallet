import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../../activity/widgets/activity_record_tile.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class AuthorizationManagementPage extends StatelessWidget {
  const AuthorizationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final approvals = state.activities
        .where((item) => item.type == ActivityType.approval)
        .toList();
    final signatures = state.activities
        .where((item) => item.type == ActivityType.signature)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('授权管理')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const RiskBanner(
              message:
                  'Review connected apps and token approvals regularly. Revoke approvals you do not recognize.',
            ),
            const SizedBox(height: 14),
            Text(
              '已连接应用',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            _ConnectedAppCard(
              name: 'Safe App',
              network: 'Ethereum',
              trusted: true,
            ),
            _ConnectedAppCard(
              name: 'Unknown App',
              network: 'Ethereum',
              trusted: false,
            ),
            const SizedBox(height: 14),
            Text(
              'Token 授权',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final approval in approvals)
              ActivityRecordTile(activity: approval),
            const SizedBox(height: 14),
            Text(
              '签名记录',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final signature in signatures)
              ActivityRecordTile(activity: signature),
          ],
        ),
      ),
    );
  }
}

class _ConnectedAppCard extends StatelessWidget {
  const _ConnectedAppCard({
    required this.name,
    required this.network,
    required this.trusted,
  });

  final String name;
  final String network;
  final bool trusted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (trusted ? colorScheme.primary : colorScheme.error)
                .withValues(alpha: 0.12),
            child: Icon(
              trusted
                  ? Icons.verified_user_outlined
                  : Icons.warning_amber_rounded,
              color: trusted ? colorScheme.primary : colorScheme.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(network),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _confirmRevoke(context),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤销授权提示'),
        content: Text('Revoke access for $name on $network?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}
