import 'package:flutter/material.dart';

import '../../../shared/utils/wallet_formatters.dart';
import '../../../shared/widgets/chain_logo.dart';
import '../models/wallet_models.dart';

class TokenAssetTile extends StatelessWidget {
  const TokenAssetTile({
    super.key,
    required this.token,
    required this.network,
    required this.hideBalances,
    required this.onTap,
    required this.onHide,
  });

  final TokenAsset token;
  final ChainNetwork network;
  final bool hideBalances;
  final VoidCallback onTap;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final riskColor = colorScheme.error;
    final unitPrice = token.balance == 0
        ? 0.0
        : token.fiatValue / token.balance;

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
            _TokenIcon(token: token, network: network),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          token.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        token.symbol,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      if (token.isRisky) ...[
                        const SizedBox(width: 5),
                        Icon(
                          Icons.warning_amber_rounded,
                          color: riskColor,
                          size: 16,
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
                        hideBalances ? '••••' : formatCurrency(unitPrice),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (token.isRisky) ...[
                        Text(
                          '·',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        Text(
                          token.riskLabel ?? 'Risk',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: riskColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
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
                  hideBalances ? '••••' : formatCurrency(token.fiatValue),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  hideBalances
                      ? '•••• ${token.symbol}'
                      : '${formatTokenAmount(token.balance)} ${token.symbol}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 30,
              child: PopupMenuButton<String>(
                tooltip: 'Token actions',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (_) => onHide(),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'hide', child: Text('Hide token')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenIcon extends StatelessWidget {
  const _TokenIcon({required this.token, required this.network});

  final TokenAsset token;
  final ChainNetwork network;

  @override
  Widget build(BuildContext context) {
    final showChainLogo = token.contractAddress == 'Native asset';
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showChainLogo)
            ChainLogo(
              chainId: network.id,
              name: network.name,
              colorValue: network.colorValue,
              size: 44,
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(token.colorValue).withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  token.symbol.characters.first,
                  style: TextStyle(
                    color: Color(token.colorValue),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ChainLogo(
              chainId: network.id,
              name: network.name,
              colorValue: network.colorValue,
              size: 21,
              borderColor: Theme.of(context).scaffoldBackgroundColor,
              borderWidth: 2,
            ),
          ),
        ],
      ),
    );
  }
}
