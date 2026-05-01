import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('帮助中心')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            _HelpCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet basics',
              body: 'Create, import, back up, and switch accounts securely.',
            ),
            _HelpCard(
              icon: Icons.hub_outlined,
              title: 'Networks',
              body:
                  'Use the correct network before sending or receiving tokens.',
            ),
            _HelpCard(
              icon: Icons.verified_user_outlined,
              title: 'Approvals',
              body: 'Review token approvals and revoke unknown connected apps.',
            ),
            _HelpCard(
              icon: Icons.warning_amber_rounded,
              title: 'Transaction safety',
              body:
                  'Always verify From, To, Network, Token, Amount, Gas Fee, and Total.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
