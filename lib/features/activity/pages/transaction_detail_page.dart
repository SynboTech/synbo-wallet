import 'package:flutter/material.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/info_row.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../../../shared/widgets/status_pill.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key, required this.activityId});

  final String activityId;

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final activity = state.activityById(activityId);
    if (activity == null) {
      return const Scaffold(body: Center(child: Text('Record not found')));
    }
    final network = state.networkById(activity.networkId);
    final statusColor = _statusColor(context, activity.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      StatusPill(
                        label: _statusLabel(activity.status),
                        color: statusColor,
                        icon: _statusIcon(activity.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _typeLabel(activity.type),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (activity.riskNote != null) ...[
              const SizedBox(height: 12),
              RiskBanner(message: activity.riskNote!),
            ],
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    label: 'Status',
                    value: _statusLabel(activity.status),
                  ),
                  InfoRow(label: 'From', value: activity.from),
                  InfoRow(label: 'To', value: activity.to),
                  InfoRow(
                    label: 'Amount',
                    value: activity.type == ActivityType.signature
                        ? 'Message signature'
                        : '${formatTokenAmount(activity.amount)} ${activity.tokenSymbol}',
                  ),
                  InfoRow(
                    label: 'Gas Fee',
                    value:
                        '${formatTokenAmount(activity.gasFee)} ${network.nativeSymbol}',
                  ),
                  InfoRow(label: 'Network', value: network.name),
                  InfoRow(label: 'Tx Hash', value: activity.txHash),
                  InfoRow(
                    label: 'Time',
                    value: formatDateTime(activity.occurredAt),
                  ),
                  InfoRow(
                    label: 'Explorer',
                    value: '${network.explorerUrl}/tx/${activity.txHash}',
                    trailing: IconButton(
                      tooltip: 'Open explorer',
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Explorer: ${network.explorerUrl}/tx/${activity.txHash}',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(ActivityType type) {
    return switch (type) {
      ActivityType.send => 'Token transfer · Send',
      ActivityType.receive => 'Token transfer · Receive',
      ActivityType.signature => 'Signature record',
      ActivityType.approval => 'Token approval record',
    };
  }

  String _statusLabel(ActivityStatus status) {
    return switch (status) {
      ActivityStatus.pending => 'Pending',
      ActivityStatus.success => 'Success',
      ActivityStatus.failed => 'Failed',
    };
  }

  IconData _statusIcon(ActivityStatus status) {
    return switch (status) {
      ActivityStatus.pending => Icons.schedule_rounded,
      ActivityStatus.success => Icons.check_circle_outline,
      ActivityStatus.failed => Icons.error_outline,
    };
  }

  Color _statusColor(BuildContext context, ActivityStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      ActivityStatus.pending => const Color(0xFF8A6D1D),
      ActivityStatus.success => const Color(0xFF2E7D57),
      ActivityStatus.failed => colorScheme.error,
    };
  }
}
