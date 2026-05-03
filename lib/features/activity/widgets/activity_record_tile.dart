import 'package:flutter/material.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class ActivityRecordTile extends StatelessWidget {
  const ActivityRecordTile({super.key, required this.activity, this.onTap});

  final ActivityRecord activity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final network = state.networkById(activity.networkId);
    final typeColor = _typeColor(context, activity.type);
    final statusColor = _statusColor(context, activity.status);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.34),
            ),
          ),
        ),
        child: Row(
          children: [
            _ActivityIcon(activity: activity, color: typeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          activity.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      if (activity.type == ActivityType.signature ||
                          activity.type == ActivityType.approval) ...[
                        const SizedBox(width: 6),
                        Icon(
                          _typeIcon(activity.type),
                          color: typeColor,
                          size: 15,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 3,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _statusLabel(activity.status),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '·',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        network.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Color(network.colorValue),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '·',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        formatDateTime(activity.occurredAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _primaryAmountText(activity),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: activity.status == ActivityStatus.failed
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _secondaryText(activity),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _primaryAmountText(ActivityRecord activity) {
    if (activity.type == ActivityType.signature) {
      return 'Sign';
    }
    if (activity.type == ActivityType.approval) {
      return 'Approve';
    }
    final prefix = activity.type == ActivityType.receive ? '+' : '-';
    return '$prefix${formatTokenAmount(activity.amount)}';
  }

  static String _secondaryText(ActivityRecord activity) {
    if (activity.type == ActivityType.signature) {
      return activity.dappName ?? 'Message';
    }
    if (activity.type == ActivityType.approval) {
      return activity.dappName ?? activity.tokenSymbol;
    }
    return activity.tokenSymbol;
  }

  static IconData _typeIcon(ActivityType type) {
    return switch (type) {
      ActivityType.send => Icons.north_east_rounded,
      ActivityType.receive => Icons.south_west_rounded,
      ActivityType.signature => Icons.draw_outlined,
      ActivityType.approval => Icons.key_outlined,
    };
  }

  static Color _typeColor(BuildContext context, ActivityType type) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (type) {
      ActivityType.send => colorScheme.primary,
      ActivityType.receive => const Color(0xFF2E7D57),
      ActivityType.signature => const Color(0xFF6D5BD0),
      ActivityType.approval => const Color(0xFF0C7C8A),
    };
  }

  static String _statusLabel(ActivityStatus status) {
    return switch (status) {
      ActivityStatus.pending => 'Pending',
      ActivityStatus.success => 'Success',
      ActivityStatus.failed => 'Failed',
    };
  }

  static Color _statusColor(BuildContext context, ActivityStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (status) {
      ActivityStatus.pending => const Color(0xFF8A6D1D),
      ActivityStatus.success => const Color(0xFF2E7D57),
      ActivityStatus.failed => colorScheme.error,
    };
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({required this.activity, required this.color});

  final ActivityRecord activity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        ActivityRecordTile._typeIcon(activity.type),
        color: color,
        size: 22,
      ),
    );
  }
}
