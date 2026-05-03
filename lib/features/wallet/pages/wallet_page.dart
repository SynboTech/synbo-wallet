import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/routes/app_router.dart';
import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/chain_logo.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/wallet_models.dart';
import '../providers/wallet_state_scope.dart';
import '../widgets/token_asset_tile.dart';
import 'add_token_page.dart';
import 'receive_page.dart';
import 'scan_page.dart';
import 'send_flow_page.dart';
import 'token_detail_page.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.walletState;
    final tokens = state.visibleTokens;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: state.refreshAssets,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _AccountHeader(
                    walletName: state.currentWallet.name,
                    account: state.currentAccount,
                    network: state.currentNetwork,
                  ),
                  const SizedBox(height: 12),
                  _AssetOverview(
                    totalAssetsUsd: state.totalAssetsUsd,
                    hideBalances: state.hideBalances,
                    isRefreshing: state.isRefreshing,
                    assetError: state.assetError,
                    onToggleHidden: state.toggleHideBalances,
                    onRefresh: state.refreshAssets,
                  ),
                  const SizedBox(height: 12),
                  const _QuickActions(),
                  SectionHeader(
                    title: 'Assets',
                    action: TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AddTokenPage(),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Token'),
                    ),
                  ),
                  if (tokens.isEmpty)
                    EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No visible tokens',
                      message: 'Switch network or add a token.',
                      action: FilledButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AddTokenPage(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Token'),
                      ),
                    )
                  else
                    ...tokens.map(
                      (token) => TokenAssetTile(
                        token: token,
                        network: state.networkById(token.networkId),
                        hideBalances: state.hideBalances,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TokenDetailPage(tokenId: token.id),
                          ),
                        ),
                        onHide: () => state.toggleTokenHidden(token.id),
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({
    required this.walletName,
    required this.account,
    required this.network,
  });

  final String walletName;
  final WalletAccount account;
  final ChainNetwork network;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showAccountSwitcher(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            walletName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${compactAddress(account.address)} · ${network.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _HeaderIconButton(
            tooltip: 'Copy address',
            icon: Icons.copy_rounded,
            onTap: () => _copyAddress(context, account.address),
          ),
          const SizedBox(width: 6),
          _HeaderLogoButton(
            tooltip: 'Switch network',
            network: network,
            onTap: () => _showNetworkSwitcher(context),
          ),
          const SizedBox(width: 6),
          _HeaderIconButton(
            tooltip: 'Wallet menu',
            icon: Icons.menu_rounded,
            onTap: () => _showWalletMenu(context),
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
      ).showSnackBar(const SnackBar(content: Text('Address copied')));
    }
  }

  void _showAccountSwitcher(BuildContext context) {
    final state = context.walletState;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'Switch Account',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final account in state.currentWallet.accounts)
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(account.name),
                subtitle: Text(compactAddress(account.address)),
                trailing: account.id == state.currentAccount.id
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () {
                  state.switchAccount(account.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showNetworkSwitcher(BuildContext context) {
    final state = context.walletState;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'Switch Network',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final network in state.networks)
              ListTile(
                leading: ChainLogo(
                  chainId: network.id,
                  name: network.name,
                  colorValue: network.colorValue,
                  size: 40,
                ),
                title: Text(network.name),
                subtitle: Text(network.nativeSymbol),
                trailing: network.id == state.currentNetwork.id
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () {
                  state.switchNetwork(network.id);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showWalletMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'Wallet Menu',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Wallet Management'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRouteNames.walletManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.hub_outlined),
              title: const Text('Network Management'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamed(AppRouteNames.networkManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Security & Privacy'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRouteNames.securityPrivacy);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 24, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _HeaderLogoButton extends StatelessWidget {
  const _HeaderLogoButton({
    required this.tooltip,
    required this.network,
    required this.onTap,
  });

  final String tooltip;
  final ChainNetwork network;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Center(
            child: ChainLogo(
              chainId: network.id,
              name: network.name,
              colorValue: network.colorValue,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetOverview extends StatelessWidget {
  const _AssetOverview({
    required this.totalAssetsUsd,
    required this.hideBalances,
    required this.isRefreshing,
    required this.assetError,
    required this.onToggleHidden,
    required this.onRefresh,
  });

  final double totalAssetsUsd;
  final bool hideBalances;
  final bool isRefreshing;
  final String? assetError;
  final VoidCallback onToggleHidden;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final amountText = hideBalances
        ? '••••••'
        : 'US${formatCurrency(totalAssetsUsd)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 20, 2, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assetError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                assetError!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Text(
              amountText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                height: 0.98,
                letterSpacing: 0,
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  isRefreshing
                      ? 'Refreshing balances'
                      : 'Across visible networks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _AssetIconButton(
                tooltip: hideBalances ? 'Show amount' : 'Hide amount',
                onPressed: onToggleHidden,
                icon: hideBalances
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              const SizedBox(width: 8),
              _AssetIconButton(
                tooltip: 'Refresh assets',
                onPressed: isRefreshing ? null : () => onRefresh(),
                icon: Icons.refresh_rounded,
                loading: isRefreshing,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssetIconButton extends StatelessWidget {
  const _AssetIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.loading = false,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.48 : 0.7,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(icon, color: colorScheme.onSurfaceVariant, size: 24),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.north_east_rounded,
              label: 'Send',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SendFlowPage()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.south_west_rounded,
              label: 'Receive',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ReceivePage()),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => const ScanPage())),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.travel_explore_rounded,
              label: 'DAPP',
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('DAPP 入口即将开放')));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.42 : 0.56,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorScheme.onSurfaceVariant, size: 28),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
