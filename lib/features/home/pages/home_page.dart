import 'package:flutter/material.dart';

import '../../../app/brand/app_brand.dart';
import '../../../app/routes/app_router.dart';
import '../models/square_models.dart';

/// 首页 - Binance/CMC 风格的 Dashboard
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _portfolioTabIndex = 0; // 0: Financing, 1: Prediction Market
  String _squareFilter = 'Trending'; // Trending or Latest
  final ScrollController _squareScrollController = ScrollController();

  late List<SquarePost> _squarePosts;

  @override
  void initState() {
    super.initState();
    _squarePosts = [
      SquarePost(
        id: 'crypto-insights-1',
        author: 'Crypto Insights',
        avatar: 'CI',
        color: Colors.blue,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        content:
            'Bitcoin showed strong support at \$95,000 level. Watch for potential breakout above \$100K soon.',
        likes: 234,
        comments: 45,
        shares: 12,
        isLiked: false,
      ),
      SquarePost(
        id: 'defi-watch-1',
        author: 'DeFi Watch',
        avatar: 'DW',
        color: Colors.purple,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        content:
            'New yield farming opportunities emerging on Base. APY ranges from 8-15% for stablecoin pairs.',
        likes: 189,
        comments: 67,
        shares: 28,
        isLiked: false,
      ),
      SquarePost(
        id: 'tech-analysis-1',
        author: 'Tech Analysis',
        avatar: 'TA',
        color: Colors.green,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        content:
            'Ethereum gas fees at 6-month low. Perfect time to bridge assets or interact with Layer 2s.',
        likes: 156,
        comments: 34,
        shares: 19,
        isLiked: false,
      ),
      SquarePost(
        id: 'security-alert-1',
        author: 'Security Alert',
        avatar: 'SA',
        color: Colors.red,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        content:
            'Warning: New phishing campaign targeting DeFi users. Always verify contract addresses before signing.',
        likes: 412,
        comments: 89,
        shares: 156,
        isLiked: false,
      ),
      SquarePost(
        id: 'market-update-1',
        author: 'Market Update',
        avatar: 'MU',
        color: Colors.orange,
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        content:
            'Solana TVL reached new all-time high. Network upgrade coming next month should improve throughput.',
        likes: 298,
        comments: 56,
        shares: 43,
        isLiked: false,
      ),
      SquarePost(
        id: 'nft-pulse-1',
        author: 'NFT Pulse',
        avatar: 'NP',
        color: Colors.pink,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        content:
            'Blue chip NFT floor prices stabilizing after recent correction. Floor prices holding strong.',
        likes: 145,
        comments: 23,
        shares: 8,
        isLiked: false,
      ),
      SquarePost(
        id: 'airdrop-hunter-1',
        author: 'Airdrop Hunter',
        avatar: 'AH',
        color: Colors.teal,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        content:
            'Hidden airdrop season detected! Several protocols teasing token announcements. Stay active on testnets.',
        likes: 567,
        comments: 134,
        shares: 89,
        isLiked: false,
      ),
    ];
  }

  @override
  void dispose() {
    _squareScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            controller: _squareScrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _buildHeader(context)),
              // Ecosystem
              SliverToBoxAdapter(child: _buildEcosystem(context)),
              // Portfolio Section with left-side nav
              SliverToBoxAdapter(child: _buildPortfolioSection(context)),
              // Square Header
              SliverToBoxAdapter(child: _buildSquareHeader(context)),
              // Square Posts (Twitter-like feed)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SquarePostCard(
                    post: _squarePosts[index],
                    isLast: index == _squarePosts.length - 1,
                    onLike: () => _toggleLike(index),
                    onOpen: () => _openSquarePost(_squarePosts[index]),
                    onAuthorOpen: () => _openAuthorSpace(_squarePosts[index]),
                    onComment: () => _showCommentSheet(_squarePosts[index]),
                    onShare: () => _showShareSheet(_squarePosts[index]),
                  ),
                  childCount: _squarePosts.length,
                ),
              ),
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              AppBrand.markAsset,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYNBO',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Primary Market Financing Protocol',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcosystem(BuildContext context) {
    final items = [
      const _EcosystemItem(
        title: 'Capital',
        icon: Icons.trending_up_rounded,
        color: Color(0xFF5B6EE1),
      ),
      const _EcosystemItem(
        title: 'Club',
        icon: Icons.group_rounded,
        color: Color(0xFF7B3FE4),
      ),
      const _EcosystemItem(
        title: 'Research',
        icon: Icons.analytics_rounded,
        color: Color(0xFF00A86B),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _EcosystemTile(item: items[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final portfolioTabs = ['Financing', '预测市场'];
    final pageController = PageController();

    // Mock data - 简洁卡片样式
    final financingItems = [
      _PortfolioItem(
        name: 'Synbo',
        symbol: 'SYNBO',
        price: '\$2,480.75',
        change: '+12.5%',
        amount: '124.5',
        totalValue: '\$2,480.75',
        color: Colors.blue,
        badge: 'Hot',
      ),
      _PortfolioItem(
        name: 'Bondly',
        symbol: 'BOND',
        price: '\$1,856.30',
        change: '+8.3%',
        amount: '892.3',
        totalValue: '\$1,856.30',
        color: Colors.green,
      ),
      _PortfolioItem(
        name: 'Stablecoin',
        symbol: 'USDC',
        price: '\$945.20',
        change: '+3.2%',
        amount: '945.2',
        totalValue: '\$945.20',
        color: Colors.teal,
      ),
      _PortfolioItem(
        name: 'YieldX',
        symbol: 'YIELD',
        price: '\$680.50',
        change: '+15.7%',
        amount: '68.05',
        totalValue: '\$680.50',
        color: Colors.orange,
        badge: 'New',
      ),
      _PortfolioItem(
        name: 'Growth',
        symbol: 'GRW',
        price: '\$420.00',
        change: '+5.1%',
        amount: '42.0',
        totalValue: '\$420.00',
        color: Colors.purple,
      ),
    ];

    final predictionItems = [
      _PredictionMarketItem(
        title: '阿根廷夺冠',
        subtitle: '2026 World Cup · \$18.2K matched',
        probability: '24%',
        change: '+2.1%',
        icon: Icons.emoji_events_outlined,
      ),
      _PredictionMarketItem(
        title: '法国进入决赛',
        subtitle: '2026 World Cup · \$12.8K matched',
        probability: '41%',
        change: '+4.8%',
        icon: Icons.sports_soccer_rounded,
      ),
      _PredictionMarketItem(
        title: '巴西小组第一',
        subtitle: '2026 World Cup · \$9.6K matched',
        probability: '58%',
        change: '-1.2%',
        icon: Icons.flag_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(portfolioTabs.length, (index) {
                  final isActive = _portfolioTabIndex == index;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _portfolioTabIndex = index);
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == portfolioTabs.length - 1 ? 0 : 22,
                        top: 4,
                        bottom: 2,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            portfolioTabs[index],
                            style: TextStyle(
                              color: isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: isActive ? 22 : 0,
                            height: 2,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              _TextButton(
                label: 'More',
                onTap: () => _showMorePortfolio(context, _portfolioTabIndex),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: PageView(
              controller: pageController,
              onPageChanged: (index) =>
                  setState(() => _portfolioTabIndex = index),
              children: [
                Column(
                  children: financingItems
                      .map((item) => _PortfolioCard(item: item))
                      .toList(),
                ),
                Column(
                  children: predictionItems
                      .map((item) => _PredictionMarketCard(item: item))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Square',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Row(
            children: [
              _TextButton(
                label: 'Trending',
                onTap: () => setState(() => _squareFilter = 'Trending'),
                isActive: _squareFilter == 'Trending',
              ),
              const SizedBox(width: 4),
              _TextButton(
                label: 'Latest',
                onTap: () => setState(() => _squareFilter = 'Latest'),
                isActive: _squareFilter == 'Latest',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleLike(int index) {
    setState(() {
      _squarePosts[index].isLiked = !_squarePosts[index].isLiked;
      _squarePosts[index].likes += _squarePosts[index].isLiked ? 1 : -1;
    });
  }

  void _openSquarePost(SquarePost post) {
    Navigator.of(
      context,
    ).pushNamed(AppRouteNames.squarePostDetail, arguments: post);
  }

  void _openAuthorSpace(SquarePost post) {
    Navigator.of(context).pushNamed(
      AppRouteNames.authorSpace,
      arguments: SquareAuthorProfile.fromPost(post),
    );
  }

  void _showCommentSheet(SquarePost post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Comment on: ${post.author}')));
  }

  void _showShareSheet(SquarePost post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Share: ${post.author}\'s post')));
  }
}

class _EcosystemItem {
  const _EcosystemItem({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _EcosystemTile extends StatelessWidget {
  const _EcosystemTile({required this.item});

  final _EcosystemItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showEcosystemPage(context, item.title),
        child: Ink(
          height: 92,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171B20) : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF252B32) : const Color(0xFFE4E8EC),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 18),
                  ),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.62),
                  ),
                ],
              ),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioItem {
  final String name;
  final String symbol;
  final String price;
  final String change;
  final String amount;
  final String totalValue;
  final Color color;
  final String? badge;

  _PortfolioItem({
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.amount,
    required this.totalValue,
    required this.color,
    this.badge,
  });
}

class _PredictionMarketItem {
  final String title;
  final String subtitle;
  final String probability;
  final String change;
  final IconData icon;

  _PredictionMarketItem({
    required this.title,
    required this.subtitle,
    required this.probability,
    required this.change,
    required this.icon,
  });
}

class _PortfolioCard extends StatelessWidget {
  const _PortfolioCard({required this.item});
  final _PortfolioItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = item.change.startsWith('+');
    final changeColor = isPositive
        ? const Color(0xFF2E7D46)
        : const Color(0xFFC2384A);
    final symbolPrefix = item.symbol.substring(
      0,
      1.clamp(0, item.symbol.length),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: GestureDetector(
        onTap: () => _showPortfolioDetail(context, item),
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
              child: Center(
                child: Text(
                  symbolPrefix,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item.badge!,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.price,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        ' · ',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.totalValue,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.amount} ${item.symbol}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
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
}

void _showPortfolioDetail(BuildContext context, _PortfolioItem item) {
  Navigator.of(context).pushNamed(
    AppRouteNames.portfolioDetail,
    arguments: {
      'name': item.name,
      'symbol': item.symbol,
      'price': item.price,
      'change': item.change,
      'amount': item.amount,
      'totalValue': item.totalValue,
      'color': item.color,
      'badge': item.badge,
    },
  );
}

class _PredictionMarketCard extends StatelessWidget {
  const _PredictionMarketCard({required this.item});
  final _PredictionMarketItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = item.change.startsWith('+');
    final changeColor = isPositive
        ? const Color(0xFF2E7D46)
        : const Color(0xFFC2384A);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              mainAxisSize: MainAxisSize.min,
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
                  item.subtitle,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.probability,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
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
    );
  }
}

class _SquarePostCard extends StatelessWidget {
  const _SquarePostCard({
    required this.post,
    required this.isLast,
    required this.onLike,
    required this.onOpen,
    required this.onAuthorOpen,
    required this.onComment,
    required this.onShare,
  });
  final SquarePost post;
  final bool isLast;
  final VoidCallback onLike;
  final VoidCallback onOpen;
  final VoidCallback onAuthorOpen;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.06),
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onOpen,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAuthorOpen,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: post.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.avatar,
                    style: TextStyle(
                      color: post.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onAuthorOpen,
                          child: Text(
                            post.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.time,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _ActionButton(
                        icon: post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: post.likes.toString(),
                        onTap: onLike,
                        color: Colors.pink,
                        isActive: post.isLiked,
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: post.comments.toString(),
                        onTap: onComment,
                      ),
                      const SizedBox(width: 16),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: post.shares.toString(),
                        onTap: onShare,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isActive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = isActive
        ? (color ?? Colors.pink)
        : (color ?? colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: activeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: activeColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    required this.label,
    required this.onTap,
    this.isActive = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            color: isActive
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// Helper
void _showEcosystemPage(BuildContext context, String ecosystem) {
  if (ecosystem == 'Capital') {
    Navigator.of(context).pushNamed(AppRouteNames.capital);
    return;
  }
  if (ecosystem == 'Club') {
    Navigator.of(context).pushNamed(AppRouteNames.club);
    return;
  }
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(ecosystem)));
}

void _showMorePortfolio(BuildContext context, int initialTabIndex) {
  Navigator.of(
    context,
  ).pushNamed(AppRouteNames.portfolioList, arguments: initialTabIndex);
}
