import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/risk_banner.dart';
import 'mnemonic_verify_page.dart';

class MnemonicBackupPage extends StatelessWidget {
  const MnemonicBackupPage({super.key});

  static const mnemonic = [
    'river',
    'silver',
    'orbit',
    'fabric',
    'cactus',
    'lunar',
    'velvet',
    'harbor',
    'matrix',
    'signal',
    'ocean',
    'anchor',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('备份助记词')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const RiskBanner(
              message:
                  'Never share your recovery phrase. The wallet cannot recover funds if the phrase is lost or leaked.',
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < mnemonic.length; i++)
                    Chip(label: Text('${i + 1}. ${mnemonic[i]}')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MnemonicVerifyPage(),
                ),
              ),
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Verify Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
