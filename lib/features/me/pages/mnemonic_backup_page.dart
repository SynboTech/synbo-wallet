import 'package:flutter/material.dart';

import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/risk_banner.dart';
import '../../wallet/providers/wallet_state_scope.dart';
import 'mnemonic_verify_page.dart';

class MnemonicBackupPage extends StatefulWidget {
  const MnemonicBackupPage({super.key});

  @override
  State<MnemonicBackupPage> createState() => _MnemonicBackupPageState();
}

class _MnemonicBackupPageState extends State<MnemonicBackupPage> {
  List<String>? _mnemonicWords;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final words = await context.walletState.recoveryWordsForWallet();
      if (!mounted) {
        return;
      }
      setState(() => _mnemonicWords = words);
    });
  }

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
              child: _mnemonicWords == null
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var i = 0; i < _mnemonicWords!.length; i++)
                          Chip(label: Text('${i + 1}. ${_mnemonicWords![i]}')),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _mnemonicWords == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            MnemonicVerifyPage(words: _mnemonicWords!),
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
