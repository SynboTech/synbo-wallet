import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';
import '../widgets/activity_record_tile.dart';
import 'transaction_detail_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  ActivitySection _section = ActivitySection.transactions;
  ActivityFilter _filter = ActivityFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final activities = _recordsForSection(state.activities);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Text(
            '活动',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          _ActivitySectionTabs(
            selected: _section,
            onChanged: (section) => setState(() {
              _section = section;
              _filter = ActivityFilter.all;
            }),
          ),
          const SizedBox(height: 18),
          if (_showRecordFilters)
            _ActivityFilterChips(
              selected: _filter,
              onChanged: (filter) => setState(() => _filter = filter),
            ),
          const SizedBox(height: 28),
          if (activities.isEmpty)
            EmptyState(
              icon: _emptyIcon(_section),
              title: _emptyTitle(_section),
              message: _emptyMessage(_section),
            )
          else
            ...activities.map(
              (activity) => ActivityRecordTile(
                activity: activity,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TransactionDetailPage(activityId: activity.id),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool get _showRecordFilters =>
      _section == ActivitySection.transactions ||
      _section == ActivitySection.transfers;

  List<ActivityRecord> _recordsForSection(List<ActivityRecord> records) {
    final sectionRecords = switch (_section) {
      ActivitySection.transactions => records,
      ActivitySection.transfers =>
        records
            .where(
              (record) =>
                  record.type == ActivityType.send ||
                  record.type == ActivityType.receive,
            )
            .toList(growable: false),
    };

    if (!_showRecordFilters) {
      return sectionRecords;
    }
    return sectionRecords
        .where((activity) => activity.matches(_filter))
        .toList(growable: false);
  }

  IconData _emptyIcon(ActivitySection section) {
    return switch (section) {
      ActivitySection.transactions => Icons.receipt_long_outlined,
      ActivitySection.transfers => Icons.swap_vert_rounded,
    };
  }

  String _emptyTitle(ActivitySection section) {
    return switch (section) {
      ActivitySection.transactions => '您暂无交易记录',
      ActivitySection.transfers => '您暂无转账记录',
    };
  }

  String _emptyMessage(ActivitySection section) {
    return switch (section) {
      ActivitySection.transactions => '钱包交易、签名和授权记录会显示在这里。',
      ActivitySection.transfers => '发送和接收 Token 的记录会显示在这里。',
    };
  }
}

enum ActivitySection { transactions, transfers }

class _ActivitySectionTabs extends StatelessWidget {
  const _ActivitySectionTabs({required this.selected, required this.onChanged});

  final ActivitySection selected;
  final ValueChanged<ActivitySection> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final section in ActivitySection.values) ...[
            _ActivitySectionTab(
              label: _label(section),
              selected: selected == section,
              onTap: () => onChanged(section),
            ),
            const SizedBox(width: 26),
          ],
        ],
      ),
    );
  }

  String _label(ActivitySection section) {
    return switch (section) {
      ActivitySection.transactions => '交易',
      ActivitySection.transfers => '转账',
    };
  }
}

class _ActivitySectionTab extends StatelessWidget {
  const _ActivitySectionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 7),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 34 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityFilterChips extends StatelessWidget {
  const _ActivityFilterChips({required this.selected, required this.onChanged});

  final ActivityFilter selected;
  final ValueChanged<ActivityFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in ActivityFilter.values) ...[
            ChoiceChip(
              label: Text(_label(filter)),
              selected: selected == filter,
              onSelected: (_) => onChanged(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  String _label(ActivityFilter filter) {
    return switch (filter) {
      ActivityFilter.all => 'All',
      ActivityFilter.send => 'Send',
      ActivityFilter.receive => 'Receive',
      ActivityFilter.pending => 'Pending',
      ActivityFilter.failed => 'Failed',
      ActivityFilter.signature => 'Signature',
      ActivityFilter.approval => 'Approval',
    };
  }
}
