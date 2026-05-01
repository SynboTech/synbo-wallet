import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/brand/app_brand.dart';
import '../../../app/routes/app_router.dart';
import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/chain_logo.dart';
import '../../wallet/models/wallet_models.dart';
import '../../wallet/providers/wallet_state_scope.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final wallet = state.currentWallet;
    final account = state.currentAccount;
    final network = state.currentNetwork;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            '我的',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _IdentityPanel(
            walletName: wallet.name,
            account: account,
            network: network,
            totalAssetsUsd: state.totalAssetsUsd,
            hideBalances: state.hideBalances,
            onCopyAddress: () => _copyAddress(context, account.address),
            onWalletTap: () =>
                Navigator.of(context).pushNamed(AppRouteNames.walletManagement),
            onNetworkTap: () => Navigator.of(
              context,
            ).pushNamed(AppRouteNames.networkManagement),
          ),
          const SizedBox(height: 10),
          _SecurityStrip(
            biometricEnabled: state.biometricEnabled,
            screenshotProtectionEnabled: state.screenshotProtectionEnabled,
            autoLockMinutes: state.autoLockMinutes,
            hideBalances: state.hideBalances,
            onTap: () =>
                Navigator.of(context).pushNamed(AppRouteNames.securityPrivacy),
          ),
          const SizedBox(height: 18),
          _SettingsSection(
            title: '钱包与网络',
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
            title: '安全',
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

  Future<void> _copyAddress(BuildContext context, String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('地址已复制')));
    }
  }
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({
    required this.walletName,
    required this.account,
    required this.network,
    required this.totalAssetsUsd,
    required this.hideBalances,
    required this.onCopyAddress,
    required this.onWalletTap,
    required this.onNetworkTap,
  });

  final String walletName;
  final WalletAccount account;
  final ChainNetwork network;
  final double totalAssetsUsd;
  final bool hideBalances;
  final VoidCallback onCopyAddress;
  final VoidCallback onWalletTap;
  final VoidCallback onNetworkTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(
          alpha: isDark ? 0.74 : 0.7,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(AppBrand.markAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: onWalletTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                walletName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${account.name} · ${compactAddress(account.address)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PanelMetric(
                  label: '总资产',
                  value: hideBalances ? '••••' : formatCurrency(totalAssetsUsd),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onNetworkTap,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChainLogo(
                        chainId: network.id,
                        name: network.name,
                        colorValue: network.colorValue,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '当前网络',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            network.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelMetric extends StatelessWidget {
  const _PanelMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _SecurityStrip extends StatelessWidget {
  const _SecurityStrip({
    required this.biometricEnabled,
    required this.screenshotProtectionEnabled,
    required this.autoLockMinutes,
    required this.hideBalances,
    required this.onTap,
  });

  final bool biometricEnabled;
  final bool screenshotProtectionEnabled;
  final int autoLockMinutes;
  final bool hideBalances;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SecurityChip(
            icon: Icons.fingerprint_rounded,
            label: '生物识别',
            value: biometricEnabled ? '开启' : '关闭',
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SecurityChip(
            icon: Icons.lock_clock_outlined,
            label: '自动锁定',
            value: '$autoLockMinutes min',
            onTap: onTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SecurityChip(
            icon: hideBalances
                ? Icons.visibility_off_outlined
                : Icons.screenshot_monitor_outlined,
            label: hideBalances ? '资产隐藏' : '防截屏',
            value: screenshotProtectionEnabled ? '开启' : '关闭',
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _SecurityChip extends StatelessWidget {
  const _SecurityChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
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
                fontWeight: FontWeight.w900,
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
                        fontWeight: FontWeight.w900,
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
                          fontWeight: FontWeight.w700,
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
                    fontWeight: FontWeight.w900,
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
