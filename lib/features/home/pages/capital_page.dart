import 'package:flutter/material.dart';

import '../../../shared/widgets/risk_banner.dart';
import '../../../shared/widgets/section_header.dart';

class CapitalPage extends StatelessWidget {
  const CapitalPage({super.key});

  static const _accent = Color(0xFFD9A322);
  static const _records = [
    _CapitalRecord(
      hash: '0xca9c...ff98',
      type: 'MINT_USDS',
      transferOut: '-199.0 USDT',
      receive: '+199.0 USDS',
      time: '2026-04-29 12:50',
    ),
    _CapitalRecord(
      hash: '0x2315...efd1',
      type: 'MINT_PT',
      transferOut: '-980.5 USDT',
      receive: '+980.5 PT',
      time: '2026-04-16 21:04',
    ),
    _CapitalRecord(
      hash: '0xc69f...becf',
      type: 'REDEEM_USDS',
      transferOut: '-391.7525 USDS',
      receive: '+380.0 USDT',
      time: '2026-04-16 21:04',
    ),
    _CapitalRecord(
      hash: '0x3d6f...5939',
      type: 'MINT_PT',
      transferOut: '-200.0 USDT',
      receive: '+200.0 PT',
      time: '2026-04-16 20:58',
    ),
    _CapitalRecord(
      hash: '0xd83f...616f',
      type: 'MINT_USDS',
      transferOut: '-2.00K USDT',
      receive: '+2.00K USDS',
      time: '2026-04-16 20:45',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF6F8F7),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            _CapitalAppBar(colorScheme: colorScheme),
            const SizedBox(height: 14),
            _CapitalHero(colorScheme: colorScheme),
            const SizedBox(height: 12),
            const _MetricsGrid(),
            const SectionHeader(title: 'Actions'),
            const _ActionList(),
            const SizedBox(height: 14),
            const RiskBanner(
              message:
                  'Capital involves minting and redeeming assets. Review token, amount, fee, and redemption outcome before confirming any transaction.',
            ),
            const SectionHeader(title: 'Transaction History'),
            Text(
              'Recent operations and transactions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest.withValues(
                  alpha: isDark ? 0.64 : 0.86,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _records.length; i++)
                    _CapitalRecordTile(
                      record: _records[i],
                      isLast: i == _records.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Showing 1-5 of 12',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapitalAppBar extends StatelessWidget {
  const _CapitalAppBar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          visualDensity: VisualDensity.compact,
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            'Capital',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: CapitalPage._accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Live',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CapitalHero extends StatelessWidget {
  const _CapitalHero({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alpha funding and lending',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Mint PT or USDS, redeem back to USDT, and track every operation in one place.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: CustomPaint(painter: _CapitalSparklinePainter()),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricTile(value: '3.30K', label: 'Total Liquidity'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MetricTile(value: '2.01K', label: 'USDS Supply'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MetricTile(value: '1.28K', label: 'PT Supply'),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 76,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _CapitalAction(
        title: 'Mint PT',
        subtitle: 'Alpha Funding and Lending',
        icon: Icons.diamond_outlined,
      ),
      _CapitalAction(
        title: 'Mint USDS',
        subtitle: 'Get USDS tokens & Farming rewards',
        icon: Icons.monetization_on_outlined,
      ),
      _CapitalAction(
        title: 'Redeem',
        subtitle: 'Convert tokens back to USDT',
        icon: Icons.sync_rounded,
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _CapitalActionTile(action: actions[i]),
        ],
      ],
    );
  }
}

class _CapitalAction {
  const _CapitalAction({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _CapitalActionTile extends StatelessWidget {
  const _CapitalActionTile({required this.action});

  final _CapitalAction action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(action.title))),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CapitalPage._accent.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: CapitalPage._accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapitalRecordTile extends StatelessWidget {
  const _CapitalRecordTile({required this.record, required this.isLast});

  final _CapitalRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.type,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.hash} · ${record.time}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.transferOut,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record.receive,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF00A86B),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 14,
            endIndent: 14,
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
      ],
    );
  }
}

class _CapitalRecord {
  const _CapitalRecord({
    required this.hash,
    required this.type,
    required this.transferOut,
    required this.receive,
    required this.time,
  });

  final String hash;
  final String type;
  final String transferOut;
  final String receive;
  final String time;
}

class _CapitalSparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CapitalPage._accent.withValues(alpha: 0.28),
          CapitalPage._accent.withValues(alpha: 0.02),
        ],
      ).createShader(Offset.zero & size);
    final linePaint = Paint()
      ..color = CapitalPage._accent
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [
      Offset(0, size.height * 0.72),
      Offset(size.width * 0.18, size.height * 0.66),
      Offset(size.width * 0.38, size.height * 0.68),
      Offset(size.width * 0.56, size.height * 0.35),
      Offset(size.width * 0.74, size.height * 0.26),
      Offset(size.width, size.height * 0.24),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final control = Offset((previous.dx + current.dx) / 2, previous.dy);
      path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
