import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/brand/app_brand.dart';
import '../../../app/routes/app_router.dart';
import '../../../shared/utils/wallet_formatters.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  int _currentBannerIndex = 0;
  bool _showBanner = true;

  final _banners = [
    _AdBannerItem(title: 'Earn Rewards', subtitle: 'Join our loyalty program'),
    _AdBannerItem(
      title: 'New Features',
      subtitle: 'Explore the latest updates',
    ),
    _AdBannerItem(title: 'Stay Secure', subtitle: 'Enable biometric login'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final account = state.currentAccount;
    final network = state.currentNetwork;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          // Swipeable Ad Banner
          if (_showBanner) ...[
            _buildAdBanner(context),
            const SizedBox(height: 16),
          ],
          Text(
            '我的',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _UserProfileCard(
            account: account,
            onCopyAddress: () => _copyAddress(context, account.address),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: '空间管理',
            children: [
              _SettingsRow(
                icon: Icons.account_balance_wallet_outlined,
                title: '钱包管理',
                subtitle: '创建、导入、备份、重命名、账户切换',
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRouteNames.walletManagement),
              ),
              const _InsetDivider(),
              _SettingsRow(
                icon: Icons.public_rounded,
                title: '网络管理',
                subtitle: '${network.name} · ${state.networks.length} 条网络',
                trailingLabel: network.nativeSymbol,
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRouteNames.networkManagement),
              ),
            ],
          ),
          _SettingsSection(
            title: '安全中心',
            children: [
              _SettingsRow(
                icon: Icons.lock_outline,
                title: '安全与隐私',
                subtitle: '密码、生物识别、自动锁定、防截屏、缓存',
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRouteNames.securityPrivacy),
              ),
              const _InsetDivider(),
              _SettingsRow(
                icon: Icons.verified_user_outlined,
                title: '授权管理',
                subtitle: '已连接应用、Token 授权、签名记录',
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRouteNames.authorizationManagement),
              ),
            ],
          ),
          _SettingsSection(
            title: '偏好与支持',
            children: [
              _SettingsRow(
                icon: Icons.card_giftcard_rounded,
                title: '推荐好友',
                subtitle: '分享推荐码，参与 SYNBO 活动奖励',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouteNames.invite),
              ),
              const _InsetDivider(),
              _SettingsRow(
                icon: Icons.notifications_outlined,
                title: '通知设置',
                subtitle: state.notificationsEnabled ? '已开启' : '已关闭',
                onTap: () => Navigator.of(
                  context,
                ).pushNamed(AppRouteNames.notifications),
              ),
              const _InsetDivider(),
              _SettingsRow(
                icon: Icons.help_outline_rounded,
                title: '帮助中心',
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRouteNames.helpCenter),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final banner = _banners[_currentBannerIndex];

    return Column(
      children: [
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < 0) {
                // Swipe left - next
                setState(() {
                  _currentBannerIndex =
                      (_currentBannerIndex + 1) % _banners.length;
                });
              } else if (details.primaryVelocity! > 0) {
                // Swipe right - previous
                setState(() {
                  _currentBannerIndex =
                      (_currentBannerIndex - 1 + _banners.length) %
                      _banners.length;
                });
              }
            }
          },
          onTap: () => setState(() => _showBanner = false),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner.title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner.subtitle,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: colorScheme.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => GestureDetector(
              onTap: () => setState(() => _currentBannerIndex = index),
              child: Container(
                width: index == _currentBannerIndex ? 16 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: index == _currentBannerIndex
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _copyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('地址已复制')));
    }
  }
}

class _AdBannerItem {
  final String title;
  final String subtitle;
  _AdBannerItem({required this.title, required this.subtitle});
}

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({required this.account, required this.onCopyAddress});

  final WalletAccount account;
  final VoidCallback onCopyAddress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(AppBrand.markAsset, fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  compactAddress(account.address),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: '复制地址',
            visualDensity: VisualDensity.compact,
            onPressed: onCopyAddress,
            icon: const Icon(Icons.copy_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.66),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 19, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailingLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingLabel!,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsetDivider extends StatelessWidget {
  const _InsetDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 58,
      color: Theme.of(
        context,
      ).colorScheme.outlineVariant.withValues(alpha: 0.52),
    );
  }
}
