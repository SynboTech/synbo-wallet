import 'package:flutter/material.dart';

import '../../../app/routes/app_router.dart';

class PortfolioListPage extends StatefulWidget {
  const PortfolioListPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<PortfolioListPage> createState() => _PortfolioListPageState();
}

class _PortfolioListPageState extends State<PortfolioListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _financingItems = const [
    _FinancingListItem(
      name: 'Synbo',
      symbol: 'SYNBO',
      price: '\$2,480.75',
      change: '+12.5%',
      amount: '124.5',
      totalValue: '\$2,480.75',
      color: Colors.blue,
      badge: 'Hot',
      status: 'Open',
    ),
    _FinancingListItem(
      name: 'Bondly',
      symbol: 'BOND',
      price: '\$1,856.30',
      change: '+8.3%',
      amount: '892.3',
      totalValue: '\$1,856.30',
      color: Colors.green,
      status: 'Open',
    ),
    _FinancingListItem(
      name: 'Stablecoin',
      symbol: 'USDC',
      price: '\$945.20',
      change: '+3.2%',
      amount: '945.2',
      totalValue: '\$945.20',
      color: Colors.teal,
      status: 'Closing soon',
    ),
    _FinancingListItem(
      name: 'YieldX',
      symbol: 'YIELD',
      price: '\$680.50',
      change: '+15.7%',
      amount: '68.05',
      totalValue: '\$680.50',
      color: Colors.orange,
      badge: 'New',
      status: 'Open',
    ),
    _FinancingListItem(
      name: 'Growth',
      symbol: 'GRW',
      price: '\$420.00',
      change: '+5.1%',
      amount: '42.0',
      totalValue: '\$420.00',
      color: Colors.purple,
      status: 'Upcoming',
    ),
    _FinancingListItem(
      name: 'Treasury Fund',
      symbol: 'USDS',
      price: '\$1.00',
      change: '+0.6%',
      amount: '1000',
      totalValue: '\$1,000.00',
      color: Color(0xFF607D8B),
      badge: 'Club',
      status: 'Open',
    ),
  ];

  final _predictionItems = const [
    _PredictionListItem(
      title: '阿根廷夺冠',
      subtitle: '2026 World Cup',
      matched: '\$18.2K matched',
      probability: '24%',
      change: '+2.1%',
      icon: Icons.emoji_events_outlined,
    ),
    _PredictionListItem(
      title: '法国进入决赛',
      subtitle: '2026 World Cup',
      matched: '\$12.8K matched',
      probability: '41%',
      change: '+4.8%',
      icon: Icons.sports_soccer_rounded,
    ),
    _PredictionListItem(
      title: '巴西小组第一',
      subtitle: '2026 World Cup',
      matched: '\$9.6K matched',
      probability: '58%',
      change: '-1.2%',
      icon: Icons.flag_outlined,
    ),
    _PredictionListItem(
      title: '英格兰进入四强',
      subtitle: '2026 World Cup',
      matched: '\$7.4K matched',
      probability: '33%',
      change: '+0.8%',
      icon: Icons.shield_outlined,
    ),
    _PredictionListItem(
      title: '金靴进球数超过 7',
      subtitle: '2026 World Cup',
      matched: '\$5.9K matched',
      probability: '19%',
      change: '-0.5%',
      icon: Icons.sports_football_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Market',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          indicatorColor: colorScheme.onSurface,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Financing'),
            Tab(text: '预测市场'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemBuilder: (context, index) =>
                _FinancingTile(item: _financingItems[index]),
            separatorBuilder: (_, _) => const SizedBox.shrink(),
            itemCount: _financingItems.length,
          ),
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            itemBuilder: (context, index) =>
                _PredictionTile(item: _predictionItems[index]),
            separatorBuilder: (_, _) => const SizedBox.shrink(),
            itemCount: _predictionItems.length,
          ),
        ],
      ),
    );
  }
}

class _FinancingTile extends StatelessWidget {
  const _FinancingTile({required this.item});

  final _FinancingListItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final changeColor = item.change.startsWith('+')
        ? const Color(0xFF2E7D46)
        : const Color(0xFFC2384A);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).pushNamed(
          AppRouteNames.portfolioDetail,
          arguments: item.toRouteArgs(),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.34),
              ),
            ),
          ),
          child: Row(
            children: [
              _TokenMark(symbol: item.symbol),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (item.badge != null) ...[
                          const SizedBox(width: 8),
                          _SmallPill(label: item.badge!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.price} · ${item.amount} ${item.symbol}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.totalValue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _SmallPill(label: item.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({required this.item});

  final _PredictionListItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final changeColor = item.change.startsWith('+')
        ? const Color(0xFF2E7D46)
        : const Color(0xFFC2384A);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.34),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.55,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 21,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.subtitle} · ${item.matched}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.probability,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.change,
                    style: TextStyle(
                      color: changeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenMark extends StatelessWidget {
  const _TokenMark({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          symbol.characters.first,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FinancingListItem {
  const _FinancingListItem({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.amount,
    required this.totalValue,
    required this.color,
    required this.status,
    this.badge,
  });

  final String name;
  final String symbol;
  final String price;
  final String change;
  final String amount;
  final String totalValue;
  final Color color;
  final String status;
  final String? badge;

  Map<String, dynamic> toRouteArgs() {
    return {
      'name': name,
      'symbol': symbol,
      'price': price,
      'change': change,
      'amount': amount,
      'totalValue': totalValue,
      'color': color,
      'badge': badge,
    };
  }
}

class _PredictionListItem {
  const _PredictionListItem({
    required this.title,
    required this.subtitle,
    required this.matched,
    required this.probability,
    required this.change,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String matched;
  final String probability;
  final String change;
  final IconData icon;
}
