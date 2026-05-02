import 'package:flutter/material.dart';

/// 融资项详情页
class PortfolioDetailPage extends StatefulWidget {
  const PortfolioDetailPage({
    super.key,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.amount,
    required this.totalValue,
    required this.color,
    this.badge,
  });

  final String name;
  final String symbol;
  final String price;
  final String change;
  final String amount;
  final String totalValue;
  final Color color;
  final String? badge;

  static const _green = Color(0xFF57C58B);
  static const _red = Color(0xFFE84864);

  @override
  State<PortfolioDetailPage> createState() => _PortfolioDetailPageState();

  static String displayPrice(String value) {
    final numeric = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (numeric == null) {
      return value;
    }
    return (numeric / 17725).toStringAsFixed(5);
  }
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = widget.change.startsWith('+');
    final changeColor = isPositive
        ? PortfolioDetailPage._green
        : PortfolioDetailPage._red;
    final pair = '${widget.symbol}/USDT';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: const _BottomActionBar(),
      body: SafeArea(
        child: Column(
          children: [
            _PairHeader(pair: pair),
            _TopTabs(
              selectedIndex: _selectedTab,
              onChanged: (index) => setState(() => _selectedTab = index),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TabContent(
                      selectedIndex: _selectedTab,
                      name: widget.name,
                      symbol: widget.symbol,
                      price: PortfolioDetailPage.displayPrice(widget.price),
                      amount: widget.amount,
                      totalValue: widget.totalValue,
                      change: widget.change,
                      changeColor: changeColor,
                      badge: widget.badge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairHeader extends StatelessWidget {
  const _PairHeader({required this.pair});

  final String pair;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 31),
            visualDensity: VisualDensity.compact,
          ),
          Container(width: 1, height: 24, color: const Color(0xFFECEFF2)),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    pair,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star_rounded, size: 34),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.open_in_full_rounded, size: 25),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = ['图表', '币种信息', '融资数据', '情报'];
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF7FCFC),
        border: Border(bottom: BorderSide(color: Color(0xFFEFF2F4))),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index == labels.length - 1 ? 0 : 30,
            ),
            child: IntrinsicWidth(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: SizedBox(
                  height: 58,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active
                              ? const Color(0xFF1E2226)
                              : _PortfolioDetailPageMuted.color,
                          fontSize: 17,
                          fontWeight: active
                              ? FontWeight.w900
                              : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: active ? 36 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2226),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.selectedIndex,
    required this.name,
    required this.symbol,
    required this.price,
    required this.amount,
    required this.totalValue,
    required this.change,
    required this.changeColor,
    this.badge,
  });

  final int selectedIndex;
  final String name;
  final String symbol;
  final String price;
  final String amount;
  final String totalValue;
  final String change;
  final Color changeColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return switch (selectedIndex) {
      0 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MarketSummary(
            price: price,
            amount: amount,
            symbol: symbol,
            change: change,
            changeColor: changeColor,
            badge: badge,
          ),
          const _TimeframeBar(),
          const SizedBox(
            height: 470,
            width: double.infinity,
            child: _MarketChart(),
          ),
        ],
      ),
      1 => _PlaceholderTabPage(
        title: '币种信息',
        subtitle: '$name 项目信息将在这里展示',
        rows: [
          ('币种', symbol),
          ('当前价格', price),
          ('标签', badge ?? 'DeFi'),
          ('说明', '项目简介、合约信息和风险提示占位'),
        ],
      ),
      2 => _PlaceholderTabPage(
        title: '融资数据',
        subtitle: '$name 融资表现和参与数据将在这里展示',
        rows: [
          ('融资规模', totalValue),
          ('持有数量', '$amount $symbol'),
          ('24h 变化', change),
          ('状态', '数据模块占位'),
        ],
      ),
      _ => _PlaceholderTabPage(
        title: '情报',
        subtitle: '$name 市场情报和公告将在这里展示',
        rows: const [
          ('最新公告', '占位'),
          ('项目动态', '占位'),
          ('风险提醒', '占位'),
          ('研究摘要', '占位'),
        ],
      ),
    };
  }
}

class _PlaceholderTabPage extends StatelessWidget {
  const _PlaceholderTabPage({
    required this.title,
    required this.subtitle,
    required this.rows,
  });

  final String title;
  final String subtitle;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              color: _PortfolioDetailPageMuted.color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),
          Container(height: 1, color: const Color(0xFFEFF2F4)),
          for (final row in rows)
            _PlaceholderInfoRow(label: row.$1, value: row.$2),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.insert_chart_outlined_rounded,
                  color: Color(0xFF9AA3AB),
                  size: 30,
                ),
                SizedBox(height: 14),
                Text(
                  '内容占位',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  '后续接入真实数据后，这里会替换为对应模块的完整内容。',
                  style: TextStyle(
                    color: _PortfolioDetailPageMuted.color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderInfoRow extends StatelessWidget {
  const _PlaceholderInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFF2F4))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _PortfolioDetailPageMuted.color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketSummary extends StatelessWidget {
  const _MarketSummary({
    required this.price,
    required this.amount,
    required this.symbol,
    required this.change,
    required this.changeColor,
    this.badge,
  });

  final String price;
  final String amount;
  final String symbol;
  final String change;
  final Color changeColor;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const Text(
                      '≈ 0.14 USD',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      change,
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    const _Tag(label: '创新区'),
                    const _Tag(label: 'DeFi'),
                    if (badge != null) _Tag(label: badge!),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatRow(label: '24h 最高价', value: '0.16214'),
              _StatRow(label: '24h 最低价', value: '0.1256'),
              _StatRow(label: '24h 成交量($symbol)', value: '${amount}M'),
              const _StatRow(label: '24h 成交总额(USDT)', value: '1.46M'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF818991),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _PortfolioDetailPageMuted.color,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 18),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _TimeframeBar extends StatelessWidget {
  const _TimeframeBar();

  @override
  Widget build(BuildContext context) {
    final labels = ['5分', '15分', '1时', '4时', '1日', '周K', '更多'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 18, 14),
      child: Row(
        children: [
          for (final label in labels) ...[
            Text(
              label,
              style: TextStyle(
                color: label == '1日'
                    ? const Color(0xFF1E2226)
                    : _PortfolioDetailPageMuted.color,
                fontSize: 17,
                fontWeight: label == '1日' ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const Spacer(),
          ],
          const Icon(
            Icons.smart_toy_outlined,
            size: 25,
            color: Color(0xFF65717C),
          ),
          const SizedBox(width: 18),
          const Icon(
            Icons.settings_outlined,
            size: 26,
            color: Color(0xFF1E2226),
          ),
        ],
      ),
    );
  }
}

class _MarketChart extends StatelessWidget {
  const _MarketChart();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 7,
          child: CustomPaint(
            painter: _CandleChartPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        Expanded(
          flex: 2,
          child: CustomPaint(
            painter: _VolumeChartPainter(),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  static const _actions = [
    _BottomAction(
      label: 'Check',
      color: Color(0xFF2F80ED),
      kind: _ActionKind.check,
    ),
    _BottomAction(
      label: 'Uncheck',
      color: Color(0xFFE84864),
      kind: _ActionKind.uncheck,
    ),
    _BottomAction(
      label: 'Buy',
      color: Color(0xFFFF8F4D),
      kind: _ActionKind.buy,
    ),
    _BottomAction(
      label: 'Sell',
      color: Color(0xFFE84864),
      kind: _ActionKind.sell,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEFF2F4))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomActionRow(actions: _actions.take(2).toList()),
            const SizedBox(height: 10),
            _BottomActionRow(actions: _actions.skip(2).toList()),
          ],
        ),
      ),
    );
  }
}

class _BottomActionRow extends StatelessWidget {
  const _BottomActionRow({required this.actions});

  final List<_BottomAction> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
            child: SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: action.color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                onPressed: () => _handleBottomAction(context, action),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    action.label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

void _handleBottomAction(BuildContext context, _BottomAction action) {
  switch (action.kind) {
    case _ActionKind.buy:
      _showTradeSheet(context, _TradeTab.buy);
    case _ActionKind.sell:
      _showTradeSheet(context, _TradeTab.sell);
    case _ActionKind.check:
      _showCheckSheet(context, _CheckTab.check);
    case _ActionKind.uncheck:
      _showCheckSheet(context, _CheckTab.uncheck);
  }
}

void _showTradeSheet(BuildContext context, _TradeTab initialTab) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TradeBottomSheet(initialTab: initialTab),
  );
}

void _showCheckSheet(BuildContext context, _CheckTab initialTab) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CheckBottomSheet(initialTab: initialTab),
  );
}

class _BottomAction {
  const _BottomAction({
    required this.label,
    required this.color,
    required this.kind,
  });

  final String label;
  final Color color;
  final _ActionKind kind;
}

enum _ActionKind { check, uncheck, buy, sell }

enum _TradeTab { buy, sell, mint }

enum _CheckTab { check, uncheck }

class _TradeBottomSheet extends StatefulWidget {
  const _TradeBottomSheet({required this.initialTab});

  final _TradeTab initialTab;

  @override
  State<_TradeBottomSheet> createState() => _TradeBottomSheetState();
}

class _TradeBottomSheetState extends State<_TradeBottomSheet> {
  static const _maxTradeAmount = 10000.0;
  static const _lossRate = 0.03;

  late _TradeTab _selectedTab = widget.initialTab;
  final _amountController = TextEditingController();
  bool _earlyMint = false;
  double _amount = 0;

  bool get _isAmountValid => _amount > 0 && _amount <= _maxTradeAmount;
  bool get _isOverMax => _amount > _maxTradeAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxLoss = _amount * _lossRate;
    final fee = _amount * 0.01;
    final totalPayment = _amount + fee;
    final receive = _amount > 0 ? _amount * (1 - _lossRate) : 0.0;
    final isSell = _selectedTab == _TradeTab.sell;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _TradeTabButton(
                    label: 'Buy',
                    active: _selectedTab == _TradeTab.buy,
                    onTap: () => setState(() => _selectedTab = _TradeTab.buy),
                  ),
                  const SizedBox(width: 34),
                  _TradeTabButton(
                    label: 'Sell',
                    active: _selectedTab == _TradeTab.sell,
                    onTap: () => setState(() => _selectedTab = _TradeTab.sell),
                  ),
                  const SizedBox(width: 34),
                  _TradeTabButton(
                    label: 'Mint',
                    active: _selectedTab == _TradeTab.mint,
                    onTap: () => setState(() => _selectedTab = _TradeTab.mint),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Select a Club with Eligibility',
                style: TextStyle(
                  color: Color(0xFF505963),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              const _TradeSelectField(),
              const SizedBox(height: 28),
              Text(
                isSell ? 'Sell Amount (Share)' : 'Buy Amount (Share)',
                style: const TextStyle(
                  color: Color(0xFF505963),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _TradeAmountField(
                controller: _amountController,
                suffix: 'Share',
                onChanged: (value) {
                  setState(() {
                    _amount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'USDS Balance: 0.00',
                      style: TextStyle(
                        color: Color(0xFF505963),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    isSell
                        ? 'Single Max Sell: ${_maxTradeAmount.toStringAsFixed(0)} Share'
                        : 'Single Max Buy: ${_maxTradeAmount.toStringAsFixed(0)} Share',
                    style: const TextStyle(
                      color: Color(0xFF9AA0A6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (_isOverMax) ...[
                const SizedBox(height: 8),
                Text(
                  isSell
                      ? 'Single sell amount cannot exceed ${_maxTradeAmount.toStringAsFixed(0)} Share'
                      : 'Single buy amount cannot exceed ${_maxTradeAmount.toStringAsFixed(0)} Share',
                  style: const TextStyle(
                    color: Color(0xFFE84864),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const _TradeSummaryRow(label: 'Slippage', value: '0.00%'),
              const SizedBox(height: 14),
              const _TradeSummaryRow(label: 'Fee', value: '1%'),
              const SizedBox(height: 14),
              _TradeSummaryRow(
                label: 'Total Payment',
                value: '${totalPayment.toStringAsFixed(2)} USDS',
              ),
              const SizedBox(height: 14),
              _TradeSummaryRow(
                label: 'Max Loss',
                value: '${maxLoss.toStringAsFixed(2)} Share',
              ),
              const SizedBox(height: 14),
              _TradeSummaryRow(
                label: 'You Receive',
                value: '${receive.toStringAsFixed(2)} Share',
              ),
              const SizedBox(height: 14),
              const _TradeSummaryRow(
                label: 'Last Stop Trading Time',
                value: '2026-05-02 23:59',
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: const Color(0xFFE8E8E8)),
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _earlyMint = !_earlyMint),
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                      height: 25,
                      child: Checkbox(
                        value: _earlyMint,
                        onChanged: (value) =>
                            setState(() => _earlyMint = value ?? false),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Early Mint',
                      style: TextStyle(
                        color: Color(0xFF505963),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isAmountValid ? () {} : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8F4D),
                    disabledBackgroundColor: const Color(0xFFFFA166),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.62,
                    ),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    isSell ? 'Sell Share' : 'Pay USDS & Buy',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TradeTabButton extends StatelessWidget {
  const _TradeTabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF1E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFFFF6B00) : const Color(0xFF505963),
            fontSize: 17,
            fontWeight: active ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TradeSelectField extends StatelessWidget {
  const _TradeSelectField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Select a Club',
              style: TextStyle(
                color: Color(0xFF9AA0A6),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 30),
        ],
      ),
    );
  }
}

class _TradeAmountField extends StatelessWidget {
  const _TradeAmountField({
    required this.controller,
    required this.suffix,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String suffix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Color(0xFF8F969E),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF20242A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            suffix,
            style: const TextStyle(
              color: Color(0xFFFF6B00),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeSummaryRow extends StatelessWidget {
  const _TradeSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9AA0A6),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF20242A),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CheckBottomSheet extends StatefulWidget {
  const _CheckBottomSheet({required this.initialTab});

  final _CheckTab initialTab;

  @override
  State<_CheckBottomSheet> createState() => _CheckBottomSheetState();
}

class _CheckBottomSheetState extends State<_CheckBottomSheet> {
  static const _minAmount = 1000.0;
  static const _riskRate = 0.03;

  late _CheckTab _selectedTab = widget.initialTab;
  final _amountController = TextEditingController();
  double _amount = 0;

  bool get _isValidAmount => _amount >= _minAmount;
  bool get _showMinimumHint => _amount > 0 && !_isValidAmount;

  String get _activeLabel =>
      _selectedTab == _CheckTab.check ? 'Check' : 'Uncheck';

  String get _inputTitle =>
      _selectedTab == _CheckTab.check ? 'Checked USDS' : 'Unchecked USDS';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxLoss = _amount * _riskRate;
    final receive = _amount > 0 ? _amount * (1 - _riskRate) : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CheckTabButton(
                    label: 'Check',
                    active: _selectedTab == _CheckTab.check,
                    onTap: () => setState(() => _selectedTab = _CheckTab.check),
                  ),
                  const SizedBox(width: 28),
                  _CheckTabButton(
                    label: 'Uncheck',
                    active: _selectedTab == _CheckTab.uncheck,
                    onTap: () =>
                        setState(() => _selectedTab = _CheckTab.uncheck),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Text(
                _inputTitle,
                style: const TextStyle(
                  color: Color(0xFF9AA0A6),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _CheckAmountField(
                controller: _amountController,
                onChanged: (value) {
                  setState(() {
                    _amount = double.tryParse(value) ?? 0;
                  });
                },
                onMax: () {
                  const maxAmount = 10000.0;
                  _amountController.text = maxAmount.toStringAsFixed(2);
                  setState(() => _amount = maxAmount);
                },
              ),
              const SizedBox(height: 12),
              Text(
                '$_inputTitle: ${_amount.toStringAsFixed(2)} USDS',
                style: const TextStyle(
                  color: Color(0xFF9AA0A6),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_showMinimumHint) ...[
                const SizedBox(height: 8),
                const Text(
                  'Minimum single order: 1000 USDS',
                  style: TextStyle(
                    color: Color(0xFFE84864),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const _TradeSummaryRow(label: 'Fee', value: '3%'),
              const SizedBox(height: 14),
              _TradeSummaryRow(
                label: 'Max Loss',
                value: '${maxLoss.toStringAsFixed(2)} USDS',
              ),
              const SizedBox(height: 14),
              const _TradeSummaryRow(label: 'Profit Yield', value: '+3.00%'),
              const SizedBox(height: 14),
              _TradeSummaryRow(
                label: 'You will receive',
                value: '${receive.toStringAsFixed(2)} USDS',
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: _isValidAmount ? () {} : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6400),
                    disabledBackgroundColor: const Color(0xFFD8DEE4),
                    disabledForegroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Confirm $_activeLabel',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckTabButton extends StatelessWidget {
  const _CheckTabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFF20242A) : const Color(0xFF9AA0A6),
          fontSize: 18,
          fontWeight: active ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _CheckAmountField extends StatelessWidget {
  const _CheckAmountField({
    required this.controller,
    required this.onChanged,
    required this.onMax,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onMax;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.fromLTRB(18, 0, 10, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        border: Border.all(color: const Color(0xFFDCDDDF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(
                  color: Color(0xFF9AA0A6),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: const TextStyle(
                color: Color(0xFF20242A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onMax,
            child: const Text(
              'MAX',
              style: TextStyle(
                color: Color(0xFFFF8F4D),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandleChartPainter extends CustomPainter {
  final _candles = const [
    _Candle(0.05, 0.17, 0.04, 0.16),
    _Candle(0.16, 0.18, 0.07, 0.15),
    _Candle(0.15, 0.17, 0.14, 0.154),
    _Candle(0.154, 0.16, 0.13, 0.145),
    _Candle(0.145, 0.31, 0.14, 0.235),
    _Candle(0.235, 0.30, 0.18, 0.276),
    _Candle(0.276, 0.278, 0.22, 0.274),
    _Candle(0.274, 0.275, 0.245, 0.249),
    _Candle(0.249, 0.260, 0.235, 0.256),
    _Candle(0.256, 0.267, 0.244, 0.258),
    _Candle(0.258, 0.292, 0.205, 0.286),
    _Candle(0.286, 0.298, 0.098, 0.221),
    _Candle(0.221, 0.245, 0.190, 0.223),
    _Candle(0.223, 0.235, 0.188, 0.193),
    _Candle(0.193, 0.235, 0.181, 0.206),
    _Candle(0.206, 0.208, 0.176, 0.184),
    _Candle(0.184, 0.190, 0.166, 0.176),
    _Candle(0.176, 0.178, 0.165, 0.171),
    _Candle(0.171, 0.212, 0.166, 0.186),
    _Candle(0.186, 0.224, 0.164, 0.173),
    _Candle(0.173, 0.184, 0.141, 0.158),
    _Candle(0.158, 0.176, 0.154, 0.170),
    _Candle(0.170, 0.188, 0.162, 0.182),
    _Candle(0.182, 0.192, 0.161, 0.184),
    _Candle(0.184, 0.185, 0.160, 0.174),
    _Candle(0.174, 0.183, 0.156, 0.177),
    _Candle(0.177, 0.182, 0.155, 0.175),
    _Candle(0.175, 0.177, 0.134, 0.153),
    _Candle(0.153, 0.174, 0.124, 0.172),
    _Candle(0.172, 0.174, 0.126, 0.145),
    _Candle(0.145, 0.162, 0.129, 0.1395),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F3F5)
      ..strokeWidth = 0.8;
    for (var i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    _drawLabels(canvas, size);
    _drawEmaLabels(canvas);
    _drawWatermark(canvas, size);

    const high = 0.335;
    const low = 0.045;
    double mapY(double value) {
      return 18 + (high - value) / (high - low) * (size.height - 40);
    }

    final step = size.width / (_candles.length + 5);
    final bodyWidth = step * 0.78;
    final greenPaint = Paint()..color = PortfolioDetailPage._green;
    final redPaint = Paint()..color = PortfolioDetailPage._red;

    for (var i = 0; i < _candles.length; i++) {
      final candle = _candles[i];
      final x = step * (i + 3);
      final paint = candle.close >= candle.open ? greenPaint : redPaint;
      canvas.drawLine(
        Offset(x, mapY(candle.high)),
        Offset(x, mapY(candle.low)),
        paint..strokeWidth = 1.5,
      );
      final top = mapY(candle.close > candle.open ? candle.close : candle.open);
      final bottom = mapY(
        candle.close > candle.open ? candle.open : candle.close,
      );
      canvas.drawRect(
        Rect.fromLTRB(
          x - bodyWidth / 2,
          top,
          x + bodyWidth / 2,
          bottom.clamp(top + 2, size.height),
        ),
        paint,
      );
    }

    _drawLine(canvas, size, step, mapY, const Color(0xFFF1C75B), 10, 22);
    _drawLine(canvas, size, step, mapY, const Color(0xFFB45BA7), 24, 31);
    _drawPriceMarker(canvas, size, mapY(0.1395));
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    double step,
    double Function(double value) mapY,
    Color color,
    int start,
    int end,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (var i = start; i <= end && i < _candles.length; i++) {
      final x = step * (i + 3);
      final avg = (_candles[i].open + _candles[i].close) / 2;
      final y = mapY(avg);
      if (i == start) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    const labels = [
      '0.33156',
      '0.27448',
      '0.21741',
      '0.16034',
      '0.10326',
      '0.04619',
    ];
    for (var i = 0; i < labels.length; i++) {
      _drawText(
        canvas,
        labels[i],
        Offset(size.width - 43, 4 + i * (size.height - 25) / 5),
        const Color(0xFF818991),
        13,
        FontWeight.w600,
      );
    }
    _drawText(
      canvas,
      '0.31',
      Offset(size.width * 0.22, 38),
      const Color(0xFF525960),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '0.05',
      Offset(size.width * 0.13, size.height - 20),
      const Color(0xFF525960),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '2026-03-31',
      Offset(0, size.height - 4),
      const Color(0xFF818991),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '2026-04-06',
      Offset(size.width * 0.19, size.height - 4),
      const Color(0xFF818991),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '2026-04-17',
      Offset(size.width * 0.44, size.height - 4),
      const Color(0xFF818991),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '2026-04-28',
      Offset(size.width * 0.63, size.height - 4),
      const Color(0xFF818991),
      13,
      FontWeight.w600,
    );
  }

  void _drawEmaLabels(Canvas canvas) {
    _drawText(
      canvas,
      'EMA7:0.15869',
      const Offset(10, 12),
      const Color(0xFFE9BE55),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      'EMA25:0.18148',
      const Offset(112, 12),
      const Color(0xFFB45BA7),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      'EMA99:--',
      const Offset(235, 12),
      const Color(0xFF8C83C5),
      13,
      FontWeight.w600,
    );
  }

  void _drawWatermark(Canvas canvas, Size size) {
    _drawText(
      canvas,
      'SYNBO',
      Offset(size.width * 0.10, size.height * 0.73),
      const Color(0xFFE7EAED),
      34,
      FontWeight.w900,
    );
  }

  void _drawPriceMarker(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = PortfolioDetailPage._red
      ..strokeWidth = 1.8;
    canvas.drawLine(
      Offset(size.width - 120, y),
      Offset(size.width - 57, y),
      paint,
    );
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 57, y - 13, 55, 26),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, Paint()..color = PortfolioDetailPage._red);
    _drawText(
      canvas,
      '0.1395',
      Offset(size.width - 47, y - 8),
      Colors.white,
      13,
      FontWeight.w800,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VolumeChartPainter extends CustomPainter {
  final _volumes = const [
    2.7,
    5.6,
    2.1,
    0.1,
    0.2,
    0.8,
    2.6,
    2.2,
    0.9,
    0.9,
    0.9,
    1.2,
    4.0,
    5.1,
    4.3,
    4.8,
    4.7,
    4.9,
    4.0,
    2.4,
    2.5,
    2.3,
    1.8,
    1.5,
    2.1,
    3.0,
    2.6,
    2.8,
    3.6,
    3.7,
    2.9,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F3F5)
      ..strokeWidth = 0.8;
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), gridPaint);
    canvas.drawLine(
      Offset(0, size.height * 0.72),
      Offset(size.width, size.height * 0.72),
      gridPaint,
    );
    final step = size.width / (_volumes.length + 5);
    final barWidth = step * 0.78;
    for (var i = 0; i < _volumes.length; i++) {
      final x = step * (i + 3);
      final h = (_volumes[i] / 6.0) * (size.height - 25);
      final color = i % 4 == 1 || i % 5 == 0
          ? PortfolioDetailPage._red.withValues(alpha: 0.48)
          : PortfolioDetailPage._green.withValues(alpha: 0.48);
      canvas.drawRect(
        Rect.fromLTWH(x - barWidth / 2, size.height - h - 10, barWidth, h),
        Paint()..color = color,
      );
    }
    _drawText(
      canvas,
      'VOL:2.7M',
      const Offset(10, 12),
      PortfolioDetailPage._red,
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      'MA5:4.6M',
      const Offset(76, 12),
      const Color(0xFFAAA68E),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      'MA10:4.2M',
      const Offset(152, 12),
      const Color(0xFF8B97BC),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '10.8M',
      Offset(size.width - 44, 7),
      const Color(0xFF818991),
      13,
      FontWeight.w600,
    );
    _drawText(
      canvas,
      '1.1M',
      Offset(size.width - 38, size.height - 21),
      const Color(0xFF818991),
      13,
      FontWeight.w600,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: 0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Candle {
  const _Candle(this.open, this.high, this.low, this.close);

  final double open;
  final double high;
  final double low;
  final double close;
}

class _PortfolioDetailPageMuted {
  static const color = Color(0xFF7B838B);
}
